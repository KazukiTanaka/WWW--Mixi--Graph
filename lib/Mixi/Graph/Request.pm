package Mixi::Graph::Request;
BEGIN {
  $Mixi::Graph::Request::VERSION = '0.0001';
}

use Any::Moose;
with 'Mixi::Graph::Role::Uri', 'Mixi::Graph::Role::Validator::Request';
use Mixi::Graph::Response;
use LWP::UserAgent;
use HTTP::Request::Common;

# must params
has client_secret => (
    is          => 'ro',
    required    => 0,
    predicate   => 'has_client_secret',
);

has access_token => (
    is          => 'ro',
    predicate   => 'has_access_token',
);

has user_id => (
    is          => 'rw',
    default     => '@me',
    predicate   => 'has_user_id',
);

has group_id => (
    is          => 'rw',
    default     => '@self',
    predicate   => 'has_group_id',
);

# common params
has startIndex => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Request::startIndex',
    default     => 0,
    predicate   => 'has_startIndex',
);

has count => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Request::count',
    default     => 20,
    predicate   => 'has_count',
);

# local methods params
has sub_path => (
    is          => 'rw',
    isa         => 'ArrayRef',
);

before [qw/ get post delete/] => sub {
    my ($self, $user_id, $group_id ) = @_;
    if ($user_id) {
        $self->user_id($user_id);
    }
    if ($group_id) {
        $self->group_id($group_id);
    }
    return $self;
};

sub get {
    my ($self) = @_;
    my $req = HTTP::Request::Common::GET(
        $self->_make_request_params('GET'),
    );
    return $self->request($req);
}

sub post {
    my ($self) = @_;
    my $req = HTTP::Request::Common::POST(
        $self->_make_request_params('POST'),
    );
    return $self->request($req);
}

sub delete {
    my ($self) = @_;
    my $req = HTTP::Request::Common::DELETE(
        $self->_make_request_params('DELETE'),
    );
    return $self->request($req);
}

sub _make_request_params{
    my ($self, $method) = @_;
    my $uri = $self->_make_uri_object($method);
    my @request_params = (
        'Host'          => $uri->host,
        'Authorization' => 'OAuth '.$self->access_token, 
    );
    if ($method eq 'GET') {
        unshift @request_params, $uri; 
    }
    elsif ($method eq 'POST'){
        unshift @request_params, (
            'http://'.$uri->host.$uri->path,
            [ $uri->query_form ],
        );
    }
    elsif ($method eq 'DELETE'){
        unshift @request_params, (
            'http://'.$uri->host.$uri->path
        );
    }
    return @request_params;
}

sub _make_uri_object {
    die 'must override a _make_uri_object method.';
}

sub request {
    my ($self, $req) = @_;

    my $response = LWP::UserAgent->new(
        timeout => 10,
    )->request($req);

    my %params = (response => $response);
    if ($self->has_client_secret) {
        $params{client_secret} = $self->client_secret;
    }
    return Mixi::Graph::Response->new(%params);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Mixi::Graph;
BEGIN {
  $Mixi::Graph::VERSION = '0.0001';
}

use Any::Moose;
use Mixi::Graph::AccessToken;
use Mixi::Graph::Authorize;
use Mixi::Graph::Query;
use Mixi::Graph::Request::People;
use Mixi::Graph::Request::Groups;
use Mixi::Graph::Request::Search;
use Mixi::Graph::Request::Voice;
use Mixi::Graph::Request::Photo;
use Mixi::Graph::Publish::Post;

has client_id => (
    is      => 'ro',
);

has client_secret => (
    is          => 'ro',
    predicate   => 'has_client_secret',
);

has redirect_uri => (
    is      => 'ro',
);

has access_token => (
    is          => 'rw',
    predicate   => 'has_access_token',
);

has refresh_token => (
    is          => 'rw',
    predicate   => 'has_refresh_token',
);

has expires_in => (
    is          => 'rw',
    predicate   => 'has_expires_in',
);

has common_params => (
    is          => 'rw',
    isa         => 'HashRef',
);

sub request_access_token {
    my ($self, $code) = @_;
    my $token = Mixi::Graph::AccessToken->new(
        code            => $code,
        redirect_uri    => $self->redirect_uri,
        client_secret   => $self->client_secret,
        client_id       => $self->client_id,
    )->request;
    $self->expires_in($token->expires_in);
    $self->access_token($token->token);
    $self->refresh_token($token->refresh_token);
    return $token;
}

sub refresh_access_token {
    my ($self, $refresh_token) = @_;
    my $token = Mixi::Graph::AccessToken->new(
        refresh_token   => $refresh_token,
        client_secret   => $self->client_secret,
        client_id       => $self->client_id,
    )->set_grant_type('refresh_token')->request;
    $self->expires_in($token->expires_in);
    $self->access_token($token->token);
    $self->refresh_token($token->refresh_token);
    return $token;
}

sub authorize { 
    my ($self, %params) = @_;
    return Mixi::Graph::Authorize->new(
        client_id       => $self->client_id,
        %params,
    );
}

sub fetch {
    my ($self, $object_name) = @_;
    return $self->query->find($object_name)->request->as_hashref;
}

before [qw/query people groups voice photo/] => sub {
    my ($self, %params) = @_;
    my %common_params;
    if ($self->has_access_token) {
        $common_params{access_token} = $self->access_token;
    }    
    if ($self->has_client_secret) {
        $common_params{client_secret} = $self->client_secret;
    }
    if ($params{startIndex}) {
        $common_params{startIndex} = $params{startIndex};
    }
    if ($params{count}) {
        $common_params{count} = $params{count};
    }
    $self->common_params(\%common_params);
    return;
};

sub query {
    my ($self) = @_;
    return Mixi::Graph::Query->new( %{$self->common_params} );
}

sub people {
    my ($self, %params) = @_;
    return Mixi::Graph::Request::People->new( %{$self->common_params}, %params );
}

sub groups {
    my ($self) = @_;
    return Mixi::Graph::Request::Groups->new( %{$self->common_params} );
}

sub search {
    my ($self) = @_;
    return Mixi::Graph::Request::Search->new( %{$self->common_params} );
}

sub voice {
    my ($self) = @_;
    return Mixi::Graph::Request::Voice->new( %{$self->common_params} );
}

sub photo {
    my ($self) = @_;
    return Mixi::Graph::Request::Photo->new( %{$self->common_params} );
}



sub add_post {
    my ($self, $object_name) = @_;
    my %params;
    if ($object_name) {
        $params{object_name} = $object_name;
    }
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_client_secret) {
        $params{client_secret} = $self->client_secret;
    }
    return Mixi::Graph::Publish::Post->new( %params );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


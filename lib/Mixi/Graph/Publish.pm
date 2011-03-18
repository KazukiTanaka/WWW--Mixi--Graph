package Mixi::Graph::Publish;
BEGIN {
  $Mixi::Graph::Publish::VERSION = '0.0001';
}

use Any::Moose;
use Mixi::Graph::Response;
with 'Mixi::Graph::Role::Uri';
use LWP::UserAgent;
use URI::Encode qw(uri_decode);

has client_secret => (
    is          => 'ro',
    required    => 0,
    predicate   => 'has_secret',
);

has access_token => (
    is          => 'ro',
    predicate   => 'has_access_token',
);

has object_name => (
    is          => 'rw',
    default     => '',
);

sub to {
    my ($self, $object_name) = @_;
    $self->object_name($object_name);
    return $self;
}

sub get_post_params {
    my $self = shift;
    my @post;
    if ($self->has_access_token) {
        push @post, oauth_token => uri_decode($self->access_token);
    }
    return \@post;
}

sub publish {
    my ($self) = @_;
    my $uri = $self->uri;
    $uri->path($self->object_path.$self->object_name);
    my $response = LWP::UserAgent->new->post($uri, $self->get_post_params);
    my %params = (response => $response);
    if ($self->has_secret) {
        $params{client_secret} = $self->client_secret;
    }
    return Mixi::Graph::Response->new(%params);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

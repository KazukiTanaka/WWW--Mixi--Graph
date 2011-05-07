package Mixi::Graph::AccessToken;
BEGIN {
  $Mixi::Graph::AccessToken::VERSION = '0.0001';
}

use Any::Moose;
use Mixi::Graph::AccessToken::Response;
with 'Mixi::Graph::Role::Uri';
use LWP::UserAgent;

has client_id => (
    is      => 'ro',
    required=> 1,
);

has grant_type => (
    is      => 'rw',
    default => 'authorization_code',
);

has refresh_token => (
    is      => 'rw',
    default => '',
);

has client_secret => (
    is      => 'ro',
    required=> 1,
);

has redirect_uri => (
    is      => 'ro',
    required=> 0,
);

has code => (
    is      => 'ro',
    required=> 0,
);

sub set_grant_type {
    my ($self, $grant_type) = @_;
    $self->grant_type($grant_type);
    return $self;
} 

sub request {
    my ($self) = @_;
    my $uri = $self->token_uri;
    my $response = LWP::UserAgent->new->post($uri,{
        grant_type      => $self->grant_type,
        client_id       => $self->client_id,
        client_secret   => $self->client_secret,
        code            => $self->code,
        redirect_uri    => $self->redirect_uri,
        refresh_token   => $self->refresh_token,
    });
    return Mixi::Graph::AccessToken::Response->new(response => $response);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


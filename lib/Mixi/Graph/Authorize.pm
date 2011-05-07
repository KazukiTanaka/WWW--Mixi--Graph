package Mixi::Graph::Authorize;
BEGIN {
  $Mixi::Graph::Authorize::VERSION = '0.0001';
}

use Any::Moose;
with 'Mixi::Graph::Role::Uri';

has client_id => (
    is      => 'ro',
    required=> 1,
);

has response_type => (
    is      => 'rw',
    default => 'code',
);

has display => (
    is      => 'rw',
    default => 'pc',
);

has permissions => (
    is          => 'rw',
    lazy        => 1,
    predicate   => 'has_permissions',
    default     => sub { [] },
);

has state => (
    is      => 'rw',
);


sub extend_permissions {
    my ($self, @permissions) = @_;
    push @{$self->permissions}, @permissions;
    return $self;
}

sub set_display {
    my ($self, $display) = @_;
    $self->display($display);
    return $self;
}

sub set_response_type {
    my ($self, $response_type) = @_;
    $self->response_type($response_type);
    return $self;
}

sub set_state {
    my ($self, $state) = @_;
    $self->state($state);
    return $self;
}

sub uri_as_string {
    my ($self) = @_;
    my $uri = $self->oauth_uri;
    my %query = (
        client_id       => $self->client_id,
        response_type   => $self->response_type,
        display         => $self->display,
        state           => $self->state,
    );
    $query{scope} = join(' ', @{$self->permissions}) if ($self->has_permissions);
    $uri->query_form(%query);
    return $uri->as_string;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


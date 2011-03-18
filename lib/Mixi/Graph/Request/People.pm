package Mixi::Graph::Request::People;
BEGIN {
  $Mixi::Graph::Request::People::VERSION = '0.0001';
}

use Any::Moose;
extends 'Mixi::Graph::Request';
with 'Mixi::Graph::Role::Validator::Request::People';
use constant base_path => '/2/people';

has sortBy => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Request::People::sortBy',
    predicate   => 'has_sortBy',
);

has sortOrder => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Request::People::sortOrder',
    predicate   => 'has_sortOrder',
);

sub _make_uri_object{
    my ($self, $method) = @_;

    # make path
    my @path = (
        $self->base_path,
        $self->user_id,
        $self->group_id
    );

    # make request params
    my %params;
    if ($self->has_startIndex) {
        $params{startIndex} = $self->startIndex;
    }
    if ($self->has_count) {
        $params{count} = $self->count;
    }
    if ($self->has_sortBy) {
        $params{sortBy} = $self->sortBy;
    }
    if ($self->has_sortOrder) {
        $params{sortOrder} = $self->sortOrder;
    }

    my $uri = $self->uri;
    $uri->path(join('/', @path));
    $uri->query_form(%params);
    return $uri;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Mixi::Graph::Request::Groups;
BEGIN {
  $Mixi::Graph::Request::Groups::VERSION = '0.0001';
}

use Any::Moose;
extends 'Mixi::Graph::Request';
use constant base_path => '/2/groups';

sub _make_uri_object{
    my ($self, $method) = @_;

    # make path
    my @path = (
        $self->base_path,
        $self->user_id,
    );

    # make request params
    my %params;
    if ($self->has_startIndex) {
        $params{startIndex} = $self->startIndex;
    }
    if ($self->has_count) {
        $params{count} = $self->count;
    }

    my $uri = $self->uri;
    $uri->path(join('/', @path));
    $uri->query_form(%params);
    return $uri;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


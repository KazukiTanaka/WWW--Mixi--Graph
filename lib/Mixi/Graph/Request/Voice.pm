package Mixi::Graph::Request::Voice;
BEGIN {
  $Mixi::Graph::Request::Voice::VERSION = '0.0001';
}

use Any::Moose;
extends 'Mixi::Graph::Request';
with 'Mixi::Graph::Role::Validator::Request::Voice';
use constant base_path => '/2/voice';

# common params
has post_id => (
    is          => 'rw',
    predicate   => 'has_post_id',
);

# user_timeline params
has since_id => (
    is          => 'rw',
    predicate   => 'has_since_id',
);

has trim_user => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Request::Voice::trim_user',
    predicate   => 'has_trim_user',
);

has attach_photo => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Request::Voice::attach_photo',
    predicate   => 'has_attach_photo',
);

#TODO utf8 check
has status => (
    is          => 'rw',
    predicate   => 'has_status',
);
has text => (
    is          => 'rw',
    predicate   => 'has_text',
);

sub statuses{
    my ($self, %params) = @_;
    if ($params{post_id}) {
        $self->post_id($params{post_id});
    }
    if ($params{trim_user}) {
        $self->trim_user($params{trim_user});
    }
    if ($params{attach_photo}) {
        $self->attach_photo($params{attach_photo});
    }
    if ($params{status}) {
        $self->status($params{status});
    }

    $self->sub_path([qw/ statuses / ]);
    return $self;
}

sub user_timeline{
    my ($self, %params) = @_;
    if ($params{since_id}) {
        $self->since_id($params{since_id});
    }
    if ($params{user_id}) {
        $self->user_id($params{user_id});
    }

    $self->sub_path( [ qw/ statuses /, $self->user_id, qw/ user_timeline / ]);
    return $self;
}

sub friends_timeline{
    my ($self, %params) = @_;
    if ($params{since_id}) {
        $self->since_id_id($params{since_id});
    }
    if ($params{group_id}) {
        $self->group_id($params{group_id});
    }

    $self->sub_path([ qw/ statuses friends_timeline / ]);
    push @{$self->sub_path}, $self->group_id if ($params{group_id});
    return $self;
}

sub replies{
    my ($self, %params) = @_;
    if ($params{post_id}) {
        $self->post_id($params{post_id});
    }
    if ($params{text}) {
        $self->text($params{text});
    }

    $self->sub_path([ qw/ replies / ]);
    return $self;
}

sub favorites{
    my ($self, %params) = @_;
    if ($params{post_id}) {
        $self->post_id($params{post_id});
    }

    $self->sub_path([ qw/ favorites / ]);
    return $self;
}

sub _make_uri_object{
    my ($self, $method) = @_;

    # make path
    my @path = (
        $self->base_path,
        @{$self->sub_path},
    );
    if ($self->has_post_id) {
        push @path, $self->post_id;
    }

    # make request params
    my %params;
    if ($method eq 'GET') {
        if ($self->has_startIndex) {
            $params{startIndex} = $self->startIndex;
        }
        if ($self->has_count) {
            $params{count} = $self->count;
        }
        if ($self->has_since_id) {
            $params{since_id} = $self->since_id;
        }
        if ($self->has_trim_user) {
            $params{trim_user} = $self->trim_user;
        }
        if ($self->has_attach_photo) {
            $params{attach_photo} = $self->attach_photo;
        }
    }
    elsif ($method eq 'POST') {
        if ($self->has_status) {
            $params{status} = $self->status;
        }
        if ($self->has_text) {
            $params{text} = $self->text;
        }
    }

    my $uri = $self->uri;
    $uri->path(join('/', @path));
    $uri->query_form(%params);
    return $uri;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


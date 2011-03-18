package Mixi::Graph::Query;
BEGIN {
  $Mixi::Graph::Query::VERSION = '0.0001';
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

has ids => (
    is          => 'rw',
    predicate   => 'has_ids',
    lazy        => 1,
    default     => sub { [] },
);

has fields => (
    is          => 'rw',
    predicate   => 'has_fields',
    lazy        => 1,
    default     => sub { [] },
);

has metadata => (
    is          => 'rw',
    predicate   => 'has_metadata',
);

has limit => (
    is          => 'rw',
    predicate   => 'has_limit',
);

has offset => (
    is          => 'rw',
    predicate   => 'has_offset',
);

has search_query => (
    is          => 'rw',
    predicate   => 'has_search_query',
);

has search_type => (
    is          => 'rw',
    predicate   => 'has_search_type',
);

has object_name => (
    is          => 'rw',
    default     => '',
);

has until => (
    is          => 'rw',
    predicate   => 'has_until',
);

has since => (
    is          => 'rw',
    predicate   => 'has_since',
);


sub limit_results {
    my ($self, $limit) = @_;
    $self->limit($limit);
    return $self;    
}

sub find {
    my ($self, $object_name) = @_;
    $self->object_name($object_name);
    return $self;
}

sub search {
    my ($self, $query, $type) = @_;
    $self->search_query($query);
    return ($type) ? $self->from($type) : $self;
}

sub from {
    my ($self, $type) = @_;
    if ($type eq 'my_news') {
        $self->object_name('me/home');
    }
    else {
        $self->object_name('search');
        $self->search_type($type);
    }
    return $self;
}

sub offset_results {
    my ($self, $offset) = @_;
    $self->offset($offset);
    return $self;    
}

sub include_metadata {
    my ($self, $include) = @_;
    $include = 1 unless defined $include;
    $self->metadata($include);
    return $self;
}

sub select_fields {
    my ($self, @fields) = @_;
    push @{$self->fields}, @fields;
    return $self;
}

sub where_ids {
    my ($self, @ids) = @_;
    push @{$self->ids}, @ids;
    return $self;
}

sub where_until {
    my ($self, $date) = @_;
    $self->until($date);
    return $self;
}

sub where_since {
    my ($self, $date) = @_;
    $self->since($date);
    return $self;
}

sub uri_as_string {
    my ($self) = @_;
    my %query;
    if ($self->has_access_token) {
        $query{oauth_token} = uri_decode($self->access_token);
    }
    if ($self->has_limit) {
        $query{limit} = $self->limit;
        if ($self->has_offset) {
            $query{offset} = $self->offset;
        }
    }
    if ($self->has_search_query) {
        $query{q} = $self->search_query;
        if ($self->has_search_type) {
            $query{type} = $self->search_type;
        }
    }
    if ($self->has_until) {
        $query{until} = $self->until;
    }
    if ($self->has_since) {
        $query{since} = $self->since;
    }
    if ($self->has_metadata) {
        $query{metadata} = $self->metadata;
    }
    if ($self->has_fields) {
        $query{fields} = join(',', @{$self->fields});
    }
    if ($self->has_ids) {
        $query{ids} = join(',', @{$self->ids});
    }
    my $uri = $self->uri;
    $uri->path($self->object_name);
    $uri->query_form(%query);
    return $uri->as_string;
}

sub request {
    my ($self, $uri) = @_;
    $uri ||= $self->uri_as_string;
    my $response = LWP::UserAgent->new->get($uri);
    my %params = (response => $response);
    if ($self->has_secret) {
        $params{client_secret} = $self->client_secret;
    }
    return Mixi::Graph::Response->new(%params);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Mixi::Graph::Publish::Post;
BEGIN {
  $Mixi::Graph::Publish::Post::VERSION = '0.0001';
}

use Any::Moose;
extends 'Mixi::Graph::Publish';

use constant object_path => '/2/voice';

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
    return $self;
}

has picture => (
    is          => 'rw',
    predicate   => 'has_picture',
);

sub set_picture {
    my ($self, $picture) = @_;
    $self->picture($picture);
    return $self;
}


has link_uri => (
    is          => 'rw',
    predicate   => 'has_link_uri',
);

sub set_link_uri {
    my ($self, $source) = @_;
    $self->link_uri($source);
    return $self;
}


has link_name => (
    is          => 'rw',
    predicate   => 'has_link_name',
);

sub set_link_name {
    my ($self, $source) = @_;
    $self->link_name($source);
    return $self;
}


has link_caption => (
    is          => 'rw',
    predicate   => 'has_link_caption',
);

sub set_link_caption {
    my ($self, $source) = @_;
    $self->link_caption($source);
    return $self;
}


has link_description => (
    is          => 'rw',
    predicate   => 'has_link_description',
);

sub set_link_description {
    my ($self, $source) = @_;
    $self->link_description($source);
    return $self;
}

has target_countries => (
    is          => 'rw',
    default     => sub {[]},
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_countries',
);

sub set_target_countries {
    my ($self, $source) = @_;
    $self->target_countries($source);
    return $self;
}

has target_cities => (
    is          => 'rw',
    default     => sub {[]},
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_cities',
);

sub set_target_cities {
    my ($self, $source) = @_;
    $self->target_cities($source);
    return $self;
}

has target_regions => (
    is          => 'rw',
    default     => sub {[]},
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_regions',
);

sub set_target_regions {
    my ($self, $source) = @_;
    $self->target_regions($source);
    return $self;
}

has target_locales => (
    is          => 'rw',
    default     => sub {[]},
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_locales',
);

sub set_target_locales {
    my ($self, $source) = @_;
    $self->target_locales($source);
    return $self;
}

has source => (
    is          => 'rw',
    predicate   => 'has_source',
);

sub set_source {
    my ($self, $source) = @_;
    $self->source($source);
    return $self;
}

has actions => (
    is          => 'rw',
    default     => sub {[]},
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_actions',
);

sub set_actions {
    my ($self, $actions) = @_;
    $self->actions($actions);
    return $self;
}

sub add_action {
    my ($self, $name, $link) = @_;
    my $actions = $self->actions;
    push @$actions, { name => $name, link => $link };
    $self->actions($actions);
    return $self;
}

has privacy => (
    is          => 'rw',
    predicate   => 'has_privacy',
);

has privacy_options => (
    is          => 'rw',
    isa         => 'HashRef',
    default     => sub {{}},
);

sub set_privacy {
    my ($self, $privacy, $options) = @_;
    $self->privacy($privacy);
    $self->privacy_options($options);
    return $self;
}

around get_post_params => sub {
    my ($orig, $self) = @_;
    my $post = $orig->($self);
    if ($self->has_message) {
        push @$post, status => $self->message;
    }
    if ($self->has_link_uri) {
        push @$post, link => $self->link_uri;
    }
    if ($self->has_link_name) {
        push @$post, name => $self->link_name;
    }
    if ($self->has_link_caption) {
        push @$post, caption => $self->link_caption;
    }
    if ($self->has_link_description) {
        push @$post, description => $self->link_description;
    }
    if ($self->has_picture) {
        push @$post, photo => $self->picture;
    }
    if ($self->has_source) {
        push @$post, source => $self->source;
    }
    if ($self->has_actions) {
        foreach my $action (@{$self->actions}) {
            push @$post, actions => JSON->new->encode($action);
        }
    }
    if ($self->has_privacy) {
        my %privacy = %{$self->privacy_options};
        $privacy{value} = $self->privacy;
        push @$post, privacy => JSON->new->encode(\%privacy);
    }
    return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;



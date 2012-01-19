package Mixi::Graph::Request::Photo;
BEGIN {
  $Mixi::Graph::Request::Photo::VERSION = '0.0001';
}
# TODO Upload 処理があるから独立実装、VoiceでもUpできるように統一する。
use Any::Moose;
use Mixi::Graph::Response;
with 'Mixi::Graph::Role::Uri', 'Mixi::Graph::Role::Validator::Photo';
use HTTP::Request::StreamingUpload;
use HTTP::Headers;
use HTTP::Request::Common;
use LWP::UserAgent;

use Data::Dumper;

use constant base_path => '/2/photo';

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

# albums params
has album_id => (
    is          => 'rw',
    predicate   => 'has_album_id',
);

has title => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'title is undefined',
    predicate   => 'has_title',
);

has description => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'description is undefined',
    predicate   => 'has_description',
);

has visibility => (
    is          => 'rw',
    isa         => 'Mixi::Graph::Role::Validator::Photo::visibility',
    default     => 'friends',
    predicate   => 'has_visibility',
);

has accessKey => (
    is          => 'rw',
    predicate   => 'has_accessKey',
);

# mediaItem
has mediaItem_id => (
    is          => 'rw',
    predicate   => 'has_mediaItem_id',
);

has file_path => (
    is          => 'rw',
    predicate   => 'has_file_path',
);

# comments params
has comment_id => (
    is          => 'rw',
    predicate   => 'has_comment_id',
);

has text => (
    is          => 'rw',
    isa         => 'Str',
    predicate   => 'has_text',
);

has favorite_user_id => (
    is          => 'rw',
    predicate   => 'has_favorite_user_id',
);

# local methods params
has sub_path => (
    is          => 'rw',
    isa         => 'ArrayRef',
);

# api common params
has startIndex => (
    is          => 'rw',
    default     => 0,
    predicate   => 'has_startIndex',
);

has count => (
    is          => 'rw',
    default     => 20,
    predicate   => 'has_count',
);



before [qw/get post delete/] => sub {
    my ($self, %params) = @_;
    if ($params{user_id}) {
        $self->user_id($params{user_id});
    }
    if ($params{group_id}) {
        $self->group_id($params{group_id});
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
    my $req;

    if ($self->sub_path->[0] eq 'mediaItems' 
        && $self->has_file_path ) {
        my $uri = $self->_make_uri_object('POST');
        $req = HTTP::Request::StreamingUpload->new(
            POST    => $uri,
            path    => $self->file_path,
            headers => HTTP::Headers->new(
                'Content-Type'      => 'image/jpeg',
                'Content-Length'    => -s $self->file_path,
                'Host'              => $uri->host,
                'Authorization'     => 'OAuth '.$self->access_token, 
            ),
        );
    }
    else {
        $req = HTTP::Request::Common::POST(
            $self->_make_request_params('POST'),
        );
    }
    return $self->request($req);
}

sub delete {
    my ($self) = @_;
    my $req = HTTP::Request::Common::DELETE(
        $self->_make_request_params('DELETE'),
    );
    return $self->request($req);
}

sub albums {
    my ($self, %params) = @_;
    if ($params{album_id}) {
        $self->album_id($params{album_id});
    }
    if ($params{title}) {
        $self->title($params{title});
    }
    if ($params{description}) {
        $self->description($params{description});
    }
    if ($params{visibility}) {
        $self->visibility($params{visibility});
    }
    if ($params{accessKey}) {
        $self->accessKey($params{accessKey});
    }

    $self->sub_path([qw/ albums /]);
    return $self;
}

sub mediaItems {
    my ($self, %params) = @_;
    if ($params{mediaItem_id}) {
        $self->mediaItem_id($params{mediaItem_id});
    }
    if ($params{title}) {
        $self->title($params{title});
    }
    if ($params{file_path}) {
        $self->file_path($params{file_path});
    }

    $self->sub_path([qw/ mediaItems /]);
    return $self;
}

sub comments {
    my ($self, %params) = @_;
    # TODO delete
    if ($params{comment_id}) {
        $self->comment_id($params{comment_id});
    }
    if ($params{text}) {
        $self->text($params{text});
    }

    $self->sub_path([ qw/ comments /, $self->sub_path->[-1] ]);
    return $self;
}

sub favorites {
    my ($self, %params) = @_;
    # TODO delete
    if ($params{favorite_user_id}) {
        $self->favorite_user_id($params{favorite_user_id});
    }

    $self->sub_path([qw/ favorites mediaItems /]);
    return $self;
}

sub _make_uri_object{
    my ($self, $method) = @_;

    # make path
    my @path = (
        $self->base_path,
        @{$self->sub_path},
        $self->user_id,
        $self->group_id
    );
    if ($self->has_album_id) {
        push @path, $self->album_id;
    }
    if ($self->has_mediaItem_id) {
        push @path, $self->mediaItem_id;
    }
    if ($self->has_comment_id) {
        push @path, $self->comment_id;
    }
    elsif ($self->has_favorite_user_id) {
        push @path, $self->favorite_user_id;
    }

    # make request params
    my %params;
    if ($self->has_accessKey) {
        $params{accessKey} = $self->accessKey;
    }
    if ($method eq 'GET') {
        if ($self->has_startIndex) {
            $params{startIndex} = $self->startIndex;
        }
        if ($self->has_count) {
            $params{count} = $self->count;
        }
    }
    elsif ($method eq 'POST') {
        if ($self->sub_path->[0] eq 'albums') {
            if ($self->has_title) {
                $params{title}          = $self->title;
                $params{description}    = $self->description;
                $params{visibility}     = $self->visibility;
            }
        }    
        elsif ($self->sub_path->[0] eq 'mediaItems') {
            if ($self->has_title) {
                $params{title}          = $self->title;
            }
        }
        elsif ($self->sub_path->[0] eq 'comments') {
            if ($self->has_text) {
                $params{text}           = $self->text;
            }
        }
    }

    my $uri = $self->uri;
    $uri->path(join('/', @path));
    $uri->query_form(%params);
    return $uri;
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


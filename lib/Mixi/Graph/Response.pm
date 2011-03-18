package Mixi::Graph::Response;
BEGIN {
  $Mixi::Graph::Response::VERSION = '1.0100';
}

use Any::Moose;
use JSON;
use Mixi::Graph::Exception;

has response => (
    is      => 'ro',
    required=> 1,
);

has as_string => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->response->content;
    },
);

has as_json => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            return $response->content;
        }
        else {
            my $message = $response->message;
            my $error = eval { JSON->new->decode($response->content) };
            my $type = 'Unknown';
            my $fberror = 'Unknown';
            unless ($@) {
                $fberror = $error->{error}{message};
                $message = $error->{error}{type} . ' - ' . $error->{error}{message};
                $type = $error->{error}{type};
            }
            Mixi::Graph::Exception::RPC->throw(
                error           => 'Could not execute request ('.$response->request->uri->as_string.'): '.$message,
                uri             => $response->request->uri->as_string,
                http_code       => $response->code,
                http_message    => $response->message,
                mixi_message    => $fberror,
                mixi_type       => $type,
            );
        }
    },
);

has as_hashref => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return JSON->new->utf8(1)->decode($self->as_json);
    },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

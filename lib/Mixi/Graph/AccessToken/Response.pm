package Mixi::Graph::AccessToken::Response;
BEGIN {
  $Mixi::Graph::AccessToken::Response::VERSION = '0.0001';
}

use Any::Moose;
use JSON qw/decode_json/;
use Mixi::Graph::Exception;

has response => (
    is      => 'ro',
    required=> 1,
);

has token => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            my $token_res_hash = JSON::decode_json($response->content);
            return $token_res_hash->{access_token};
        }
        else {
            Mixi::Graph::Exception::RPC->throw(
                error               => 'Could not fetch access token: '.$response->message,
                uri                 => $response->request->uri->as_string,
                http_code           => $response->code,
                http_message        => $response->message,
                mixi_message        => 'Could not fetch access token.',
                mixi_type           => 'None',
            );
        }
    }
);

has expires => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            my $token_res_hash = JSON::decode_json($response->content);
            return $token_res_hash->{expires_in};
        }
        else {
            Mixi::Graph::Exception::RPC->throw(
                error               => 'Could not fetch access token: '.$response->message,
                uri                 => $response->request->uri->as_string,
                http_code           => $response->code,
                http_message        => $response->message,
                mixi_message        => 'Could not fetch access token.',
                mixi_type           => 'None',
            );
        }
    }
);

has refresh_token => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            my $token_res_hash = JSON::decode_json($response->content);
            return $token_res_hash->{refresh_token};
        }
        else {
            Mixi::Graph::Exception::RPC->throw(
                error               => 'Could not fetch access token: '.$response->message,
                uri                 => $response->request->uri->as_string,
                http_code           => $response->code,
                http_message        => $response->message,
                mixi_message        => 'Could not fetch access token.',
                mixi_type           => 'None',
            );
        }
    }
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

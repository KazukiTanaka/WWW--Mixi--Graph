package Mixi::Graph::Role::Uri;
BEGIN {
  $Mixi::Graph::Role::Uri::VERSION = '0.0001';
}

use Any::Moose 'Role';
use URI;

sub uri {
    return URI->new('http://api.mixi-platform.com')
}

sub oauth_uri {
    return URI->new('https://mixi.jp/connect_authorize.pl')
}

sub token_uri {
    return URI->new('https://secure.mixi-platform.com/2/token');
}

1;


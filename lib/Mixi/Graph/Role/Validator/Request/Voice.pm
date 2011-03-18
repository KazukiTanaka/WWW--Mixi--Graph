package Mixi::Graph::Role::Validator::Request::Voice;
BEGIN {
  $Mixi::Graph::Role::Validator::Request::Voice::VERSION = '0.0001';
}

use Any::Moose '::Util::TypeConstraints';
use Any::Moose 'Role';

subtype 'Mixi::Graph::Role::Validator::Request::Voice::trim_user'
    => as 'Str',
    => where { $_ =~ /\A(?:1|true|t)\z/ }
    => message { "The String you provided, $_, was not 1|true|t" };

subtype 'Mixi::Graph::Role::Validator::Request::Voice::attach_photo'
    => as 'Str',
    => where { $_ =~ /\A(?:1|true|t)\z/ }
    => message { "The String you provided, $_, was not 1|true|t" };

1;


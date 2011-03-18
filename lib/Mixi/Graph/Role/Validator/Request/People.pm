package Mixi::Graph::Role::Validator::Request::People;
BEGIN {
  $Mixi::Graph::Role::Validator::Request::People::VERSION = '0.0001';
}

use Any::Moose '::Util::TypeConstraints';
use Any::Moose 'Role';

subtype 'Mixi::Graph::Role::Validator::Request::People::sortBy'
    => as 'Str',
    => where { $_ =~ /\AdisplayName\z/ }
    => message { "The String you provided, $_, was not displayName" };

subtype 'Mixi::Graph::Role::Validator::Request::People::sortOrder'
    => as 'Str',
    => where { $_ =~ /[ascending|descending]/ }
    => message { "The String you provided, $_, was not [ascending|descending]" };

1;


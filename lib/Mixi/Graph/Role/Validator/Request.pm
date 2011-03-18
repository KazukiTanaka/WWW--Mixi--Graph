package Mixi::Graph::Role::Validator::Request;
BEGIN {
  $Mixi::Graph::Role::Validator::Request::VERSION = '0.0001';
}

use Any::Moose '::Util::TypeConstraints';
use Any::Moose 'Role';

subtype 'Mixi::Graph::Role::Validator::Request::startIndex'
    => as 'Int',
    => where { 0 <= $_ }
    => message { "The Value you provided, startIndex was not 0 <= $_" };

subtype 'Mixi::Graph::Role::Validator::Request::count'
    => as 'Int',
    => where { 0 <= $_ }
    => message { "The Value you provided, count was not 0 <= $_" };

1;


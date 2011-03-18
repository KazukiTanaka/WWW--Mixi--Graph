package Mixi::Graph::Role::Validator::Photo;
BEGIN {
  $Mixi::Graph::Role::Validator::Photo::VERSION = '0.0001';
}

use Any::Moose '::Util::TypeConstraints';
use Any::Moose 'Role';

subtype 'Mixi::Graph::Role::Validator::Photo::visibility'
    => as 'Str',
    => where { $_ =~ /[everyone|friends|friends_of_friends|top_friends|access_key|self]/ }
    => message { "The String you provided, $_, was not [everyone|friends|friends_of_friends|top_friends|access_key|self]" };


1;


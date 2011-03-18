package Mixi::Graph::Exception;
BEGIN {
  $Mixi::Graph::Exception::VERSION = '0.0001';
}


use Exception::Class (
 
    'Mixi::Graph::Exception::General' => {
        description     => "A general exception has occured.",
    },

    'Mixi::Graph::Exception::RPC' => {
        isa             => 'Mixi::Graph::Exception::General',
        description     => "An error occurred communicating with Mixi.",
        fields          => [qw(http_code http_message mixi_message mixi_type uri)],
    },
 
 
);


1;


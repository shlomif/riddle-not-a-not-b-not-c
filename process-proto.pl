#!/usr/bin/perl

use strict;
use warnings;

use IO::All;

sub proc
{
    local $_ = shift;
    
    s/\$get->\(\$_\)/\$p[\$_]/;
    s/\$not_def->\(([^\)]+)\)/(!defined(\$p[$1]))/;
    s/\$set->\(([^,]+),([^\)]+)\)/\$p[$1] = $2/;

    return $_;
}

io->file("not-a-opt.pl")->print(
    map { proc($_) } io->file("not-a-opt-proto.pl")->getlines()
);
   

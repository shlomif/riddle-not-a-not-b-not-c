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
    s/neg\(([^\)]+)\)/((~($1))&\$limit)/;

    return $_;
}

io->file("not-a-opt.pl")->print(
    map { proc($_) } io->file("not-a-opt-proto.pl")->getlines()
);

=head1 COPYRIGHT & LICENSE

Copyright 2010 Shlomi Fish.

This program is released under the following license: MIT/X11
( L<http://www.opensource.org/licenses/mit-license.php> ).

=cut


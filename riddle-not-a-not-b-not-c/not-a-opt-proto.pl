#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw(notall);

my $limit = 0xFF;

# @p is the population of the positions.
my @p = (map { undef() } (0 .. $limit));

sub neg
{
    return ((~(shift())) & $limit);
}

my %initial;

my $A = $initial{A} = 0b11110000;
my $B = $initial{B} = 0b11001100;
my $C = $initial{C} = 0b10101010;

my $NOT_A = neg($A);
my $NOT_B = neg($B);
my $NOT_C = neg($C);

# $initial{NOT_AND} = ((~($initial{A} & $initial{B} & $initial{C})) & $limit);
# $initial{NOT_OR2} = ((~($initial{A} | $initial{B} | $initial{C})) & $limit);
# $initial{NOT_OR} = ((~(($A & $B) | ($A & $C) | ($B & $C))) & $limit);
# $initial{B_NOT} = ((~$B) & $limit);
# $initial{C_NOT} = ((~$C) & $limit);
# $initial{NOT_AB} = ((~(($A | $B))) & $limit);
# $initial{NOT_AC} = ((~(($A & $C))) & $limit);

# $initial{NOT_OR} = ((~($B & ($A | $C))) & $limit);
# $initial{NOT_AND2} = ((~($B)) & $limit);

my $get = sub {
    my $i = shift;

    return $p[$i];
};

my $not_def = sub {
    my $i = shift;

    return !defined($get->($i));
};

my $set = sub {
    my ($i, $val) = @_;

    $p[$i] = $val;

    return;
};

while (my ($key, $mask) = each(%initial))
{
    $set->($mask, ['i', $key]);
}

sub find
{
    POP:
    while (notall { $get->($_) } ($NOT_A, $NOT_B, $NOT_C))
    {
        X_LOOP:
        for my $x (0 .. ($limit-1))
        {
            if ($not_def->($x))
            {
                next X_LOOP;
            }

            Y_LOOP:
            for my $y (($x+1) .. $limit)
            {
                if ($not_def->($y))
                {
                    next Y_LOOP;
                }

                my $new;
                if ($not_def->($x & $y))
                {
                    $set->(($x & $y), ['&', $x, $y]);
                    $new = 1;
                }

                if ($not_def->($x | $y))
                {
                    $set->(($x | $y), ['|', $x, $y]);
                    $new = 1;
                }

                if ($new)
                {
                    next POP;
                }
            }
        }

        return;
    }
    return 1;
}

find();

my @start_p = @p;

foreach my $i (grep { $get->($_) } 0 .. $limit)
{
    print "Checking $i\n";

    my $neg = neg($i);

    if ($not_def->($neg))
    {
        @p = @start_p;

        $set->($neg, ['~', $i]);

        find();

        my @i_p = @p;

        foreach my $j (grep { $get->($_) } (0 .. $limit))
        {
            my $neg_j = neg($j);

            @p = @i_p;

            if ($not_def->($neg_j))
            {
                $set->($neg_j, ['~', $j]);

                if (find())
                {
                    foreach my $signal (qw(A B C))
                    {
                        my $n = neg($initial{$signal});
                        print "~$signal = ", disp($n), "\n";
                    }
                }
            }
        }
    }
}

sub disp
{
    my $n = shift;

    my $e = $p[$n];

    my $proto_ret = sub {
    if ($e->[0] eq "i")
    {
        return $e->[1];
    }
    elsif (($e->[0] eq "&") || ($e->[0] eq "|"))
    {
        return "(" . disp($e->[1]) . ")$e->[0](" . disp($e->[2]) . ")";
    }
    elsif ($e->[0] eq "~")
    {
        return "~(". disp($e->[1]) . ")";
    }
    else
    {
        die "Unknown e->[0] $e->[0]!";
    }
    }->();

    $proto_ret =~ s{\(([ABC])\)}{$1}g;
    $proto_ret =~ s{\(([ABC])&([ABC])\)}/
        join("",sort { $a cmp $b } ($1,$2))
        /eg;
    $proto_ret =~ s/\(([ABC]{2})\|\(([ABC]{2})\|([ABC]{2})\)\)/
        "(" . join("|", sort { $a cmp $b} ($1,$2,$3)) . ")"
        /eg;

    return $proto_ret;
}

=head1 COPYRIGHT & LICENSE

Copyright 2010 Shlomi Fish.

This program is released under the following license: MIT/X11
( L<http://www.opensource.org/licenses/mit-license.php> ).

=cut


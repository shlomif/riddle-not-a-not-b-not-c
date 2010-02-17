#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw(all);

my $limit = 0xFF;

# @p is the population of the positions.
my @p = (map { undef() } (0 .. $limit));

sub lim
{
    return (shift() & $limit);
}

my %initial;

my $A = $initial{A} = 0b11110000;
my $B = $initial{B} = 0b11001100;
my $C = $initial{C} = 0b10101010;

my $NOT_A = lim(~$A);
my $NOT_B = lim(~$B);
my $NOT_C = lim(~$C);

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
    my $found;
    POP:
    while (! ($found = all { $get->($_) } ($NOT_A, $NOT_B, $NOT_C)))
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

        last POP;
    }
    return $found;
}

find();

my @start_p = @p;

my @keys = (grep { $not_def->($_) } (0 .. $limit));

for my $k_i (0 .. $#keys-1)
{
    for my $k_j ($k_i+1 .. $#keys)
    {
        print "Checking $k_i and $k_j\n";

        @p = @start_p;

        $set->($keys[$k_i], ['i', 'k_i']);
        $set->($keys[$k_j], ['i', 'k_j']);

        if (find())
        {
            print sprintf("Found for 0b%.8b , 0b%.8b.\n", $keys[$k_i], $keys[$k_j]);
            exit(0);
        }

    }
}



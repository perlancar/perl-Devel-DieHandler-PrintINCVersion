package Devel::DieHandler::PrintINCVersion;

# DATE
# VERSION

use strict;
use warnings;

use ExtUtils::MakeMaker;

my @handler_stack;

sub import {
    my $pkg = shift;
    push @handler_stack, $SIG{__DIE__} if $SIG{__DIE__};
    $SIG{__DIE__} = sub {
        local $SIG{__DIE__};
        print "Versions of files in %INC:\n";
        for my $k (sort keys %INC) {
            my $path = $INC{$k};
            print "  $k ($path): ";
            if (-f $path) {
                my $v = MM->parse_version($path);
                print $v if defined $v;
            }
            print "\n";
        }
        if (@handler_stack) {
            goto &{$handler_stack[-1]};
        } else {
            die @_;
        }
    };
}

sub unimport {
    my $pkg = shift;
    if (@handler_stack) {
        $SIG{__DIE__} = pop(@handler_stack);
    }
}

1;
# ABSTRACT: Print versions of files (modules) listed in %INC

=head1 SYNOPSIS

 % perl -MDevel::DieHandler::PrintINCVersion -e'...'


=head1 DESCRIPTION

When imported, this module installs a C<__DIE__> handler which, upon the program
dying, will print the versions of files (modules) listed in C<%INC> to STDOUT.
The versions will be extracted using L<ExtUtils::MakeMaker>'s C<parse_version>.

Unimporting (via C<no Devel::DieHandler::PrintINCVersion>) after importing
restores the previous handler.

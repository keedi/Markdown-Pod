package Markdown::Pod::script;
# ABSTRACT: script to convert Markdown to POD

use strict;
use warnings;

use Encode qw( encodings decode );
use File::Slurp;
use Getopt::Long;
use List::Util qw( first );
use Markdown::Pod;

sub new {
    my $class = shift;

    bless {
        encoding => 'utf8',
        verbose  => undef,
        argv     => [],
        @_,
    }, $class;
}

sub doit {
    my $self = shift;

    if (my $action = $self->{action}) {
        $self->$action() and return 1;
    }

    $self->show_help(1)
        unless @{$self->{argv}} || $self->{load_from_stdin};

    if ($self->{encoding}) {
        my $found = first { $_ eq $self->{encoding} } Encode->encodings;
        if (!$found) {
            warn "cannot find such '$self->{encoding}' encoding\n";
            $self->show_help(1);
        }
    }

    my $m2p  = Markdown::Pod->new;

    if ( $self->{load_from_stdin} ) {
        my $markdown = read_file(\*STDIN);

        my $pod = $m2p->markdown_to_pod(
            encoding => $self->{encoding},
            markdown => $markdown,
        );
        print $self->{encoding} ? decode( $self->{encoding}, $pod ) : $pod;
    }

    for my $file ( @{$self->{argv}} ) {
        my $pod = $m2p->markdown_to_pod(
            encoding => $self->{encoding},
            markdown => scalar( read_file($file) ),
        );
        print $self->{encoding} ? decode( $self->{encoding}, $pod ) : $pod;
    }

    return 1;
}

sub env {
    my ($self, $key) = @_;

    return $ENV{"PERL_MARKDOWN2POD_" . $key} || q{};
}

sub parse_options {
    my $self = shift;

    local @ARGV = @{$self->{argv}};
    push @ARGV, split /\s+/, $self->env('OPT');
    push @ARGV, @_;

    Getopt::Long::Configure("bundling");
    Getopt::Long::GetOptions(
        'e|encoding=s' => sub { $self->{encoding} = $_[1] },
        'v|verbose'    => sub { $self->{verbose} = 1 },
        'h|help'       => sub { $self->{action}  = 'show_help' },
        'V|version'    => sub { $self->{action}  = 'show_version' },
    );

    if (@ARGV == 0 || !-t STDIN) {
        $self->{load_from_stdin} = 1;
    }

    $self->{argv} = \@ARGV;
}

sub show_help {
    my $self = shift;

    if ($_[0]) {
        die <<'USAGE';
Usage: markdown2pod [OPTIONS] <file1> [ <file2> ... ]

Try `markdown2pod --help` for details.
USAGE
    }

    print <<"HELP";
Usage: markdown2pod [OPTIONS] <file1> [ <file2> ... ]

OPTIONS:
    -e,--encoding       set markdown encoding
    -v,--verbose        print more information
    -h,--help           print this message
    -V,--version        display software version

HELP

    return 1;
}

sub show_version {
    print "markdown2pod (Markdown::Pod) version $Markdown::Pod::VERSION\n";
    return 1;
}

1;
__END__

=head1 SYNOPSIS

    my $app = Markdown::Pod::script->new;
    $app->parse_options(@ARGV);
    $app->doit or exit(1);


=head1 DESCRIPTION

This module contains script related functions.


=cut

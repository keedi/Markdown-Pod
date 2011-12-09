package Markdown::Pod;
# ABSTRACT: Convert Markdown to POD

use strict;
use warnings;

use Encode qw( encodings );
use List::Util qw( first );
use Markdent::Parser;
use Markdent::Types qw( Str );
use Markdown::Pod::Handler;
use Moose;
use MooseX::Params::Validate qw( validated_list );
use MooseX::StrictConstructor;
use namespace::autoclean;

sub markdown_to_pod {
    my $self = shift;
    my ( $dialect, $markdown, $encoding ) = validated_list(
        \@_,
        dialect  => { isa => Str, default => 'Standard' },
        markdown => { isa => Str },
        encoding => { isa => Str, default => q{}, optional => 1 },
    );

    my $capture = q{};
    open my $fh, '>', \$capture
        or die $!;

    if ($encoding) {
        my $found = first { $_ eq $encoding } Encode->encodings;
        if ($found) {
            binmode $fh, ":encoding($encoding)";
        }
        else {
            warn "cannot find such '$encoding' encoding\n";
        }
    }

    my $handler = Markdown::Pod::Handler->new(
        encoding => $encoding,
        output   => $fh,
    );

    my $parser = Markdent::Parser->new(
        dialect => $dialect,
        handler => $handler,
    );

    $parser->parse( markdown => $markdown );

    close $fh;

    $capture =~ s/\n+$/\n/;

    #
    # FIXME
    # dirty code to support blockquote
    #
    $capture =~ s{
        ^ =begin \s+ blockquote
        \s+
        (.*?)
        \s+
        ^ =end \s+ blockquote
    }{
        my $quoted = $1;
        $quoted =~ s/^/    /gsm;
        $quoted;
    }xgsme;

    return $capture;
}

__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 SYNOPSIS

    use Markdown::Pod;
    
    my $m2p = Markdown::Pod->new;
    my $pod = $m2p->markdown_to_pod(
        markdown => $markdown,
    );


=head1 DESCRIPTION

    use Markdown::Pod;
    
    my $m2p = Markdown::Pod->new;
    my $pod = $m2p->markdown_to_pod(
        markdown => $markdown,
    );

        markdown => { isa => Str },
        encoding => { isa => Str, default => q{}, optional => 1 },

...


=attr markdown

markdown text

=attr encoding

encoding to use

=method new

create Markdown::Pod object

=method markdown_to_pod

convert markdown text to POD text


=head1 SEE ALSO

=over

=item *

L<Markdent>

=item *

L<Pod::Markdown>

=item *

L<Text::MultiMarkdown>, L<Text::Markdown>

=back


=cut

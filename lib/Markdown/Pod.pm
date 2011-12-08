package Markdown::Pod;
# ABSTRACT: Convert Markdown to POD

use strict;
use warnings;

use Markdent::Parser;
use Markdent::Types qw( Str );
use Moose;
use MooseX::Params::Validate qw( validated_list );
use MooseX::StrictConstructor;
use namespace::autoclean;

use Markdown::Pod::Handler;

sub markdown_to_pod {
    my $self = shift;
    my ( $dialect, $title, $markdown, $encoding ) = validated_list(
        \@_,
        dialect  => { isa => Str, default => 'Standard' },
        title    => { isa => Str },
        markdown => { isa => Str },
        encoding => { isa => Str, default => q{}, optional => 1 },
    );

    my $capture = q{};
    open my $fh, '>', \$capture
        or die $!;

    if (PerlIO::Layer::->find($encoding, 1)) {
        binmode $fh, ":$encoding";
    }
    else {
        warn "cannot find such '$encoding' encoding\n";
    }

    my $handler = Markdown::Pod::Handler->new(
        title    => $title,
        encoding => $encoding,
        output   => $fh,
    );

    my $parser = Markdent::Parser->new(
        dialect => $dialect,
        handler => $handler,
    );

    $parser->parse( markdown => $markdown );

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

...


=attr foo

=attr ...

=method bar

=method ...


=head1 SEE ALSO


=cut

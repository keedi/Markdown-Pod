package Markdown::Pod::Handler;
# ABSTRACT: Parser module to convert from markdown to POD

use strict;
use warnings;

use Markdent::Types qw(
    Bool Str HashRef OutputStream HeaderLevel
);

use namespace::autoclean;
use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Params::Validate qw( validated_list validated_hash );

with 'Markdent::Role::EventsAsMethods';

has encoding => (
    is       => 'ro',
    isa      => Str,
    default  => q{},
);

has _output => (
    is       => 'ro',
    isa      => OutputStream,
    required => 1,
    init_arg => 'output',
);

my $link_buf;
my @blockquotes;
my @list_type;

sub _stream {
    my ( $self, @params ) = @_;
    print { $self->_output } @params;
}

sub start_document {
    my $self = shift;

    $self->_stream( '=encoding ' . $self->encoding . "\n\n" ) if $self->encoding;
}

sub end_document   { }

sub text {
    my $self = shift;
    my ($text) = validated_list( \@_, text => { isa => Str } );

    if ( $link_buf ) {
        $link_buf->{text} = $text;
    }
    else {
        $self->_stream( $text );
    }
}

sub start_header {
    my $self  = shift;
    my ($level) = validated_list(
        \@_,
        level => { isa => HeaderLevel },
    );

    $self->_stream("\n=head$level ");
}

sub end_header {
    my $self  = shift;
    my ($level) = validated_list(
        \@_,
        level => { isa => HeaderLevel },
    );

    $self->_stream( "\n" );
}

sub start_paragraph {
    my $self  = shift;
}

sub end_paragraph {
    my $self  = shift;

    $self->_stream("\n");
}

sub start_link {
    my $self = shift;
    my %p    = validated_hash(
        \@_,
        uri            => { isa => Str },
        title          => { isa => Str, optional => 1 },
        id             => { isa => Str, optional => 1 },
        is_implicit_id => { isa => Bool, optional => 1 },
    );

    delete @p{ grep { ! defined $p{$_} } keys %p };

    $link_buf->{uri} = $p{uri};
    $self->_stream('L<');
}

sub end_link {
    my $self = shift;

    if ($link_buf && $link_buf->{text}) {
        $self->_stream( "$link_buf->{text}|$link_buf->{uri}>" );
    }
    else {
        $self->_stream( "$link_buf->{uri}>" );
    }

    $link_buf = undef;
}

sub start_strong {
    my $self = shift;

    $self->_stream('B<');
}

sub end_strong {
    my $self = shift;

    $self->_stream('>');
}

sub start_emphasis {
    my $self = shift;

    $self->_stream('I<');
}

sub end_emphasis {
    my $self = shift;

    $self->_stream('>');
}

sub preformatted {
    my $self = shift;
    my ($text) = validated_list( \@_, text => { isa => Str }, );

    chomp $text;
    $text =~ s/^/    /gsm;
    $self->_stream( $text, "\n\n" );
}

sub start_blockquote {
    my $self  = shift;

    $self->_stream("=begin blockquote\n\n");
}

sub end_blockquote {
    my $self  = shift;

    $self->_stream("=end blockquote\n\n");
}

sub start_unordered_list {
    my $self = shift;

    $self->_stream("=over\n\n");
}

sub end_unordered_list {
    my $self = shift;

    $self->_stream("=back\n\n");
}

sub start_ordered_list {
    my $self = shift;

    $self->_stream("=over\n\n");
}

sub end_ordered_list {
    my $self = shift;

    $self->_stream("=back\n\n");
}

sub start_list_item {
    my $self = shift;
    my %p    = validated_hash(
        \@_,
        bullet => { isa => Str },
    );

    $self->_stream("=item $p{bullet}\n\n");
}

sub end_list_item {
    my $self = shift;

    $self->_stream("\n\n");
}

sub start_code {
    my $self = shift;

    $self->_stream('C<');
}

sub end_code {
    my $self = shift;

    $self->_stream('>');
}

sub image {
    my $self = shift;
    my %p    = validated_hash(
        \@_,
        alt_text       => { isa => Str },
        uri            => { isa => Str, optional => 1 },
        title          => { isa => Str, optional => 1 },
        id             => { isa => Str, optional => 1 },
        is_implicit_id => { isa => Bool, optional => 1 },
    );

    delete @p{ grep { ! defined $p{$_} } keys %p };

    my $alt_text = exists $p{alt_text} ? qq|alt="$p{alt_text}"| : q{};

    my $attr = exists $p{title} ? $p{title} : q{};
    my $attr_text = q{};
    while ($attr =~ s/(\S+)="(.*?)"//) {
        $attr_text .= qq{ $1="$2"};
    }
    while ($attr =~ /(\S+)=(\S+)/g) {
        $attr_text .= qq{ $1="$2"};
    }

    $self->_stream( qq|=for html <img src="$p{uri}" $alt_text$attr_text />| );
}

sub start_html_tag {
    my $self = shift;
    my ( $tag, $attributes ) = validated_list(
        \@_,
        tag        => { isa => Str },
        attributes => { isa => HashRef },
    );
}

sub end_html_tag {
    my $self = shift;
    my ( $tag, $attributes ) = validated_list(
        \@_,
        tag        => { isa => Str },
    );
}

sub html_tag {
    my $self = shift;
    my ( $tag, $attributes ) = validated_list(
        \@_,
        tag        => { isa => Str },
        attributes => { isa => HashRef },
    );

    my $attributes_str = q{};
    $attributes_str = join q{ }, map { qq|$_="$attributes->{$_}"| } sort keys %$attributes;
    if ( $tag =~ /^br$/i ) {
        $self->_stream( qq|<$tag $attributes_str />\n| );
    }
    else {
        $self->_stream( qq|<$tag $attributes_str />| );
    }
}

sub html_block {
    my $self = shift;
    my ($html) = validated_list( \@_, html => { isa => Str }, );

    chomp $html;
    $self->_output()->print(
            <<"END_HTML"

=begin html

$html

=end html

END_HTML
    );
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__

=head1 SYNOPSIS

    my $handler = Markdown::Pod::Handler->new(
        encoding => $encoding,
        output   => $fh,
    );
    
    my $parser = Markdent::Parser->new(
        dialect => $dialect,
        handler => $handler,
    );



=head1 DESCRIPTION

This module is a handler of L<Markdent> Markdown parser.
It converts Markdown to POD.


=attr markdown

markdown text

=attr encoding

encoding to use


=method new

create Markdown::Pod::Handler object

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

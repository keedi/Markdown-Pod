package Markdown::Pod;
# ABSTRACT: Convert Markdown to POD

use strict;
use warnings;

use Encode qw( encodings );
use List::Util qw( first );
use Scalar::Util qw(blessed);
use Markdent::Parser;
use Markdown::Pod::Handler;

sub new {
	my ($class, %args) = @_;
	my $self = {%args};
	return bless $self, $class;
}

sub Str { '' }
sub validated_list {
	my %args = @{shift()};

	my $callsub = (caller(0))[3];
	my $except = sub { require Carp; Carp::croak @_ };

	my @out;
	while (my ($param, $rule) = splice @_, 0, 2) {
		if (!exists $args{$param}) {
			if (exists $rule->{default}) {
				$args{$param} = $rule->{default};
			} elsif ($rule->{optional}) {
        push @out, $rule->{default} if exists $rule->{default};
      } else {
				$except->("missing required param to $callsub: $param");
			}
		}

		my $value = $args{$param};
		if (exists $rule->{isa}) {
			if ($rule->{isa} =~ /::/) {
				my $found = blessed($args{$param}) || ref($args{param});
				my $wanted = +{
					'' => 'Str',
				}->{$rule->{isa}} || $rule->{isa};
				$except->("param $param should be a $wanted not a $found")
					if $found ne $wanted;
			}
		}

		push @out, $args{$param};
	}
	return @out;
}

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

1;
__END__


=head1 SYNOPSIS

    use Markdown::Pod;

    my $m2p = Markdown::Pod->new;
    my $pod = $m2p->markdown_to_pod(
        markdown => $markdown,
    );


=head1 DESCRIPTION

This module parses Markdown text and return POD text.
It uses L<Markdent> module to parse Markdown.
Due to POD doesn't support blockquoted HTML tag,
so quoted text of Markdown will not be handled properly.
Quoted text will be converted to POD verbatim section.


=attr markdown

markdown text

=attr encoding

encoding to use. Available type of encoding is same as L<Encode> module.

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

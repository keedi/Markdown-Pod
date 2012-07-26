use strict;
use warnings;

use Test::More tests => 1;

use Encode qw( decode_utf8 );
use File::Slurp;
use Markdown::Pod;

my $file = 't/mkd/rt-77887-embed-html.mkd';

my $m2p = Markdown::Pod->new;
my $src = read_file(\*DATA);
my $dst = $m2p->markdown_to_pod(
    encoding => 'utf8',
    markdown => decode_utf8(read_file($file)),
);

$src =~ s/\s+\Z//gsm;
$dst =~ s/\s+\Z//gsm;

is $dst, $src, "converting $file";

__DATA__
=encoding utf8


=head2 NAME

Markdown::Pod - Convert Markdown to POD


=head2 VERSION

version 0.003


=head2 SYNOPSIS

    use Markdown::Pod;
    
    my $m2p = Markdown::Pod->new;
    my $pod = $m2p->markdown_to_pod(
        markdown => $markdown,
    );


=head2 DESCRIPTION


=begin html

<p>This module parses Markdown text and return POD text.</p>

=end html


=begin html

<div>
It uses Markdent module to parse Markdown.
Due to POD doesn't support blockquoted HTML tag,
</div>

=end html

so quoted text of Markdown will not be handled properly.
Quoted text will be converted to POD verbatim section.

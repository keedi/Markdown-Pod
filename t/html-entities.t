use strict;
use warnings;

use Test::More tests => 1;

use Encode qw( decode_utf8 );
use File::Slurp;
use Markdown::Pod;

my $file = 't/mkd/html-entities.mkd';

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

I ate fish E<amp> chips for lunch.

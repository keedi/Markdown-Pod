use strict;
use warnings;

use Test::More tests => 1;

use Encode qw( decode_utf8 );
use File::Slurp;
use Markdown::Pod;

my $file = 't/mkd/weird-ordered-lists.mkd';

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

=over

=item 1.

This should be understood as an ordered list.


=item 2.

The output numbers should increase, even though every written number is "1".


=item 3.

That's just how Markdown is!


=back

Here's a paragraph just to break things up.

=over

=item 1.

This should also be understood as an ordered list.


=item 2.

The numbers should increase, starting from 1, even though the written numbers are weird.


=item 3.

That's again just how Markdown is!


=back

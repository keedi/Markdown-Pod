use strict;
use warnings;

use Test::More tests => 1;

use Encode qw( decode_utf8 );
use File::Slurp;
use Markdown::Pod;

my $file = 't/mkd/rt-77889-ordered-list.mkd';

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


=head2 준비물

필요한 모듈은 다음과 같습니다.

=over

=item -

L<CPAN의 Win32::GuiTest 모듈|http://p3rl.org/Win32::GuiTest>


=item -

L<CPAN의 Win32::GuiTest::Examples 예제|http://p3rl.org/Win32::GuiTest::Examples>


=back

윈도우에서는 다음 명령을 이용해서 모듈을 설치합니다.

=over

=item 1.

cpan Win32::GuiTest


=item 2.

cpan Win32::GuiTest::Examples


=back

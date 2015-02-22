use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-03.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    소스코드 감쪽같이 숨기기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   aanoaa


=head2 저자

L<@aanoaa|http://twitter.com/#!/aanoaa> - Perl, 콧수염, 야구, 자전거, 낙타, 돌고래, 포청천 마니아.
아이유 열혈 삼촌팬. Perl과 Javascript, 안드로이드 어플리케이션 개발에 능하다.
Perl 코드 사용시 탭 문자 대신 4칸 공백을 사용한다.
일신 상의 이유로 Vim을 버리고 Emacs로 투신.
현재 L<콧수염 블로그|http://aanoaa.github.com/>를 운영하고 있다.


=head2 시작하며

Perl 코드를 실행할 수 있다는 것은 소스 코드도 읽을 수 있다는 것을 뜻합니다.
하지만 단 몇 줄의 Perl 코드로 여러분의 코드를 감쪽같이 숨길 수도 있습니다.


=head2 어떻게?

먼저 숨기고자 하는 문자열을 비트스트림으로 보고 C<'0'>과 C<'1'>로만 이루어진 문자열로 바꿉니다.
그런 다음, 이것을 다시 공백(C<" ">)과 탭(C<"\t">)으로만 이루어진 문자열로 바꿉니다.
그러면 여러분의 코드는 아무리 모니터를 뚫어지게 쳐다봐도, 백번 인쇄를 해도 읽어낼 수 없게 됩니다!
예를 들어 아래와 같은 내용이 주어졌다면,

    #!plain
    안녕하세요

먼저 이렇게 C<0>과 C<1>로만 이루어진 문자열로 바꿉니다.

    #!plain
    00110111101010010001000111010111101000011010100110110111101010010001100100110111001000010001110100110111010110010010100101010000

그리고 C<0>과 C<1>을 각각 공백과 탭 문자로 바꾸면 읽을 수도 없고 인쇄할 수는 문자열이 완성됩니다!

    #!plain
    "   	 				 	 	  	   	   			 	 				 	    		 	 	  		 		 				 	 	  	   		  	  		 			  	    	   			 	  		 			 	 		  	  	 	  	 	 	    "

보이지 않게 된 문자열을 큰 따옴표로 묶은 모습입니다.


=head2 만들어 봅시다!

먼저 Perl 내부로 읽어들인 문자열을 
L<unpack|http://perldoc.perl.org/functions/unpack.html> 함수를 사용하여 C<'0'>과 C<'1'>의 바이트 시퀀스로 변형합시다.

    #!perl
    my $text = <STDIN>;
    $text = unpack "b*", $text;

다음으로 C<'0'>은 C<' '>로, C<'1'>은 C<"\t">로 바꿉니다.

    #!perl
    $text =~ tr/01/ \t/;

이게 끝입니다!
전체 코드로 한번 볼까요?

    #!perl
    my $text = <STDIN>;
    $text = unpack "b*", $text;
    $text =~ tr/01/ \t/;
    print $text;

결과 화면은 다음과 같습니다.
C<"Hello Susan!">을 입력하면 빨간 박스에
표시한 부분만큼 공백이 출력된 것을 볼 수 있습니다.

=for html <img src="http://advent.perl.kr/2011/2011-12-03-1.png" alt="결과" />


=head2 정리하며

역순으로 실행하면 C<' '>와 C<"\t">로 이루어진 텍스트를
원상태로 복구할 수 있을 겁니다.
Perl을 사용하면 이렇게 간단하게 문자열을 조작할 수 있습니다.
문서와 명령행 옵션이 깔끔하게 포함된
L<s3cr3t 전체 소스코드|https://gist.github.com/1408846>도 꼭 확인해보세요.


=head2 참고문서

=over

=item -

L<CPAN의 Acme::Bleach 모듈|https://metacpan.org/module/Acme::Bleach>


=item -

L<s3cr3t gist|https://gist.github.com/1408846>


=item -

L<gypark님의 위키|http://gypark.pe.kr/wiki/Perl/Pack#H_1_7_2>


=item -

L<perldoc pack|http://perldoc.perl.org/functions/pack.html>


=item -

L<perldoc unpack|http://perldoc.perl.org/functions/unpack.html>


=back


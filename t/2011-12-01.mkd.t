use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-01.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    네모 반듯한 표 그리고 한글
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   keedi


=head2 저자

L<@keedi|http://twitter.com/#!/keedi> - Seoul.pm 리더, Perl덕후,
L<거침없이 배우는 펄|http://www.yes24.com/24/goods/4433208>의 공동 역자, keedi.k I<at> gmail.com


=head2 시작하며

화려한 UI를 가진 응용 프로그램과 웹페이지가 가득한 21세기라 하더라도
터미널에서 작업을 하는 사람은 여전히 많습니다.
비단 프로그래머 뿐만 아니라 서버 관리자는 물론, 대용량 자료 처리를 위해
*nix 머신에 접속해서 여러가지 프로세스를 돌려 결과 뽑아내야하는
생명정보학 연구원 역시 21세기인 지금까지도 터미널을 즐겨 쓰는 사람들입니다.

터미널의 특성상 표현할 수 있는 문자가 제한된 만큼 화려한 효과를
보여줄 수는 없지만 하지만 이 와중에도 L<ASCII 아트|http://en.wikipedia.org/wiki/Ascii_art>처럼
제한된 문자를 이용해서 터미널에서의 표현력을 높이려는 시도는
항상 있었습니다.

    #!plain
    THERE'S MORE THAN ONE WAY TO DO ME
               _                      
           .--' |                     
          /___^ |     .--.            
              ) |    /    \           
             /  |  /`      '.         
            |   '-'    /     \        
            \         |      |\       
             \    /   \      /\|      
              \  /'----`\   /         
              |||       \\ |          
              ((|        ((|          
              |||        |||          
       jgs   //_(       //_(          

아마도 검은색 화면에 흰색(또는 녹색!)의 글자가 만들어내는 정갈한
화면에 매료된 적이 있다면 아마도 당신은 해커일 확률이 높겠지요. :-)

예술(?)은 잠시 접어두고 일 이야기를 해볼까요?
터미널을 즐겨 쓰는 사람들은 자신이 작업하고 있는 결과물 역시
터미널에서 확인해야 할 경우가 많습니다.
또 그것이 간편해서 선호하기도 하구요.
엄청나게 많은 내용이라 사람이 보기 위한 자료가 아닐 수도 있지만
때로는 한 두 페이지 내외의 눈으로 확인해야 할 자료도 있습니다.
지금부터 살펴볼 내용은 바로 여러분이 눈으로 확인하려는 자료입니다.


=head2 준비물

필요한 모듈은 다음과 같습니다.

=over

=item -

L<CPAN의 Text::ASCIITable 모듈|https://metacpan.org/module/Text::ASCIITable>


=item -

L<CPAN의 Text::CharWidth 모듈|https://metacpan.org/module/Text::CharWidth>


=item -

L<CPAN의 Text::WrapI18N 모듈|https://metacpan.org/module/Text::WrapI18N>


=back

데비안 계열의 리눅스를 사용하고 있다면 다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ sudo apt-get install libtext-asciitable-perl libtext-charwidth-perl

직접 L<CPAN|http://www.cpan.org/>을 이용해서 설치한다면 다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ sudo cpan Text::ASCIITable Text::CharWidth

사용자 계정으로 모듈을 설치하는 방법을 정확하게 알고 있거나
C<perlbrew>를 이용해서 자신만의 Perl을 사용하고 있다면
다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ cpan Text::ASCIITable Text::CharWidth


=head2 네모 반듯한 표

L<카탈리스트(Catalyst)|http://www.catalystframework.org/>를 사용해본 적이 있다면 실행 후
기본적으로 터미널에 출력하는 디버그 로그에 포함된 네모 반듯한 표가
가독성을 얼마나 높여주는지 기억할 것입니다.

L<![카탈리스트 디버그 로그][img-01]|2011-12-01-1.png>

사용자 관리를 예로 들어볼까요?
표현해야 할 자료가 다음과 같은 항목을 가진다고 가정해보죠.

=over

=item -

이름


=item -

별명


=item -

전자우편


=item -

홈페이지


=back

일반적으로 이런 값을 출력하는 가장 간단한 방법은 각각의 항목 이름과
값을 묶어서 쉼표 등의 구분자를 이용해서 출력하는 것입니다.

    #!perl
    printf(
        "id(%s), name(%s), nick(%s), email(%s), homepage(%s)\n",
        $user->{id},
        $user->{name},
        $user->{nick},
        $user->{email},
        $user->{homepage},
    );

반목문과 앞의 코드를 이용하면 출력 결과는 이런 형태일 것입니다.

    #!plain
    id(2), name(Inkyung Park), nick(practal78), email(practal78@gmail.com), homepage()
    id(3), name(Hanyoung Cho), nick(rumidier), email(rumidier@naver.com), homepage()
    id(4), name(Hyoungsuk Hong), nick(aanoaa), email(aanoaa@gmail.com), homepage(http://twitter.com/aanoaa)
    id(5), name(Keedi Kim), nick(keedi), email(keedi.k@gmail.com), homepage()
    id(6), name(Yongbin Yu), nick(yongbin), email(supermania@gmail.com), homepage()

원하는 값은 모두 보이지만 한 눈에 들어오지는 않습니다.
바로 지금이 표를 써야할 시점입니다. :-)
CPAN에는 다양한 종류의 테이블 모듈이 있지만 이번에는
L<CPAN의 Text::ASCIITable 모듈|https://metacpan.org/module/Text::ASCIITable>을 사용하기로 합니다.
다음은 모듈을 사용해서 앞에서 보았던 자료를 네모난 표에 담는 간단한 예제입니다.

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    use Text::ASCIITable;
    
    my $table = Text::ASCIITable->new({
        headingText => 'People',
    });
    $table->setCols(qw/ id name nick email homepage /);
    
    my @users = (
        {
            id       => '1',
            name     => 'Keedi Kim',
            nick     => 'keedi',
            email    => 'keedi.k@gmail.com',
            homepage => 'http://twitter.com/keedi',
        },
        {
            id       => '2',
            name     => 'Inkyung Park',
            nick     => 'practal78',
            email    => 'practal78@gmail.com',
            homepage => 'http://twitter.com/practal78',
        },
        {
            id       => '3',
            name     => 'Hanyoung Cho',
            nick     => 'rumidier',
            email    => 'rumidier@naver.com',
            homepage => 'http://twitter.com/rumidier',
        },
        {
            id       => '4',
            name     => 'Hyoungsuk Hong',
            nick     => 'aanoaa',
            email    => 'aanoaa@gmail.com',
            homepage => 'http://twitter.com/aanoaa',
        },
        {
            id       => '5',
            name     => 'Yongbin Yu',
            nick     => 'yongbin',
            email    => 'supermania@gmail.com',
            homepage => 'http://twitter.com/y0ngbin',
        },
    );
    
    for my $user ( @users ) {
        $table->addRow(
            $user->{id},
            $user->{name},
            $user->{nick},
            $user->{email},
            $user->{homepage},
        );
    }
    
    print $table;

실행 결과는 다음과 같습니다.

L<![네모 반듯한 표][img-02]|2011-12-01-2.png>

아름답군요! ;-)


=head2 어이쿠! 표가 깨져요!

영어권 사람이라면 평생동안 단 한번도 겪기 힘든 문제지만, 한국, 중국, 일본처럼
고유의 언어와 문자를 사용하고 있는 우리는 항상 겪는 문제입니다. 
컴퓨터란 것이 태초부터 멀티바이트 문자를 고려하지 않고 세상에 태어난 만큼
많이 좋아졌다고는 하지만 특히 터미널에서라면 항상 겪는 것이 인코딩 문제입니다.
인코딩 문제를 해결하는 가장 간단하면서도 명확한 방법은
사용하는 모든 자료를 UTF-8 형식으로 인코딩 및 디코딩 하는 것입니다.
물론 여러분의 터미널 역시 UTF-8 형식으로 인코딩해서 보이도록 설정하는 것은 기본이겠죠?
다행히 현대의 리눅스 시스템은 거의 대부분 UTF-8 인코딩을 기본 설정으로 사용하고 있습니다.

지금 우리가 맞닥뜨릴 문제는 한글 깨짐 현상과는 조금 다른 바로 표 깨짐 현상입니다.

L<![세로 줄이 맞지 않는 표][img-03]|2011-12-01-3.png>

아휴! 이름을 한글로 바꿨을 뿐인데, 표의 세로 줄이 깨져 버려서 엉망이 되었습니다.
이것은 엄밀히 말해서 우리가 잘못했다기 보다는 C<Text::ASCIITable> 모듈의 저자가
미처 고려하지 못한 부분입니다.
간단하게 설명하면 UTF-8 인코딩을 사용하는 환경에서 한글 한 글자는 3바이트를 크기를
가지는데 실제로 터미널의 화면에서는 2칸의 너비를 사용하기 때문에 생기는 문제입니다.
대부분의 사람은 터미널에서 해당 문자열의 길이를 파악할 때 글자의 바이트 수를 이용해서
터미널에서 몇 열을 사용하는지 계산합니다만, 불행히도 2바이트를 사용하는 CP949(EUC-KR)
인코딩과는 달리 UTF-8 인코딩은 3바이트를 사용하기 때문에 한글 한 글자마다 3칸을
차지한다고 고려해서 결국 앞의 예제에서는 3개의 공백이 더 들어가게 됩니다.

이 문제를 해결하기 위한 패치는 다음과 같습니다.

    #!diff
    --- a/table.pl    2011-12-01 03:09:31.768703000 +0900
    +++ b/table.pl    2011-12-01 03:35:59.616703000 +0900
    @@ -4,16 +4,18 @@
     use strict;
     use warnings;
     use Text::ASCIITable;
    +use Text::CharWidth qw( mbswidth );
     
     my $table = Text::ASCIITable->new({
         headingText => 'People',
    +    cb_count    => sub { mbswidth(shift) }, 
     });
     $table->setCols(qw/ id name nick email homepage /);
     
     my @users = (
         {
             id       => '1',
    -        name     => 'Keedi Kim',
    +        name     => '김도형',
             nick     => 'keedi',
             email    => 'keedi.k@gmail.com',
             homepage => 'http://twitter.com/keedi',

C<Text::ASCIITable> 모듈은 C<cb_count> 속성을 지원하는데 이 기능을 이용하면
기본적으로 모듈이 사용하는 글자 계수기 대신 사용자가 원하는 콜백 함수를
실행시켜 상황에 맞게 글자 수를 셀 수 있습니다.
L<CPAN의 Text::CharWidth 모듈|https://metacpan.org/module/Text::CharWidth>은 C<mbswidth> 함수를
제공하는데 이 함수를 이용하면 CJK 문자가 터미널에서 갖는 실제 너비를
알 수 있습니다.
즉 C<cb_count> 속성에 할당할 콜백 함수에서 C<mbswidth> 함수를 사용해서
너비를 계산한 값을 반환한다면 정확히 우리가 원하는 결과가 나옵니다.

패치를 적용하고 난 뒤 실행 결과는 다음과 같습니다.

L<![한글 줄맞춤 패치를 적용한 표][img-04]|2011-12-01-4.png>

네, 한글을 표로 넣는 일도 이젠 문제 없습니다!


=head2 어라? 줄바꿈이 어색해요

내친 김에 이번에는 음반을 관리해볼까요?

L<![음반 관리 표][img-05]|2011-12-01-5.png>

한글도 그렇고 큰 문제없이 깔끔하게 출력됩니다.
그런데 가사 부분이 조금은 어색해 보입니다.
사실 영어권 문자의 경우 단어가 끝나기 전에 줄바꿈이 될 경우 가독성이
무척 떨어지기 때문에 보통 띄어쓰기 단위로 줄바꿈을 수행하지만
한글은 단어 중간에 다음 줄로 끊기더라도 가독성이 크게 떨어지지 않습니다.
오히려 띄어쓰기 단위로 줄바꿈을 하는 것이 더 어색할 수도 있습니다.

이 문제를 해결하기 위한 패치는 다음과 같습니다.

    #!diff
    --- table-hangul-wrap.pl    2011-12-01 04:01:48.832702999 +0900
    +++ table-hangul-wrap.pl    2011-12-01 04:01:41.872703000 +0900
    @@ -6,6 +6,37 @@
     use Text::ASCIITable;
     use Text::CharWidth qw( mbswidth );
     
    +BEGIN {
    +    use Text::WrapI18N;
    +    no warnings 'redefine';
    +
    +    sub Text::WrapI18N::_isCJ {
    +        my $u = shift;
    +
    +        if ($u >= 0x3000 && $u <= 0x312f) {
    +            if ($u == 0x300a || $u == 0x300c || $u == 0x300e ||
    +                $u == 0x3010 || $u == 0x3014 || $u == 0x3016 ||
    +                $u == 0x3018 || $u == 0x301a) {return 0;}
    +            return 1;
    +        }  # CJK punctuations, Hiragana, Katakana, Bopomofo
    +        if ( 0x31a   <= $u && $u <= 0x31bf  ) { return 1; } # Bopomofo
    +        if ( 0x31f0  <= $u && $u <= 0x31ff  ) { return 1; } # Katakana extension
    +        if ( 0x3400  <= $u && $u <= 0x9fff  ) { return 1; } # Han Ideogram
    +        if ( 0xf900  <= $u && $u <= 0xfaff  ) { return 1; } # Han Ideogram
    +        if ( 0x20000 <= $u && $u <= 0x2ffff ) { return 1; } # Han Ideogram
    +        if ( 0xAC00  <= $u && $u <= 0xD7AF  ) { return 1; } # Hangul
    +
    +        return 0;
    +    }
    +
    +    sub Text::ASCIITable::wrap {
    +        my ( $text, $width, $nostrict ) = @_;
    +
    +        $Text::WrapI18N::columns = $width;
    +        return Text::WrapI18N::wrap('', '', $text);
    +    }
    +}
    +
     my $table = Text::ASCIITable->new({
         headingText => 'Music',
         cb_count    => sub { mbswidth(shift) }, 

Perl에 익숙하지 않다면 이번 패치는 조금 복잡하게 느껴질 수도 있을 것입니다.
한글에 띄어쓰기 단위가 아니라 글자 단위의 줄바꿈 기능을 추가하기 위해서
다음 두 개의 함수를 오버라이딩 합니다.

=over

=item -

C<Text::WrapI18N> 모듈의 C<_isCJ> 함수


=item -

C<Text::ASCIITable> 모듈의 C<wrap> 함수


=back

C<Text::ASCIITable> 모듈은 C<cb_count> 속성을 제공해서 사용자가 원하는
스타일로 글자의 개수를 셀 수는 있지만 줄바꿈과 관련해서는 공식적으로
사용자가 제어할 수 있는 방법이 없습니다.
그래서 해당 모듈을 사용하는 응용 프로그램 또는 라이브러리 측에서
강제로 오버라이딩 하는 방법을 택해서 문제를 해결합니다.
또한 줄바꿈과 관련해서는
L<CPAN의 Text::WrapI18N 모듈|https://metacpan.org/module/Text::WrapI18N>을 사용합니다.
이 모듈은 일반적으로 많이 사용하는
L<CPAN의 Text::Wrap 모듈|https://metacpan.org/module/Text::Wrap>과 거의 유사하지만
CJK 문자에 대해서 바이트 단위가 아니라 실제 너비를 고려해서
줄바꿈을 수행하도록 도와줍니다.
다만 이 모듈은 한국어를 고려하고 있지 않기 때문에
한국어 유니코드에 해당하는 범위에 대해서도 동작하도록
C<_isCJ> 함수를 오버라이딩 합니다.

패치를 적용하고 난 후의 출력 화면입니다.

L<![줄바꿈 패치를 적용한 후 음반 관리 표][img-06]|2011-12-01-6.png>

완전한 예제 스크립트는 다음과 같습니다.

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    use Text::ASCIITable;
    use Text::CharWidth qw( mbswidth );
    
    BEGIN {
        use Text::WrapI18N;
        no warnings 'redefine';
    
        sub Text::WrapI18N::_isCJ {
            my $u = shift;
    
            if ($u >= 0x3000 && $u <= 0x312f) {
                if ($u == 0x300a || $u == 0x300c || $u == 0x300e ||
                    $u == 0x3010 || $u == 0x3014 || $u == 0x3016 ||
                    $u == 0x3018 || $u == 0x301a) {return 0;}
                return 1;
            }  # CJK punctuations, Hiragana, Katakana, Bopomofo
            if ( 0x31a   <= $u && $u <= 0x31bf  ) { return 1; } # Bopomofo
            if ( 0x31f0  <= $u && $u <= 0x31ff  ) { return 1; } # Katakana extension
            if ( 0x3400  <= $u && $u <= 0x9fff  ) { return 1; } # Han Ideogram
            if ( 0xf900  <= $u && $u <= 0xfaff  ) { return 1; } # Han Ideogram
            if ( 0x20000 <= $u && $u <= 0x2ffff ) { return 1; } # Han Ideogram
            if ( 0xAC00  <= $u && $u <= 0xD7AF  ) { return 1; } # Hangul
    
            return 0;
        }
    
        sub Text::ASCIITable::wrap {
            my ( $text, $width, $nostrict ) = @_;
    
            $Text::WrapI18N::columns = $width;
            return Text::WrapI18N::wrap('', '', $text);
        }
    }
    
    my $table = Text::ASCIITable->new({
        headingText => 'Music',
        cb_count    => sub { mbswidth(shift) }, 
    });
    $table->setCols(qw/ artist name lyrics /);
    $table->setColWidth( 'lyrics', 40 );
    
    my @songs = (
        {
            artist   => '옐로우 몬스터즈',
            name     => 'Metal Gear',
            lyrics   => 
                  '언제부턴가 모두 똑같아 '
                . '음악보다 말발의 멜로디를 '
                . '노래하고 춤추고 옷을 벗고 '
                . '가요 판 강타하려 기웃거려 '
                . '누가 월드 스타? 아무도 널 몰라. '
                . '아무도 널 몰라! 아무도 널 몰라 몰라!! '
                . '언제부턴가 모두 얼굴이 똑같아졌어 '
                . '언제부턴가 모두 모두 똑같아 '
                . '언제부턴가 모두 똑같아'
                ,
        },
        {
            artist   => '델리스파이스',
            name     => '두 눈을 감은 타조처럼',
            lyrics   => 
                  '아주 오래 전 옛날 커다란 홍수 속에서 '
                . '사자들이 떠난후에 살아남은 여우들만이 '
                . '두 눈을 감아 당신 앞에 큰 위험이 '
                . '머릴 박아 땅속에 마치 타조처럼 '
                . '모두가 알아야만해 당신앞에 서 있는 건 '
                . '사자가 아닌 여우인걸 이제 필요한건 '
                . '모두 나가 여우사냥을 해야 해'
                ,
        },
    );
    
    for my $song ( @songs ) {
        $table->addRow(
            $song->{artist},
            $song->{name},
            $song->{lyrics},
        );
    }
    
    print $table;


=head2 정리하며

반짝이고 화려한 인터넷 브라우저 화면에 비하면 텍스트 기반의
터미널 화면은 그야말로 초라하기 짝이 없습니다.
터미널을 기피하고, 키보드 보다는 마우스를 사용하는 것이
익숙한 사람이 더 많아지는 것도 어쩌면 당연한 시대입니다.
그럼에도 불구하고 터미널을 좋아하는 사람(아마도 여러분?)은 여전히 적지 않습니다.
일상적인 작업 뿐만 아니라 대량의 자료를 생성해내기 직전 점검을 해야할 때,
프로그램의 로그로써 사람이 읽기 쉬운 자료로 보여주어야 할 경우
표로 도식화 하는 것은 훌륭한 선택입니다.
하지만 터미널에서 ASCII 문자를 이용해서 일일이 그리는 일은
고통스러운 일입니다.
자료 처리에 탁월한 Perl과 너무도 간단하게 표를 그릴 수 있게
도와주는 CPAN 모듈, 그리고 한글을 위한 약간의 기교를 이용하면
여러분의 터미널을 이쁘게 꾸미는 것은 정말 즐거운 일이 될 것입니다.

텍스트를 사랑하는 덕ㅎ... 아니, 해커 여러분에게 바칩니다.

Enjoy Your Perl! ;-)


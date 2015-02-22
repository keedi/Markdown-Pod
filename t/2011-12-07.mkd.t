use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-07.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    윈도우 환경에서 화면 캡쳐 후 자동 저장 기능의 구현
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   owl0908


=head2 저자

@owl0908 - 
Perl과는 그닥 어울릴 것 같아보이지 않는, 법학을 전공한 고시 준비생.
10여년 전 개인 홈페이지를 Perl로 구현한 것이 계기가 되어,
슬럼프가 올 때마다 하라는 공부는 안하고 Perl 코딩을 한 결과,
이제는 자신의 정체성의 혼란을 겪고 있다(물론 실력과는 전혀 관계가 없다).
L<부엉이의 나무구멍 속 작은 공간|http://www.dormouse.pe.kr> 블로그를 운영하고 있다.
webmaster I<at> dormouse.pe.kr


=head2 시작하며

이것저것 스크린샷이 포함된 글을 쓰실 때, 대개 어떻게 하시나요?
C<Shift + PrtSc> 키를 이용하면 현재 화면을 쉽게 클립보드에 저장할 수 있습니다.
이렇게 클립보드로 저장된 이미지는 어디서든 C<Ctrl-V> 로 붙여넣기를 할 수 있죠.
그러나, 스크린샷이 파일 형태로 필요하다면 어떨까요?
이미지 편집 프로그램을 실행시킨 다음, 붙여넣기를 한 후, 저장을 해야 합니다.
서너장이 아니라 수십 수백장의 화면을 갈무리해야 한다면
일일이 이렇게 저장하는 것은 너무 힘든 일입니다.
스크린샷을 찍으면 자동으로 알아서 파일로 저장까지 해주면 딱 좋을 것 같지 않나요?
자, 시작해보죠. :-)


=head2 준비물

우선 현재 화면을 갈무리해서, 그것을 특정 파일로 저장하는 기능을 구현해야 합니다.
윈도우즈는 기본적으로 C<Shift + PrtSc> 키를 입력하면 전체화면을 갈무리해서 클립보드에 저장합니다.
이 기능을 이용한다고 했을때 고민해야할 부분은 다음과 같습니다.

=over

=item -

어떤 행위를 했을때 화면을 갈무리 할 것인지 결정


=item -

결정된 행위가 이루어졌을 경우 C<Shift + PrtSc> 키가 입력된 것처럼 동작


=item -

클립보드의 내용을 읽어와서 파일로 저장


=back

인터페이스 디자인에 해당하는 부분으로 어떤 식으로 컴퓨터에게 명령을 내릴지 정해야 합니다.
스크린샷을 찍을 때마다 스크립트를 실행하는 방법은 불편할 것 같습니다.
가능한 간편하게 사용할 수 있으며 눈에 띄지않을 방법을 생각해보니
시스템 트레이에 아이콘을 상주시켜 놓고 이 아이콘을 클릭할 때마다
화면을 갈무리하는 것이 꽤나 그럴듯해 보입니다.
(믿기 어렵겠지만, 시스템 트레이 아이콘을 이용하는 것은
꽤나 있어보이는 것에 비해 너무 간단합니다. :)

필요한 모듈은 다음과 같습니다.

=over

=item -

L<CPAN의 Win32::GUI 모듈|https://metacpan.org/module/Win32::GUI>


=item -

L<CPAN의 Win32::GuiTest 모듈|https://metacpan.org/module/Win32::GuiTest>


=item -

L<CPAN의 Win32::HideConsole 모듈|https://metacpan.org/module/Win32::HideConsole>


=item -

L<CPAN의 Win32::Clipboard 모듈|https://metacpan.org/module/Win32::Clipboard>


=item -

L<CPAN의 DateTime 모듈|https://metacpan.org/module/DateTime>


=item -

L<CPAN의 File::Slurp 모듈|https://metacpan.org/module/File::Slurp>


=back

L<딸기펄|http://strawberryperl.com>을 사용한다면 콘솔에서 C<cpan> 명령을 이용해서 설치합니다.
L<딸기펄 5.14|http://strawberryperl.com/beta/index.html> 버전에서 필요한 모든 모듈이 정상적으로
설치되는 것을 확인했으므로 버전 선택시 참고하시길 바랍니다.

    #!bash
    > cpan Win32::GUI
    > cpan Win32::GuiTest
    > cpan Win32::HideConsole
    > cpan Win32::Clipboard
    > cpan DateTime
    > cpan File::Slurp

L<ActiveState사의 ActivePerl|http://www.activestate.com/activeperl>을 사용한다면 PPM 관리자를 이용해서 설치하면 됩니다.


=head2 뼈대 만들기

GUI 구성은 윈도우즈 네이티브 UI 라이브러리인 C<Win32::GUI> 모듈을 사용합니다.
윈도우즈의 시스템 트레이에 아이콘을 상주시키는 것은 C<Win32::GUI> 모듈이 제공하는
C<AddNotifyIcon> 메소드를 사용하면 간단하게 구현할 수 있습니다.
기본적인 뼈대 코드는 다음과 같습니다.

    #!perl
    #!/usr/bin/env perl
    
    use strict;
    use warnings;
    
    use Win32::GUI ();
    
    # 사용할 아이콘을 정의합니다.
    my $icon = Win32::GUI::Icon->new('icon.ico');
    
    # 기본으로 사용할 창을 정의합니다.
    my $main = Win32::GUI::Window->new(
        -name => 'Main',
        -size => [ 1, 1 ],
    );
    
    # 시스템 트레이 아이콘을 정의합니다.
    $main->AddNotifyIcon(
        -name    => "NI",
        -icon    => $icon,
        -tip     => "Click to Screenshot!",
        -balloon => 0,
        -onClick => sub {
            # 스크린샷을 찍는 부분을 구현할 예정입니다.
            return 0;
        },
        -onRightClick => sub {
            # 트레이에 좀비 아이콘이 그냥 남아있는 것을 방지합니다.
            $main->NI->Remove;
    
            # 프로그램 종료
            return -1;
        },
    );
    
    # 창을 숨깁니다.
    $main->Hide;
    
    # GUI 메인 루프에 진입합니다.
    Win32::GUI::Dialog;

작성한 스크립트가 있는 디렉터리와 동일한 위치에 마음에 드는 아이콘을 구한 뒤
C<icon.ico>로 이름을 바꿔서 저장한 후 스크립트를 실행하면
시스템 트레이에 아이콘이 나타나는 것을 볼 수 있습니다.
아이콘에 마우스를 가져가면 C<Click to Screenshot!>이라는 툴팁이 표시될 것입니다.
아이콘 위에서 마우스 왼쪽 버튼을 누르면 C<onClick> 이벤트가 발생하며
오른쪽 버튼을 누르면 C<onRightClick> 이벤트가 발생합니다.
오른쪽 버튼을 누를 경우 연결된 함수 레퍼런스가 C<-1>을 반환하므로 프로그램이 종료됩니다.

I<그림 1.> 실행 후 시스템 트레이에 아이콘이 적재된 화면 L<(원본)|2011-12-07-1.png>
=for html <img src="2011-12-07-1.png" alt="실행 후 시스템 트레이에 아이콘이 적재된 화면" width="700" />

이제 스크린샷을 찍을 부분을 구현해야겠죠.
C<PrtSc> 명령은 L<CPAN의 Win32::GuiTest 모듈|https://metacpan.org/module/Win32::GuiTest>의 C<SendKeys> 함수를 이용하면 됩니다.
C<SendKeys> 함수는 문자 그대로 특정한 키 입력을 컴퓨터에게 던져주는 역할을 합니다.
C<onClick> 이벤트 발생시 실행시키는 함수 레퍼런스에 다음 내용을 추가합니다.

    #!perl
    ...
    
    use Win32::GUI ();
    use Win32::GuiTest qw(SendKeys); # 추가된 부분
    
    ...
    
    $main->AddNotifyIcon(
        -name    => "NI",
        -icon    => $icon,
        -tip     => "Click to Screenshot!",
        -balloon => 0,
        -onClick => sub {
            # 스크린샷을 찍습니다.
            SendKeys( "+{PRTSCR}" ); # 추가된 부분
            return 0;
        },
        ...
    );

C<{PRTSCR}> 앞의 C<+>는 C<Shift>를 같이 입력한다는 의미입니다.
참고로 C<^>은 C<Ctrl>, C<%>는 C<Alt>를 의미합니다.
여러 키 조합과 딜레이 타임을 옵션으로 지정할 수도 있기 때문에,
C<SendKeys>와 C<Win32::GUI> 모듈의 타이머 기능을 결합하면 여러가지로 활용이 가능합니다.
예를 들자면, 특정 온라인 게임에 대응하는 매크로도 만들 수 있겠죠. ;-)


=head2 클립보드 이미지를 파일로 저장

이제 클립보드로 들어간 이미지를 저장해야겠죠?
L<CPAN의 Win32::Clipboard 모듈|https://metacpan.org/module/Win32::Clipboard>을 사용하면
간편하게 클립보드 이미지를 불러올 수 있습니다.
불러오고 싶다면 다음처럼 단 두 줄만 작성하면 됩니다.

    #!perl
    use Win32::Clipboard;
    my $bitmap = Win32::Clipboard::GetBitmap;

정말 끝내주지 않나요? :-D

클립보드에 저장된 비트맵을 불러오는 것이므로 클립보드에 있는 것이
이미지인지 텍스트인지 확인할 필요도 없을 것 같습니다.
C<$bitmap> 스칼라 변수에 비트맵 이미지가 고스란히 저장되기 때문에
C<.bmp> 파일에 써주기만 하면 파일 저장도 끝납니다.
파일명을 일일이 사용자에게 물어보는 것도 번거로운 일이니까
현재 날짜과 시간을 사용해서 자동으로 저장하도록 하겠습니다.
C<onClick> 이벤트에 대한 함수 레퍼런스는 이렇게 바뀝니다.

    #!perl
    ...
    
    use Win32::GUI ();
    use Win32::GuiTest qw(SendKeys);
    use Win32::Clipboard;
    use DateTime;
    use File::Slurp
    
    ...
    
    $main->AddNotifyIcon(
        -name    => "NI",
        -icon    => $icon,
        -tip     => "Click to Screenshot!",
        -balloon => 0,
        -onClick => sub {
            # 스크린샷을 찍습니다.
            SendKeys( "+{PRTSCR}" );
    
            # 스크린샷을 저장합니다.
            my $dt       = DateTime->now( time_zone => 'Asia/Seoul' );
            my $filename = sprintf('%s %s.bmp', $dt->ymd, $dt->hms);
            my $bitmap   = Win32::Clipboard::GetBitmap;
    
            write_file( $filename, {binmode => ':raw'}, $bitmap ) ;
    
            return 0;
        },
        ...
    );

I<그림 2.> 화면 갈무리 결과 L<(원본)|2011-12-07-2.png>
=for html <img src="2011-12-07-2.png" alt="화면 갈무리 결과" width="700" />


=head2 용량 줄이기

일단 프로그램 작성은 끝났습니다.
다만 실행해보면 갈무리되는 파일의 크기가 무척 크다는 것을 알 수 있습니다.
비트맵 형식은 압축을 하지 않기 때문에 일반적인 HD 해상도의 파일은 약 3MB,
그리고 그 이상의 해상도의 화면을 사용한다면 5MB는 가볍게 훌쩍 넘깁니다.
본격적으로 대량 캡쳐를 하려고 생각했는데, 이러면 좀 곤란하겠죠.
BMP 대신 PNG 파일 포맷을 사용해서 용량 문제를 해결하도록 하겠습니다.

BMP를 PNG로 변환하는 방법은 다양합니다.
CPAN의 L<GD 모듈|https://metacpan.org/module/GD>, L<Image::Magick|https://metacpan.org/module/Image::Magick>,
L<Imager|https://metacpan.org/module/Imager>는 물론이고 C<Win32::GUI> 모듈에 딸려 나오는
[Win32::GUI::DIBitmap][cpan-win32-gui-dbbitmap] 모듈을 사용하는 등
여러가지 방법이 있습니다.
다만 각각의 모듈은 모두 윈도우즈에 소소한 문제들이 있습니다.
C<GD> 모듈의 경우 BMP 포맷을 지원하지 않으며,
C<Image::Magick>는 따로 바이너리 라이브러리를 설치한 후 CPAN 모듈을
설치해야 하므로 초보자의 경우 접근이 어렵습니다.
또한 C<Imager>는 BMP를 지원하지면 결정적으로 윈도우즈에서
캡쳐할때 생성되는 BMP 형식(만)을 지원하지 않습니다.
마지막으로 C<Win32::GUI::DIBitmap> 모듈의 경우 ActivePerl의 경우 문제없이
사용이 가능하나 딸기펄 사용자의 경우 컴파일러 호환 문제로 설치되지 않아
사용할 수가 없습니다.

이 문제를 해결하는 가장 간단한 방법은 BMP를 PNG로 변환해주는 가벼운 유틸리티를
구해서 BMP 파일을 생성한 다음 바로 실행시켜 변환시키는 것입니다.
L<PNG 라이브러리 공식 홈페이지|http://www.libpng.org/pub/png/pngcode.html>에는 변환툴로서 가벼운
L<bmp2png|http://cetus.sakura.ne.jp/softlab/b2p-home/>를 소개하고 있습니다.
bmp2png는 단 하나의 실행파일로 구성되어 있으며 윈도우즈 명령줄에서
인자로 BMP 파일을 넘기면 확장자만 바꿔서 PNG 파일을 생성해줍니다.
bmp2png를 다운로드 받아서 압축을 푼 다음에 C<BMP2PNG.EXE> 파일을 스크립트가
있는 경로에 두거나 또는 C<PATH> 환경변수로 관리되고 있는 디렉터리에 두세요.

새롭게 갱신한 코드 조각은 다음과 같을 것입니다.

    #!perl
    $main->AddNotifyIcon(
        ...
        -onClick => sub {
            # 스크린샷을 찍습니다.
            SendKeys( "+{PRTSCR}" );
    
            # 스크린샷을 저장합니다.
            my $dt       = DateTime->now( time_zone => 'Asia/Seoul' );
            my $bitmap   = Win32::Clipboard::GetBitmap;
            my $filename = sprintf(
                '%4d%02d%02d-%02d%02d%02d.bmp',
                $dt->year, $dt->month,  $dt->day,
                $dt->hour, $dt->minute, $dt->second,
            );
            write_file($filename, { binmode => ':raw' }, $bitmap);
    
            # BMP 형식을 PNG로 변환합니다.
            system('BMP2PNG.EXE', $filename);
            unlink($filename);
    
            return 0;
        },
        ...
    );

I<그림 2.> PNG로 변환한 캡처 화면 L<(원본)|2011-12-07-3.png>
=for html <img src="2011-12-07-3.png" alt="PNG로 변환한 캡처 화면" width="700" />


=head2 보기 싫은 콘솔 창을 없애자

윈도우즈 환경에서 Perl 스크립트를 실행하면 기본적으로
항상 나타나는 까만 콘솔 창은 아무래도 좀 부담스럽습니다.
이제 이 콘솔 창을 없애 봅시다.
L<CPAN의 PAR::Packer 모듈|https://metacpan.org/module/Par::Packer>을 사용하면
실행 바이너리를 만드는 시점에 옵션을 이용해 콘솔 창을 보이지 않게 할 수 있습니다.
C<PAR::Packer>를 이용해서 바이너리로 만들지 않더라도
콘솔 창을 없애려면 L<CPAN의 Win32::HideConsole 모듈|https://metacpan.org/module/Win32::HideConsole>을
이용(L<CPAN의 Win32::Console 모듈|https://metacpan.org/module/Win32::Console>도 한번 확인해보세요) 합니다.

스크립트에는 다음 코드를 추가합니다.

    #!perl
    
    use Win32::HideConsole;
    
    hide_console;

실행하면 항상 보이던 콘솔 화면이 잠깐 나타났다가 이내 사라지는 것을 확인할 수 있습니다.


=head2 트레이 아이콘을 프로그램 안에 내장하고 싶어요!

현재 구현한 스크립트대로라면 C<icon.ico> 파일을
항상 스크립트와 함께 들고 다녀야 합니다.
이것은 꽤나 번거로운 일이기 때문에 아예 C<icon.ico> 파일을
코드 안에 내장시키는 것이 더 좋을 것 같습니다.
C<Win32::GUI::BitmapInline> 모듈은 BASE64 형식으로 인코딩된
데이터를 비트맵 형식으로 변환해서 받아들이기 때문에
이 모듈을 사용하면 스크립트 내부에 아이콘을
문자열 형식으로 저장할 수 있습니다.
C<Win32::GUI> 모듈을 설치했다면 바로 사용이 가능합니다.

우선 사용할 아이콘을 BASE64 형식으로 인코딩해야 합니다.
이것은 콘솔 창에서 단 한 줄의 코드로 알아낼 수 있습니다.

    #!bash
    > perl -MFile::Slurp -MMIME::Base64 -E "print encode_base64(read_file(shift))" icon.ico

실행을 시키면 콘솔창에 다음처럼 복잡한 문자열이 출력될 것입니다.

    #!plain
    > perl -MFile::Slurp -MMIME::Base64 -E "print encode_base64(read_file(shift))" icon.ico
    AAABAAMAEBAQAAEABAAoAQAANgAAABAQAAABAAgAaAUAAF4BAAAQEAAAAQAgAGgEAADGBgAAKAAA
    ABAAAAAgAAAAAQAEAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAP///wB7AAAAAHsAAHt7AAAAAHsA
    ewB7AAB7ewC9vb0Ae3t7AP8AAAAA/wAA//8AAAAA/wD/AP8AAP//AAAAAAD////////////////3
    /4////////+P/////////3//////////j/////////+P/////////49///////////h/////////
    //////j////4/////4//////////+P//f///j/j/j//////////4////////////////////////
    ////nlz7t3Qg/Zt4Zf2bIHT9W3Mg/VtuIP0TdXPwAXBy4ANsZeADIHfkB24g5gdld8MPZyD/n2Ug
    //9vbv//biAoAAAAEAAAACAAAAABAAgAAAAAAEABAAAAAAAAAAAAAAAAAAAAAAAA////AP7+/gDW
    1tYAqqqqAP39/QB5eXkAAAAAAHp6egD8/PwAQUFBAHV1dQCEhIQAHh4eAMvLywC3t7cAAwMDAIiI
    iAACAgIAgYGBAPb29gAgICAAtra2AIqKigAEBAQAGhoaAOfn5wAODg4AODg4AGtrawAYGBgAsrKy
    AMHBwQAVFRYAFxcXAAsLCwABAQEAHx8fAAoKCgBwcHAAm5ubAOnp6AB4eHgAERERACMjIwBEREQA
    4uLiAKampgBlZWUAampqALS0tACvr68Az8/PAAgICABsbGwAj4+PALGxsQC/v78A8fHxAFhYWACa
    mpoA////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////
    AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
    ////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD/
    //8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////
    AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
    ////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD/
    //8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////
    AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
    ////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD/
    //8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AAYGBgYGBgYGBgYG
    BgYGBgYGBgYGBgYGBgYNBgY6BgYGBgYGBgYGBgYGBhwGBgYGBgYGBgYGBgYGBgYDBgYGBgYGBgYG
    BgYGBgYGHAYGBgYGBgYGBgYGBgYGBhwGBgYGBgYGBgYGBgYGDBQJBgUGBgYGBgYGDAwGBgYGBhQG
    BScGBgYGBgYGBgYGBgYGBgwGBgYGBgYGGwYGBgYGBgYcBgYGBgYGFAYLBgYGBgYMBgYGBgYGBgYG
    BgsGBgYGCwYGBgYGCQYGBQYGCwYGDAYGBgYGBgYGBgYGBgYFBgYGBgYGBgYGBgYGBgYGBgYGBgYG
    BgYGBgYGBgYGBgYGBgYGBgb//55c+7d0IP2beGX9myB0/VtzIP1bbiD9E3Vz8AFwcuADbGXgAyB3
    5AduIOYHZXfDD2cg/59lIP//b27//24gKAAAABAAAAAgAAAAAQAgAAAAAABABAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAABwAAAAAQAAAE6/v79AAAAA
    DgAAAABYWFinAAAAZQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAA/wAAAAEAAAAB
    CAgI92xsbJMAAAAAAAAAAQAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAP8A
    AAABAAAASwAAAP+vr69QAAAAAAAAAAEAAAD/AAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAEAAAD/AAAAAQAAAP8AAAAAampqlQAAAAEAAAABAAAA/wAAAAEAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAABAAAA/wAAAAEAAAD/AAAAWWVlZZoAAAABAAAAAQAAAP8AAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAFwAAAP8AAACHERER7iMjI9xERES7AAAAAXp6eoUAAAD/AAAAHQAAAAAA
    AAAAAAAAAAAAAAEAAAA+FRUW6hcXF+gCAgL9CwsL9AEBAf4AAAD/AgIC/R8fH+AKCgr1cHBwj5ub
    m2QAAAAAAAAAAAAAAAAAAAABAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA
    /xgYGOcAAABNAAAAAAAAAAAAAAAAAAAAAQAAAP8ODg7xODg4xwAAAP8AAAD/AAAA/wAAAP8AAAD/
    AAAA/wAAAP9ra2uUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/ICAg3wAAAEmKiop1BAQE+wAAAP8A
    AAD/AAAA/wAAAP8aGhrlAAAAGAAAAAAAAAAAAAAAAAAAAAAAAABIAAAA/wMDA/wAAACKAAAAAYiI
    iHcCAgL9AAAA/wAAAP8AAAD/gYGBfgAAAAkAAAAAAAAAAAAAAAAAAAAAQUFBvgAAAP8AAAD/dXV1
    igAAAAAAAAAAhISEewAAAP8AAAD/Hh4e4QAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAp
    AAAAVQAAAAEAAAAAAAAAAAAAAAJ5eXmGAAAA/wAAAIUAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAD//55c+7d0IP2beGX9myB0/VtzIP1bbiD9E3Vz8AFwcuADbGXgAyB35AduIOYHZXfDD2cg
    /59lIP//b27//24g

화면에 출력되는 문자열을 복사한 다음 우리의 스크립트에 붙여넣어 보죠.

    #!perl
    # 사용할 아이콘을 정의합니다.
    my $icon = Win32::GUI::BitmapInline->newIcon( q(
    AAABAAMAEBAQAAEABAAoAQAANgAAABAQAAABAAgAaAUAAF4BAAAQEAAAAQAgAGgEAADGBgAAKAAA
    ABAAAAAgAAAAAQAEAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAP///wB7AAAAAHsAAHt7AAAAAHsA
    ewB7AAB7ewC9vb0Ae3t7AP8AAAAA/wAA//8AAAAA/wD/AP8AAP//AAAAAAD////////////////3
    ...
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAD//55c+7d0IP2beGX9myB0/VtzIP1bbiD9E3Vz8AFwcuADbGXgAyB35AduIOYHZXfDD2cg
    /59lIP//b27//24g
    ) );

아무래도 이제 파일 하나로 구성되었기 때문에 배포할 때도 훨씬 편리하겠죠?


=head2 락앤롤!

지금까지 작성한 스크립트의 전체 코드는 다음과 같습니다.
화면 갈무리 후 저장하는 파일 형식은 PNG입니다.

    #!perl
    #!/usr/bin/env perl
    
    use strict;
    use warnings;
    
    use Win32::GUI ();
    use Win32::GUI::BitmapInline;
    use Win32::GuiTest qw(SendKeys);
    use Win32::Clipboard;
    use Win32::HideConsole;
    use DateTime;
    use File::Slurp;
    
    # 콘솔을 보이지 않게 합니다.
    hide_console;
    
    # 사용할 아이콘을 정의합니다.
    my $icon = Win32::GUI::BitmapInline->newIcon( q(
    AAABAAMAEBAQAAEABAAoAQAANgAAABAQAAABAAgAaAUAAF4BAAAQEAAAAQAgAGgEAADGBgAAKAAA
    ABAAAAAgAAAAAQAEAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAP///wB7AAAAAHsAAHt7AAAAAHsA
    ewB7AAB7ewC9vb0Ae3t7AP8AAAAA/wAA//8AAAAA/wD/AP8AAP//AAAAAAD////////////////3
    /4////////+P/////////3//////////j/////////+P/////////49///////////h/////////
    //////j////4/////4//////////+P//f///j/j/j//////////4////////////////////////
    ////nlz7t3Qg/Zt4Zf2bIHT9W3Mg/VtuIP0TdXPwAXBy4ANsZeADIHfkB24g5gdld8MPZyD/n2Ug
    //9vbv//biAoAAAAEAAAACAAAAABAAgAAAAAAEABAAAAAAAAAAAAAAAAAAAAAAAA////AP7+/gDW
    1tYAqqqqAP39/QB5eXkAAAAAAHp6egD8/PwAQUFBAHV1dQCEhIQAHh4eAMvLywC3t7cAAwMDAIiI
    iAACAgIAgYGBAPb29gAgICAAtra2AIqKigAEBAQAGhoaAOfn5wAODg4AODg4AGtrawAYGBgAsrKy
    AMHBwQAVFRYAFxcXAAsLCwABAQEAHx8fAAoKCgBwcHAAm5ubAOnp6AB4eHgAERERACMjIwBEREQA
    4uLiAKampgBlZWUAampqALS0tACvr68Az8/PAAgICABsbGwAj4+PALGxsQC/v78A8fHxAFhYWACa
    mpoA////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////
    AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
    ////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD/
    //8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////
    AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
    ////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD/
    //8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////
    AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A
    ////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD/
    //8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP//
    /wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AAYGBgYGBgYGBgYG
    BgYGBgYGBgYGBgYGBgYNBgY6BgYGBgYGBgYGBgYGBhwGBgYGBgYGBgYGBgYGBgYDBgYGBgYGBgYG
    BgYGBgYGHAYGBgYGBgYGBgYGBgYGBhwGBgYGBgYGBgYGBgYGDBQJBgUGBgYGBgYGDAwGBgYGBhQG
    BScGBgYGBgYGBgYGBgYGBgwGBgYGBgYGGwYGBgYGBgYcBgYGBgYGFAYLBgYGBgYMBgYGBgYGBgYG
    BgsGBgYGCwYGBgYGCQYGBQYGCwYGDAYGBgYGBgYGBgYGBgYFBgYGBgYGBgYGBgYGBgYGBgYGBgYG
    BgYGBgYGBgYGBgYGBgYGBgb//55c+7d0IP2beGX9myB0/VtzIP1bbiD9E3Vz8AFwcuADbGXgAyB3
    5AduIOYHZXfDD2cg/59lIP//b27//24gKAAAABAAAAAgAAAAAQAgAAAAAABABAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAABwAAAAAQAAAE6/v79AAAAA
    DgAAAABYWFinAAAAZQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAA/wAAAAEAAAAB
    CAgI92xsbJMAAAAAAAAAAQAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAP8A
    AAABAAAASwAAAP+vr69QAAAAAAAAAAEAAAD/AAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAEAAAD/AAAAAQAAAP8AAAAAampqlQAAAAEAAAABAAAA/wAAAAEAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAABAAAA/wAAAAEAAAD/AAAAWWVlZZoAAAABAAAAAQAAAP8AAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAFwAAAP8AAACHERER7iMjI9xERES7AAAAAXp6eoUAAAD/AAAAHQAAAAAA
    AAAAAAAAAAAAAAEAAAA+FRUW6hcXF+gCAgL9CwsL9AEBAf4AAAD/AgIC/R8fH+AKCgr1cHBwj5ub
    m2QAAAAAAAAAAAAAAAAAAAABAAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA
    /xgYGOcAAABNAAAAAAAAAAAAAAAAAAAAAQAAAP8ODg7xODg4xwAAAP8AAAD/AAAA/wAAAP8AAAD/
    AAAA/wAAAP9ra2uUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/ICAg3wAAAEmKiop1BAQE+wAAAP8A
    AAD/AAAA/wAAAP8aGhrlAAAAGAAAAAAAAAAAAAAAAAAAAAAAAABIAAAA/wMDA/wAAACKAAAAAYiI
    iHcCAgL9AAAA/wAAAP8AAAD/gYGBfgAAAAkAAAAAAAAAAAAAAAAAAAAAQUFBvgAAAP8AAAD/dXV1
    igAAAAAAAAAAhISEewAAAP8AAAD/Hh4e4QAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAp
    AAAAVQAAAAEAAAAAAAAAAAAAAAJ5eXmGAAAA/wAAAIUAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAD//55c+7d0IP2beGX9myB0/VtzIP1bbiD9E3Vz8AFwcuADbGXgAyB35AduIOYHZXfDD2cg
    /59lIP//b27//24g
    ) );
    
    # 기본으로 사용할 창을 정의합니다.
    my $main = Win32::GUI::Window->new(
        -name => 'Main',
        -size => [ 1, 1 ],
    );
    
    # 시스템 트레이 아이콘을 정의합니다.
    $main->AddNotifyIcon(
        -name    => "NI",
        -icon    => $icon,
        -tip     => "Click to Screenshot!",
        -balloon => 0,
        -onClick => sub {
            # 스크린샷을 찍습니다.
            SendKeys( "+{PRTSCR}" );
    
            # 스크린샷을 저장합니다.
            my $dt       = DateTime->now( time_zone => 'Asia/Seoul' );
            my $bitmap   = Win32::Clipboard::GetBitmap;
            my $filename = sprintf(
                '%4d%02d%02d-%02d%02d%02d.bmp',
                $dt->year, $dt->month,  $dt->day,
                $dt->hour, $dt->minute, $dt->second,
            );
            write_file($filename, { binmode => ':raw' }, $bitmap);
    
            # BMP 형식을 PNG로 변환합니다.
            system('BMP2PNG.EXE', $filename);
            unlink($filename);
    
            return 0;
        },
        -onRightClick => sub {
            # 트레이에 좀비 아이콘이 그냥 남아있는 것을 방지합니다.
            $main->NI->Remove;
    
            # 프로그램 종료
            return -1;
        },
    );
    
    # 창을 숨깁니다.
    $main->Hide;
    
    # GUI 메인 루프에 진입합니다.
    Win32::GUI::Dialog;


=head2 정리하며

글쓴이 소개란을 읽으셨을지 모르겠지만, 전 전산/컴퓨터와는 전혀 관계 없는 법학 전공자거든요. (^^)
MS 윈도우 환경에서 약간의 Perl 지식만 있다면 Perl을 이용해 자신이 필요한 기능을
자신이 직접 설계해서 사용할 수 있다는 사실은 정말 매력적입니다.
모듈을 사용한 것은 온전한 제 지식이 아니라구요?
뭐 그럼 어떤가요? 어쨌든 만들고 싶었던 것을 만들어냈잖아요!
이미 다른 사람들이 만들어 놓은 수많은 CPAN 모듈들을 활용하면,
혼자 힘으로는 역부족이라고 생각했던 부분은 해낼 수 있게,
가능한 부분은 더욱 빠른 시간내에 구현할 수 있게 도와줍니다.
어떤가요? 매력적이지 않나요?
이미 Perl을 훌륭하게 사용하고 계신 많은 분들이 있지만,
저처럼 전산 전공이 아닌, 일반적 지식만을 갖춘 I<잠재적 Perl 이용자>께 이 글을 바칩니다.
화이팅! ;-)


=head2 생각해볼 거리

지금 프로그램은 파일을 저장하는 경로가 정해져있습니다.
실행하는 시점에 인자로 넘긴다던가, 또는 설정파일을 참고하도록 수정할 수도 있겠지요.
또한 트레이 아이콘에서 오른쪽 버튼을 눌렀을때 바로 종료가 되는 것이 아니라
팝업 메뉴를 띄운 후 설정을 변경하거나 종료하는 옵션을 추가할 수도 있을 것입니다.
나머지는 여러분의 상상력에 맡기겠습니다.

마지막으로 이 프로그램에 단축키 기능을 추가한다면 어떨까요?
이를테면 윈도우 환경 어디서나 CTRL-F12 를 클릭하면 이 기능이 동작하도록 하는 것입니다.
윈도우용 Perl은 L<Win32::API|https://metacpan.org/module/Win32::API> 모듈을 이용해 윈도우 기본 API를 직접 사용할 수 있기 때문에,
C<user32.dll>의 C<RegisterHotKey/UnregisterHotKey>를 임포트해 적당한 키 조합을 등록하고
키보드 입력을 전역으로 모니터링(후킹)하면, 단축키를 이용한 스크린샷의 조작이 가능합니다.
단축키 방식을 도입할 경우 지금까지 사용한 전체 화면 스크린캡쳐 외에도,
C<Alt + PrtSc>를 사용해 현재 활성화 된 창만을 갈무리 할 수 있습니다.
지금처럼 아이콘을 클릭하는 방식이라면 아이콘을 클릭하는 순간 활성창이
작업표시줄로 바뀌기 때문에, 항상 작업 표시줄만 갈무리 될 것입니다.
기사에서 사용한 모든 화면은 단축키까지 구현한 완전한 스크립트를 이용해서 갈무리한 것입니다.
C<PAR::Packer>로 빌드한 L<실행 바이너리와 전체 소스|http://www.nightowl.pe.kr/software/prtscrsave>도
꼭 다운로드 받아서 확인해보세요. ;-)

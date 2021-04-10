use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-15.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    한 이미지 안에 들어있는 사진들 추출하기 - Prima 모듈
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   gypark


=head2 저자

L<@gypark|http://twitter.com/gypark> - 
개인 자료라고 믿기 어려울 정도의 방대한 Perl 자료를
제공하고 있는 L<gypark.pe.kr|http://gypark.pe.kr/wiki/Perl>의 주인장, Raymundo라는 닉을 사용하기도 한다. 네이버 Perl 카페 회원


=head2 시작하며

오래 전 있었던 일입니다.
우연히 다음 그림과 같은 사진 파일을 보게 되었습니다.

=for html <img src="2011-12-15-1.png" alt="여러 사진이 포함된 하나의 이미지" /><br />

I<그림 1.> 여러 사진이 포함된 하나의 이미지

하나의 JPEG 사진 파일 안에 사진 세 장이 합쳐져 있는데
이게 모니터에 다 들어오지 않아 보기에 불편하더랍니다.
그래서 저 안에 있는 사진 세 장을 각각 별도의 파일로 저장하고 싶어졌습니다.

위와 같이 사진이 세 장 뿐이면 그림판에서 영역 지정해 저장하면 됩니다.
하지만 파일 하나에 사진이 수십 장 들어있다면,
그리고 그런 파일이 또 수십 개나 있다면 정말 골치아픈 일이 될 것입니다.
이것을 자동으로 할 수 없을까 궁리해 보았습니다.


=head2 아이디어

이미지 처리를 위한 빠르고 효율적인 알고리즘이 많이 있을 것입니다.
하지만 그런 것을 전혀 몰라도 원하는 결과는 여전히 얻을 수 있습니다.
가장 직관적이고 단순한 방법을 생각해봅시다.

여러 사진을 병합해 한 장의 사진을 만들면 배경색은 균일하게 쓰입니다.
반대로, 사진은 동일한 색상의 픽셀이 연속해서 나오는 경우가 거의 없습니다.
따라서, 사진 파일의 각 픽셀을 수직, 수평 방향으로 스캔하면서,
한 라인의 첫 픽셀부터 마지막 픽셀까지 동일한 색상이면 그 라인은 배경이고,
그렇지 않으면 사진이라고 간주해도 무방할 것 같습니다.

따라서, 먼저 파일 전체를 일단 세로방향으로 진행하며 스캔합니다.
제일 바닥부터 사진의 수평 라인을 한 줄씩 읽어 나가다가
배경이 아닌 부분을 만나면 그 라인을 시작 지점으로 지정하고,
다시 배경이 되는 라인을 만나면 그 라인을 끝 지점으로
지정합니다.
그런 다음, 시작지점부터 끝지점까지의 영역을 추출하여 하나의 이미지 조각으로
저장합니다. B<그림 2>를 참고하세요.

=for html <img src="2011-12-15-2.png" alt="세로 반향으로 진행하며 수평 라인을 한 줄씩 읽는다." /><br />

I<그림 2.> 세로 반향으로 진행하며 수평 라인을 한 줄씩 읽는다.

이렇게 총 세 개의 이미지 조각이 저장될 것입니다.
이번에는 각 조각마다 왼쪽에서 오른쪽으로 진행하면서 수직 라인을 스캔합니다.
역시 마찬가지로 배경이 아닌 부분을 처음 만나면 그 라인을 시작 지점으로 지정하고,
다시 배경 라인을 만나면 그 라인을 끝 지점으로 지정하여
시작 지점부터 끝 지점까지의 영역을 추출합니다.
그러면 마지막으로 추출된 영역이 우리가 원하는 한 장의 사진이 됩니다.
이것을 저장하면 되겠습니다. B<그림 3>을 참고하세요.

=for html <img src="2011-12-15-3.png" alt="좌에서 우측으로 진행하면서 수직 라인을 스캔한다." /><br />

I<그림 3.> 좌에서 우측으로 진행하면서 수직 라인을 스캔한다.

이 원리로 각각 세 장의 사진을 저장할 수 있습니다.
사실 이 방법으로는 제대로 추출하지 못하는 경우가 있지만,
어려운 건 나중에 생각합시다.

우리는 이미지 파일을 읽고, 각 픽셀의 색상 값을 구하고,
원하는 영역을 추출하고, 다시 이미지 파일로 저장하는 기능이 필요합니다.
L<CPAN|http://cpan.org/>에는 이런 기능을 제공하는 여러 모듈이 있습니다.
오늘은 L<Prima 모듈|http://metacpan.org/module/Prima>을 사용해 보도록 하겠습니다.


=head2 Prima 모듈 설치

L<Prima 모듈|http://metacpan.org/module/Prima>은 단순히 이미지 파일을 다루는 모듈이 아닙니다.
멀티 플랫폼에서 호환되는 GUI개발 툴킷입니다.
그러나 이미지를 다루는 기능만 필요할 때에도 Prima가 안성맞춤입니다.

L<CPAN|http://cpan.org/>에는 이미지를 처리하는 모듈이 많이 있습니다.
하지만 그 중에는 JPEG나 GIF 등의 포맷까지 다루기 위해서는
해당 포맷을 위한 별도의 라이브러리가 시스템에 설치되어 있어야
하는 모듈도 있습니다.
반면, Prima 모듈은 자체적으로 라이브러리를 제공하기 때문에
윈도우에서도 cpan을 통해 아주 간단히 컴파일 및 설치가 됩니다.

    #!plain
    c:\> cpan Prima

위와 같이 입력하면 Prima 모듈과, Prima에서 외부 이미지 처리를 위해 사용되는
Prima::codecs::win32 또는 Prima::codecs::win64 모듈까지 설치됩니다.

이상하게도 이미지 처리 라이브러리와 링크가 되지 않아
끝내 위 방법으로 설치하지 못하는 경우가 발생할 수도 있습니다.
제가 이 기사를 작성하기 위해 최근에 모듈을 다시 설치하면서 이 문제가 발생했는데
이때 저의 환경은 윈도 XP 서비스팩 3, Strawberry Perl 5.12.3이었습니다.

이처럼 컴파일 과정에서 에러가 나서 설치에 실패할 경우에는
먼저 Prima::codecs::win32 (또는 win64) 모듈만 cpan을 통해 설치하고,
Prima 자체는 Prima 웹사이트에서 배포하는 바이너리를 내려받습니다.

L<이곳에서|http://prima.eu.org/download/bindist.html> 자신의 환경에 맞는 압축 파일을
다운로드한 후 압축을 풀고, 압축을 푼 디렉터리에 들어가서
아래와 같은 명령으로 설치합니다.

    #!plain
    c:\> perl ms_install.pl


=head2 Prima 코드 예제

여기에 사용된 코드는 L<Prima::Image|http://metacpan.org/module/Prima::Image>
문서에 주로 나와 있습니다. 아래에 몇 가지 함수의 예를 코드로 정리하였습니다.

    #!perl
    use Prima;
    
    # "0.bmp"를 읽음
    my $image = Prima::Image->load('0.bmp');
    die "$@" unless $image;
    
    # 이미지의 가로와 세로 길이를 얻어냄
    # 만일 width(10) 처럼 setter 로 사용할 경우 그림이 확대 또는 축소된다.
    print "Width : ", $image->width(), "\n";
    print "Height: ", $image->height(), "\n";
    
    # 가로10, 세로5 좌표 픽셀의 컬러값을 얻음
    # 이 때 그림의 좌측 하단이 (0,0)이다.
    printf "%06x", $image->pixel(10, 5);
    
    # 5,0 자리 픽셀의 컬러를 지정
    $image->pixel(5, 0, 0x00ff00);
    
    # 일부 추출 (x오프셋, y오프셋, 폭, 높이)
    my $newimage = $image->extract(5, 0, 12, 2);
    
    # 저장
    $newimage->save('01.bmp');


=head2 완성

아래는 완성된 코드입니다.
위 아이디어를 그대로 코드로 옮긴 형태이기 때문에 개선의 여지가 많을 것입니다.
자세한 설명은 코드에 있는 주석을 참고하세요.

    #!perl
    #
    # 실행:
    # extract_photo.pl 파일명
    #
    # 파일을 열어서 내부에 포함된 사진들을 추출하여 개별 파일로 저장함
    #
    # Raymundo ( twitter: @gypark )
    # 2011.12.11
    
    use strict;
    use warnings;
    use Prima;
    
    # 파일명을 명령행 인자로 받고 이름과 확장자 분리
    my $filename = $ARGV[0];
    my ( $basename, $suffix ) = $filename =~ /(.+)\.([^.]*)$/;
    
    # 파일을 로드
    my $image = Prima::Image->load( $filename );
    die "can't load [$filename]: $@" unless $image;
    
    # 제일 귀퉁이의 색상이 배경색이라고 가정
    my $background = $image->pixel(0, 0);
    
    
    # 먼저 세로방향으로 진행하며 사진 조각 추출
    
    my @pieces;         # 추출되는 이미지 조각의 배열
    my $outside = 1;    # 현재 스캔하는 가로 라인이 배경인지 아닌지 체크
    my $y1;             # 사진이 시작되는 y좌표를 저장하기 위한 임시 변수
    foreach my $y ( 0 .. $image->height() - 1 ) {
        if ( ! same_color_horizon( $image, $y, $background ) ) {
            if ( $outside ) {
                # 배경에서 배경이 아닌 라인으로 처음 진입할 때 y좌표 기록
                $y1 = $y;
                $outside = 0;
            }
        }
        else {
            if ( ! $outside ) {
                # 배경이 아닌 라인에서 배경 라인으로 나가는 시점에서 이미지 조각 추출
                push @pieces, $image->extract( 0, $y1, $image->width(), $y - $y1 );
                $outside = 1;
            }
        }
    }
    
    
    # 이 시점에서, @pieces 에는 사진 조각들이 저장되어 있음
    # 각 조각에 대해서, 이번에는 가로 방향으로 진행하면서 좌우의 배경을 떼어낸다
    
    my $count = 1;  # 저장할 때 파일이름에 번호를 붙이기 위한 카운터
    foreach my $piece ( @pieces ) {
        my $outside = 1;
        my $x1;             # 사진이 시작되는 x좌표를 저장하기 위한 임시 변수
        foreach my $x ( 0 .. $piece->width() - 1 ) {
            if ( ! same_color_vertical( $piece, $x, $background ) ) {
                if ( $outside ) {
                    # 배경에서 배경이 아닌 라인으로 처음 진입할 때 x좌표 기록
                    $x1 = $x;
                    $outside = 0;
                }
            }
            else {
                if ( ! $outside ) {
                    # 배경이 아닌 라인에서 배경 라인으로 나가는 시점에서 이미지 조각 추출
                    my $photo = $piece->extract( $x1, 0, $x - $x1, $piece->height() );
                    $outside = 1;
                    # 추출한 조각을 파일로 저장
                    # 저장하는 이름은 "원본사진이름_두자리숫자.원본사진확장자"
                    my $photoname = sprintf( "%s_%02d.%s", $basename, $count++, $suffix );
                    $photo->save($photoname) or die "$@";
                    print "* [$photoname] saved\n";
                }
            }
        }
    }
    
    
    # 그림 객체 $img 와 세로좌표 $y 를 인자로 받아서
    # 세로좌표 $y에 해당하는 가로선이 전부 동일한 색상 $color인지 여부를 반환
    sub same_color_horizon {
        my ( $img, $y, $color ) = @_;
    
        foreach my $x ( 0 .. $img->width() - 1 ) {
            return 0 if ( $img->pixel($x, $y) != $color );
        }
    
        return 1;
    }
    
    # 그림 객체 $img 와 가로좌표 $x 를 인자로 받아서
    # 가로좌표 $x에 해당하는 세로선이 전부 동일한 색상 $color인지 여부를 반환
    sub same_color_vertical {
        my ( $img, $x, $color ) = @_;
    
        foreach my $y ( 0 .. $img->height() - 1 ) {
            return 0 if ( $img->pixel($x, $y) != $color );
        }
    
        return 1;
    }

한편, Prima에서 이미지의 좌표 오프셋을 처리할 때
이미지의 "좌측 아래"가 (0, 0)으로 간주되므로 아래쪽에 있는 사진부터 1번이 됩니다.
위에서부터 번호를 매기려면  y-좌표 스캔 방향을 위에서 아래로 진행하도록 뒤집으면 됩니다.
여기에서는 보기 쉽게 0에서부터 증가하도록 작성했습니다.


=head2 실행 결과

앞에서 본 샘플 이미지로 테스트하면 잘 작동합니다.
하지만 별로 재미가 없으니
쇼핑몰 사이트에서 상품 소개 사진 한 장을 가져와서 테스트해 봅시다.

=for html <img src="2011-12-15-4.jpg" alt="쇼핑몰 상품 소개 사진으로 실험한 모습" /><br />

I<그림 4.> 쇼핑몰 상품 소개 사진으로 실험한 모습

B<그림 4>의 좌측에 있는 원본 이미지는 세로가 12,280 픽셀이나 되는
길쭉한 이미지 파일입니다. 여기서 보통 크기의 사진 17 개를 추출해 내었습니다.

11, 12, 15, 16번 사진의 경우 상품 소개 문구나 눈에 띄지 않는
색상의 이미지가 들어가 있는 것이 추출되었습니다. 저런 건 별 수 없이 직접 눈으로 보면서 지워야겠습니다.


=head2 정리하며

Prima 모듈은 멀티 플랫폼 GUI 개발 툴킷입니다.
하지만 외부 이미지 포맷 라이브러리에 의존하지 않고
다양한 플랫폼을 지원하는 이미지 프로그램을 작성할 때에도 유용하게 사용할 수 있습니다.

워낙 간단한 알고리즘으로 사진을 추출했기 때문에 개선의 여지가 남아 있습니다.
실험을 통해 발견된 문제는 아래에 숙제로 남겨두겠습니다. 

=over

=item -

문제 1. 사진이 전체 이미지 제일 바깥쪽에 여백 없이 붙어 있으면 제대로 추출되지
않을 수 있습니다.



=item -

문제 2. 둘 이상의 사진이 세로로 겹치게 놓여 있으면 흉하게 추출됩니다.



=back


=head2 참고 문서

=over

=item *

L<Prima Homepage|http://prima.eu.org/> - http://prima.eu.org/


=item *

L<CPAN Prima|http://metacpan.org/module/Prima> - http://metacpan.org/module/Prima


=item *

L<GyparkWiki|http://gypark.pe.kr/wiki/Perl/Prima> - http://gypark.pe.kr/wiki/Perl/Prima


=back

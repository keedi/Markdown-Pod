use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-21.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    Perl로 시스템 트레이딩하기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   saillinux


=head2 저자

L<@saillinux|http://twitter.com/#!/saillinux> -
마음씨 좋은 외국인 노동자,
한국에 와서 비즈스프링에서 웹개발자 및 시스템 운영자로,
야후 코리아에서 프로덕션 옵스 및 엔지니어로,
현재 블리자드 엔터테인먼트에서 시스템 운영자로 재직 중이다.
L<거침없이 배우는 펄|http://www.yes24.com/24/goods/4433208>의 공동 역자,
Perl로 MMORPG를 만들어보겠다는 꿈을 갖고 있지만
요즘은 현실과 타협해 시스템 트레이딩에 푹 빠져있는 Perl덕후,
건강을 최고의 신조로 여기고 있다.


=head2 시작하며

오늘은 Perl을 이용해 아주 간단한 시스템 트레이딩을 해볼까 합니다.
조금 생소한가요? :)
소개하는 내용을 기반으로 자신만의 트레이딩 시스템 구축을 위한
프레임워크를 구현하는 것이 이번 기사의 목적입니다.
하지만 지금부터 다룰 내용은 목적은 실제 수익이 아니라 시스템 트레이딩
입문을 위한 설명인만큼, 혹시라도 생길 수 있는 I<불이익>에 대한 책임은
지지 않는다는 것 꼭 기억해두세요! ;-)


=head2 사전 지식

시스템 트레이딩은 여러 분야의 기술을 접목해야 구축하고 동작시킬 수 있습니다.
필요한 사전 지식은 다음과 같습니다.

=over

=item -

기본 주식 지식 및 HTS를 이용한 매매 경험,
  L<주식투자 무작정 따라하기|http://www.yes24.com/24/goods/5926363?scode=032&OzSrank=8>


=item -

주식에 대한 (약간의) 기술적 분석 (Technical Analysis)
  L<개념과 원리가 있는 친절한 기술적 분석|http://www.yes24.com/24/goods/4965201?scode=032&OzSrank=9>


=item -

L<Etrade 증권|http://etrade.co.kr>의 X-ing API


=item -

COM 인터페이스를 다루기 위한 L<CPAN의 Win32::OLE 모듈|https://metacpan.org/module/Win32::OLE>


=back


=head2 준비물

시스템 트레이딩 역시 일반적인 주식 거래와 다를 것이 없으므로 증권 계좌가 필요합니다.
여러분의 은행 계좌와 증권 계좌를 연결하기 위해 우선 은행을 방문해서
L<Etrade 증권|http://etrade.co.kr> 계좌를 새로 만듭니다(은행 직원분이 친철하게 도와주니까 겁먹지 마세요).
아름다운 직원분께서 계좌를 만들어 주시면 왠지 수익률이
높아질 것만 같은 기분이 듭니다(기분이 좋습니다).

=for html <img src="2011-12-21-1.jpg" alt="Camel Investment" width="700" />
I<그림 1.> Camel Investment L<(원본)|2011-12-21-1.jpg>

Etrade 증권의 HTS및 API를 이용하려면 증권 계좌 번호와
은행 계좌 번호, 공인 인증서가 필요하니까 준비해두세요.
그리고 Etrade HTS 및 X-ing COM, Res and DLL 파일이
필요한데 이것은 차차 설명하겠습니다.

마지막으로 시스템 트레이딩 구축을 위한 핵심인 Perl이 필요합니다.
모든 예제는 L<딸기 Perl|http://strawberryperl.com>을 기준으로 작성 및 테스트했습니다.
딸기 Perl을 설치하면 L<Win32::OLE 모듈|https://metacpan.org/module/Win32::OLE>이
기본으로 제공되므로 따로 설치하지 않아도 됩니다.


=head2 Etrade X-ing API?

Etrade 증권은 X-ing API를 제공하므로 개발자들이
자신의 입맞에 맞는 HTS 매매 시스템을 구축 할수 있습니다.
X-ing API가 제공 하는 COM을 이용해 모의 서버에 접속하면
사용할 수 있는 주요 기능은 다음과 같습니다.

=over

=item -

Etrade 증권 서비스를 로긴 후 세션을 유지


=item -

실시간 호가 및 체결값을 실시간으로 받기


=item -

현물 매수/매도 주문


=item -

선물,옵션 그리고 ELW 파생 상품 서비스 이용


=back

열거한 기능 이외에도 여러 기능을 제공하는데
자세한 내용은 X-ing API 레퍼런스 문서를 참조하세요.


=head2 X-ing API를 사용하기 위해 필요한 파일 설치

우선 X-ing API COM, Res 파일을 L<공식 홈페이지|http://etrade.co.kr>에서 받습니다.
파일을 받기 위해서는 Etrade 증권 계좌가 필요하며 회원 가입을 해야 합니다.
L<Etrade 증권 홈페이지|http://etrade.co.kr>에 들어가서 검색창에서 C<X-ing API>를
넣고 검색합니다.

=for html <img src="2011-12-21-2.jpg" alt="필요한 파일 다운로드" width="700" />
I<그림 2.> 필요한 파일 다운로드 L<(원본)|2011-12-21-2.jpg>

C:\XING 디렉토리를 생성한 후 다운로드 받은 파일(C<COM(2011.04.26).zip>,
C<Res(2011.10.20).zip>) 의 압축을 풀어 디렉토리에 넣습니다.
C<COM(2011.04.26)>는 C<COM>으로 C<Res(2011.10.20)>는 C<Res>로 이름을 변경합니다.
C<Programs(2011.11.10).zip> DLL 파일은 COM 파일의 최근 업데이트
내역이므로 COM 디렉터리 아래에 압축을 풀어줍니다.
파일을 풀고난 후 디렉토리 구조는 다음과 같습니다.

    #!bash
    C:\XING
    C:\XING\COM
    C:\XING\Res
    C:\XING\Res\Real
    C:\XING\Res\Tran

'-']... "허허 이런 것은 얼른 얼른 넘어갑시다"라고 외치실 분들을 위해
사실 따로 파일(L<다운로드|http://advent.perl.kr/2011/xing-demo.zip>)을 준비했습니다.
이 파일을 다운로드 받은 후 C<C:\>에 압축을 풉니다.

C<C:\XING\COM>에 들어가서 C<Reg.bat>를 실행해 X-ing COM 오브젝트를 등록합니다.

=for html <img src="2011-12-21-3.jpg" alt="설치" width="700" />
I<그림 3.> 설치 L<(원본)|2011-12-21-3.jpg>

자! 드디어 Xing-API를 사용하기 위한 사전 준비를 완료했습니다.
API를 테스트 하기위해 모의 투자 계좌를 이용합니다.
혹시 생길지 모르는 문제를 사전에 발견하기 위해 실전에서 테스트 하기 보다는
증권사에서 제공하는 모의 투자 시스템으로 연습하는 것이 먼저겠죠? :)
모의 투자 계좌는 증권 계좌와 다르므로 우선 HTS를 받아서 설치하고
모의 투자 모드로 로그인한 후 계좌 번호를 받아야 합니다.

=for html <img src="2011-12-21-4.jpg" alt="HTS 다운로드" width="700" />
I<그림 4.> HTS 다운로드 L<(원본)|2011-12-21-4.jpg>

설치가 끝나면 HTS로 로그인하세요.

=for html <img src="2011-12-21-5.jpg" alt="HTS 로그인" width="700" />
I<그림 5.> HTS 로그인 L<(원본)|2011-12-21-5.jpg>

그림에 표시된 모의 증권 계좌 번호를 적어 두도록 합니다.
그리고 모의 투자 계좌 비밀 번호는 C<0000>입니다.

=for html <img src="2011-12-21-6.jpg" alt="HTS 계정" width="700" />
I<그림 6.> HTS 계정 L<(원본)|2011-12-21-6.jpg>

이제 모의 투자 계좌 번호까지 준비되었습니다.
드이어 L<CPAN의 Win32::OLE 모듈|https://metacpan.org/module/Win32::OLE>을
이용해 Xing API를 사용해보죠!


=head2 X-ing API를 우아하게 Perl에서 사용 하도록 하자 '-'] 엣헴!

C<Reg.bat>을 실행하면 X-ing COM 객체가 원도우에 등록됩니다.
C<Win32::OLE>를 사용하면 COM이 제공하는 X-ing API를
Perl에서 직접 호출할 수 있기 때문에 정말 편리합니다.
이것을 C++ 이나 Visual Basic으로 작성할 생각을하면
상상만으로도 손가락이 얼얼해지는것 같네요;;


=head3 로그인, 세션 생성

우선 X-ing API로 로그인한 후 세션을 생성합니다.
Win32::OLE 모듈을 로드할 때 이벤트 핸들링을 위해
C<EVENTS>를 임포트한다는 점을 눈여겨 보세요.

    #!perl
    use 5.010;
    use strict;
    use warnings;
    use Carp;
    use Win32::OLE qw/EVENTS/;

X-ing API에서 세션을 담당하는 C<XA_Session.XASession>을 불러 OLE 객체를 받도록 합니다.

    #!perl
    my $XASession = Win32::OLE->new('XA_Session.XASession')
        or croak Win32::OLE->LastError();

그리고 C<XASession> 사용시 일어나는 모든 이벤트를 핸들 할수 있도록 다음과 같은 핸들러를 작성합니다.

    #!perl
    my $XASessionEvents = sub {
        my ( $obj, $event, @args ) = @_;
    
        # 1: OnLogin
        # 2: OnLogout
        # 3: OnDisconnect
        given ($event) {
            when (1) {
                my ($code, $msg) = @args;
                print "XASession Login Event: [$code] $msg \n";
                Win32::OLE->QuitMessageLoop();
            }
            when (2) {
                print "XASession Logout Event: @args \n";
                Win32::OLE->QuitMessageLoop();
            }
            when (3) {
                print "XASession Disconnect Event: @args \n";
                Win32::OLE->QuitMessageLoop();
            }
        }
    };

이벤트 코드 각각의 의미는 다음과 같습니다.

=over

=item -

C<1>: 로그인에 성공


=item -

C<2>: 로그아웃에 성공


=item -

C<3>: 연결 끊김


=back

이제 C<$XASession> 객체가 생성하는 모든 이벤트를 제어해보죠.

    #!perl
    Win32::OLE->WithEvents(
        $XASession,
        $XASessionEvents,
        '{6D45238D-A5EB-4413-907A-9EA14D046FE5}',
    );
    
    croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;

C<WithEvents>를 사용하지 않으면 로드한 객체의 이벤트를 핸들링 하지않습니다.
간혹 C<Win32::OLE>가 자동으로 이벤트 인터페이스를 판별 하지 못하는 객체도 있습니다.
그럴 경우에는 직접 객체의 C<COCLASS>(C<IProvideClassInfo2>를 참조) 값이라던지
혹은 이벤트의 DISPATCH 인터페이스를 찾아 3번째 인자로 제공해야합니다.

여기까지 수행하면 X-ing API의 OLE 객체를 얻을 수 있습니다.
이제는 다음 흐름에 따라 프로그램을 작성합니다.

=over

=item -

I<서버에 연결>: X-ing 서버에 연결


=item -

I<로그인>: 서버에 아이디/암호, 공인인증으로 로그인


=item -

I<데이터처리>: 조회성 TR/실시간 TR을 이용하여 데이터 조회 및 처리


=item -

I<로그아웃>: X-ing 서버에서 로그아웃


=item -

I<서버연결종료>: 서버와 연결된 세션 종료


=back

연결에 필요한 정보를 이용해서 OLE 객체를 이용해 세션을 생성하고
로그인을 수행하는 코드는 다음과 같습니다.

    #!perl
    my $server      = 'demo.etrade.co.kr'; # 모의 투자 서버 주소
    my $port        = 20001;               # 서비스 포트
    my $user        = q{};                 # Etrade 증권 아이디
    my $pass        = q{};                 # Etrade 증권 암호
    my $certpwd     = q{};                 # 공인 인증서 암호
    my $srvtype     = 1;                   # 서버 타입
    my $showcerterr = 1;                   # 공인 인증서 에러
    
    $XASession->ConnectServer($server, $port)
        or croak $XASession->GetErrorMessage( $XASession->GetLastError );
    
    $XASession->Login($user, $pass, $certpwd, $srvtype, $showcerterr)
        or croak $XASession->GetErrorMessage( $XASession->GetLastError );
    
    Win32::OLE->MessageLoop();

로그인을 하려면 사용자 아이디와 암호, 공인인증 암호가 필요한데
모의 투자로 테스트할 때는 공인인증 암호를 넣지 않아도 됩니다.

=for html <img src="2011-12-21-7.jpg" alt="로그인 과정" width="700" />
I<그림 7.> 로그인 과정 L<(원본)|2011-12-21-7.jpg>

C<MessageLoop>를 호출 하는 시점에 프로그램은 C<QuitMessageLoop>가 호출되기 전까지
윈도우 메시지 루프 모드로 들어가서 이벤트를 디스패치하기 시작합니다.
이렇게 해서 얻은 이벤트는 아까 작성한 C<XASessionEvents> 이벤트 핸들러가 처리합니다.
여기서는 로그인 세션을 성공적으로 생성된 것을 확인하면
다음 작업을 위해 C<QuitMessageLoop>를 호출해서 이벤트 루프에서 빠져나옵니다.


=head3 실시간으로 호가 및 체결 값 처리

X-ing API는 두 종류의 I<트랜잭션>(transaction)을 지원 합니다.
트랜잭션이란 서버로부터 데이터를 얻기 위해 요청하고
데이터를 받는 일련의 행동을 말합니다.

=over

=item -

I<조회 트랜잭션>: 서버로 부터 요청 당시의 데이터를 전송


=item -

I<실시간 트랜잭션>: 서버로 데이터 요청을 하면 이후에 데이터가 변경될 때마다 데이터를 전송(이벤트 방식)


=back

=for html <img src="2011-12-21-8.jpg" alt="트랜잭션" width="700" />
I<그림 8.> 트랜잭션 L<(원본)|2011-12-21-8.jpg>

호가 데이타를 받아오는 실시간 트랜잭션을 작성하려면
실시간 데이터를 제공하는 XAReal COM 객체를 불러옵니다.

    #!perl
    my $XAReal = Win32::OLE->new('XA_DataSet.XAReal.1')
        or croak Win32::OLE->LastError();

호가 데이터는 실시간으로 업데이트 되는 값이며 X-ing API에서는 실시간
트랜잭션 구조체인 C<S3_>을 참조해 호가 데이터를 요청 및 추출합니다.
앞서 압축을 풀어 C<Res> 폴더에 저장한 디렉토리의 파일을 적재합니다.

    #!perl
    $XAReal->LoadFromResFile("$FindBin::Bin/Res/Real/H1_.res")
        or croak Win32::OLE->LastError();

KOSPI호가잔량 데이터에 대한 이벤트 핸들링 입니다.
XAReal OLE객체가 제공하는 함수인 C<GetFieldData>로
C<H1_.res> DATA MAP 파일을 참조해 데이터 블록에서 필드값을 추출합니다.
첫 번째 인자인 C<OutBlock>은 DATA MAP을 참조할 때
데이터 블록을 받았을 경우의 필드를 참조하라는 뜻입니다.

    #!perl
    my $XARealEvents = sub {
        my ( $obj, $event, @args ) = @_;
    
        # 1: OnReceiveRealData
        given ($event) {
            when (1) {
                # 호가 값이 업데이트 된 시간을 추출
                my $hotime   = $XAReal->GetFieldData('OutBlock', 'hotime');
    
                # 매도 호가1 값을 추출
                my $offerho1 = $XAReal->GetFieldData('OutBlock', 'offerho1');
    
                # 매수 호가1 값을 추출
                my $bidho1   = $XAReal->GetFieldData('OutBlock', 'bidho1');
    
                print "\t$hotime $offerho1 $bidho1\n";
            }
        }
    };

C<$XAReal>이 받는 모든 이벤트를 C<$XARealEvents> 핸들러가 처리할 수 있도록 등록합니다.

    #!perl
    Win32::OLE->WithEvents(
        $XAReal,
        $XARealEvents,
        '{16602768-2C96-4D93-984B-E36E7E35BFBE}',
    );
    croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;

데이터를 보낼때 생성할 블록 데이터는 다음처럼 C<SetFieldData()> 함수를 호출해 생성할 수 있습니다.

    #!perl
    $XAReal->SetFieldData('InBlock', 'shcode', '000270');
    $XAReal->AdviseRealData();

C<InBlock>은 DATA MAP을 참조시 데이터 블록을 보낼 경우의 필드를 참조하라는 뜻입니다.
C<shcode>는 종목을 의미하며 C<000270>은 기아자동차의 코드 번호입니다.
즉, 기아자동차의 호가 잔량을 요청한다는 뜻이죠.
데이터 블록을 생성했으면 C<AviseReadData()> 함수를 호출해 실시간 데이터를 받습니다.

호가 잔량 데이터 핸들링 또한 이벤트를 처리해야 하므로
이벤트 루프에 다시 진입해야 합니다.

    #!perl
    Win32::OLE->MessageLoop();

스크립트를 실행한 후 C<Ctrl-C> 명령으로 종료하면 응용 프로그램
오류 창이 뜨지만 큰 상관은 없으니 가볍게 무시해도 됩니다. :)


=head2 두근두근 매수/매도리얼

드디어 매수/매도 주문을 내야 할 시점입니다.
모의 투자 계좌로 로그인 했기 때문에 부담없이 팍팍!! 주문을 해보세요.
걱정 마세요. 여러분의 가상 지갑은 튼실하답니다! :)
여러분은 여기서 한번 죽어도 다시 살아날 수 있습니다.

실시간 트랜잭션이 아니라 조회 트랜잭션을 사용해 주문을 내보죠.

    #!perl
    my $XAQuery  = Win32::OLE->new('XA_DataSet.XAQuery')
        or croak Win32::OLE->LastError();
    
    $XAQuery->LoadFromResFile("$FindBin::Bin/res/Tran/t5501.res")
        or croak Win32::OLE->LastError();

C<XA_DataSet.XAQuery> COM 객체를 이용해 OLE 객체를 생성했습니다.
현물 매수/매도 주문을 위한 DATA MAP은
C<Tran/t5501.res>에 정의되어 있으니 불러오도록 합니다.

    #!perl
    my $XAQueryEvents = sub { };

현물 주문 조회 트랜잭션의 경우 이벤트 호출로 받아 오는 데이터가 없으므로
제대로 체결이 이루어졌는지 알려면 실시간 C<SC0> 핸들러를 이용해
주문 체결 이벤트를 다루도록 합니다.
매수 주문을 넣기 위한 데이터 블록을 생성하고 요청하는 코드는 다음과 같습니다.

    #!perl
    $XAQuery->SetFieldData('t5501InBlock', 'reccnt',      0, '1');
    $XAQuery->SetFieldData('t5501InBlock', 'accno',       0, 'XXXXXXXXXXX'); 
    $XAQuery->SetFieldData('t5501InBlock', 'passwd',      0, '0000');
    $XAQuery->SetFieldData('t5501InBlock', 'expcode',     0, 'A000270');
    $XAQuery->SetFieldData('t5501InBlock', 'qty',         0, '1');
    $XAQuery->SetFieldData('t5501InBlock', 'price',       0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'memegb',      0, '2');
    $XAQuery->SetFieldData('t5501InBlock', 'hogagb',      0, '03');
    $XAQuery->SetFieldData('t5501InBlock', 'pgmtype',     0, '00');
    $XAQuery->SetFieldData('t5501InBlock', 'gongtype',    0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'gonghoga',    0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'tongsingb',   0, '00');
    $XAQuery->SetFieldData('t5501InBlock', 'sinmemecode', 0, '000');
    $XAQuery->SetFieldData('t5501InBlock', 'loandt',      0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'memnumber',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'ordcondgb',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'stragb',      0, '000000');
    $XAQuery->SetFieldData('t5501InBlock', 'groupid',     0, '00000000000000000000');
    $XAQuery->SetFieldData('t5501InBlock', 'ordernum',    0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'portnum',     0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'basketnum',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'tranchnum',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'itemnum',     0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'operordnum',  0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'flowsupgb',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'oppbuygb',    0, '0');
    
    $XAQuery->Request(0);

상당히 길어 보이지만 몇 가지 필드만 신경쓰면 됩니다.

=over

=item -

C<accno>: 증권 계좌 번호(지금은 모의투자 계좌 번호)


=item -

C<passwd>: 증권계좌 암호


=item -

C<expcode>: 주식 번호(앞에 A를 앞에 붙임)


=item -

C<qty>: 수량


=item -

C<price>: 지정가일 경우 원하는 체결 가격


=item -

C<memegb>: 매매 구분(C<1>은 매수, C<2>는 매도)


=item -

C<hogagb>: 호가유형 코드(C<00>는 지정가, C<03>은 시장, 등등)


=back

그외 필드는 예제에 있는 값을 이용하시면 됩니다
자세한 내용은 X-ing API 레퍼런스 문서를 참조하세요.

이렇게 해서 생성한 데이터 블럭을 C<Request()> 함수를 호출해 주문합니다.
주문을 내기만 해서는 접수가 이루어졌는지 알 수 없습니다.
실시간으로 접수가 이루어졌는지 확인하려면
실시간 트랜잭션 중 하나인 주식 주문 접수를 등록합니다.

    #!perl
    my $XAReal = Win32::OLE->new('XA_DataSet.XAReal.1')
        or croak Win32::OLE->LastError();
    
    $XAReal->LoadFromResFile("$FindBin::Bin/res/Real/SC0_.res")
        or croak Win32::OLE->LastError();
    
    my $XARealEvents = sub SC0_handler {
        my ($obj) = @_;
    
        print $obj->GetFieldData('OutBlock', 'ordno'), "\n";
    }
    
    Win32::OLE->WithEvents($XAReal, $XARealEvents, '{16602768-2C96-4D93-984B-E36E7E35BFBE}');
    croak Win32::OLE->LastError() if Win32::OLE->LastError() != 0;
    
    $XAReal->AdviseRealData();

실시간 주문 접수와는 달리 데이터 블럭을 직접 만들 필요가 없습니다.
주문 접수가 이루어 졌을때 전달받는 값 중 하나인 C<ordno>(주문번호)를 출력합니다.

주문 한번 시원하게 날려볼까요? ;-)

    #!perl
    Win32::OLE->MessageLoop();


=head2 전체 소스 코드


=head3 trading.pl

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    
    use Carp;
    use FindBin;
    use Win32::OLE qw( EVENTS );
    
    local $|++;
    
    my $XASession = Win32::OLE->new('XA_Session.XASession')
        or croak Win32::OLE->LastError;
    
    my $XASessionEvents = sub {
        my ($obj, $event, @args) = @_;
        
        # 1: OnLogin
        # 2: OnLogout
        # 3: OnDisconnect
        given ($event) {
            when (1) {
                my ($code, $msg) = @args;
                say "XASession Login Event: [$code] $msg";
                Win32::OLE->QuitMessageLoop;
            }
            when (2) {
                say "XASession Logout Event: @args";
                Win32::OLE->QuitMessageLoop;
            }
            when (3) {
                say "XASession Disconnect Event: @args";
                Win32::OLE->QuitMessageLoop;
            }
        }
    };
    
    Win32::OLE->WithEvents(
        $XASession,
        $XASessionEvents,
        '{6D45238D-A5EB-4413-907A-9EA14D046FE5}',
    );
    
    croak Win32::OLE->LastError
        if Win32::OLE->LastError != 0;
    
    my $server      = 'demo.etrade.co.kr';    # 모의 투자 서버 주소
    my $port        = 20001;                  # 서비스 포트
    my $user        = q{};                    # 이트레이드 증권 아이디
    my $pass        = q{};                    # 이트레이드 증권 암호
    my $certpwd     = q{};                    # 공인 인증서 암호
    my $srvtype     = 1;                      # 서버 타입
    my $showcerterr = 1;                      # 공인 인증서 에러
    
    $XASession->ConnectServer($server, $port)
        or croak $XASession->GetErrorMessage( $XASession->GetLastError );
    
    $XASession->Login($user, $pass, $certpwd, $srvtype, $showcerterr)
       or croak $XASession->GetErrorMessage( $XASession->GetLastError );
    
    Win32::OLE->MessageLoop;
    
    my $XAReal = Win32::OLE->new('XA_DataSet.XAReal.1')
        or croak Win32::OLE->LastError;
    
    $XAReal->LoadFromResFile("$FindBin::Bin/res/Real/H1_.res")
        or croak Win32::OLE->LastError;
    
    my $XARealEvents = sub {
        my ( $obj, $event, @args ) = @_;
    
        # 1: OnReceiveRealData
        given ($event) {
            when (1) {
                my $trname = $args[0];
    
                my $hotime   = $obj->GetFieldData('OutBlock', 'hotime');
                my $offerho1 = $obj->GetFieldData('OutBlock', 'offerho1');
                my $bidho1   = $obj->GetFieldData('OutBlock', 'bidho1');
    
                print "OnReceiveRealData: $trname\n";
                print "[$hotime $offerho1 $bidho1]\n";
            }
        }
    };
    
    Win32::OLE->WithEvents(
        $XAReal,
        $XARealEvents,
        '{16602768-2C96-4D93-984B-E36E7E35BFBE}',
    );
    
    croak Win32::OLE->LastError
        if Win32::OLE->LastError != 0;
    
    $XAReal->SetFieldData( 'InBlock', 'shcode', '000270' );
    
    $XAReal->AdviseRealData;
    
    Win32::OLE->MessageLoop;


=head3 order.pl

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    
    use Carp;
    use FindBin;
    use Win32::OLE qw( EVENTS );
    
    local $|++;
    
    my $XASession = Win32::OLE->new('XA_Session.XASession')
        or croak Win32::OLE->LastError;
    
    my $XASessionEvents = sub {
        my ($obj, $event, @args) = @_;
        
        # 1: OnLogin
        # 2: OnLogout
        # 3: OnDisconnect
        given ($event) {
            when (1) {
                my ($code, $msg) = @args;
                say "XASession Login Event: [$code] $msg";
                Win32::OLE->QuitMessageLoop;
            }
            when (2) {
                say "XASession Logout Event: @args";
                Win32::OLE->QuitMessageLoop;
            }
            when (3) {
                say "XASession Disconnect Event: @args";
                Win32::OLE->QuitMessageLoop;
            }
        }
    };
    
    Win32::OLE->WithEvents(
        $XASession,
        $XASessionEvents,
        '{6D45238D-A5EB-4413-907A-9EA14D046FE5}',
    );
    
    croak Win32::OLE->LastError
        if Win32::OLE->LastError != 0;
    
    my $server      = 'demo.etrade.co.kr';    # 모의 투자 서버 주소
    my $port        = 20001;                  # 서비스 포트
    my $user        = q{};                    # 이트레이드 증권 아이디
    my $pass        = q{};                    # 이트레이드 증권 암호
    my $certpwd     = q{};                    # 공인 인증서 암호
    my $srvtype     = 1;                      # 서버 타입
    my $showcerterr = 1;                      # 공인 인증서 에러
    
    $XASession->ConnectServer($server, $port)
        or croak $XASession->GetErrorMessage( $XASession->GetLastError );
    
    $XASession->Login($user, $pass, $certpwd, $srvtype, $showcerterr)
       or croak $XASession->GetErrorMessage( $XASession->GetLastError );
    
    Win32::OLE->MessageLoop;
    
    my $XAQuery = Win32::OLE->new('XA_DataSet.XAQuery')
        or croak Win32::OLE->LastError;
    
    $XAQuery->LoadFromResFile("$FindBin::Bin/Res/Tran/t5501.res")
        or croak Win32::OLE->LastError;
    
    my $XAQueryEvents = sub { };
    
    $XAQuery->SetFieldData('t5501InBlock', 'reccnt',      0, '1');
    $XAQuery->SetFieldData('t5501InBlock', 'accno',       0, 'XXXXXXXXXXX'); 
    $XAQuery->SetFieldData('t5501InBlock', 'passwd',      0, '0000');
    $XAQuery->SetFieldData('t5501InBlock', 'expcode',     0, 'A000270');
    $XAQuery->SetFieldData('t5501InBlock', 'qty',         0, '1');
    $XAQuery->SetFieldData('t5501InBlock', 'price',       0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'memegb',      0, '2');
    $XAQuery->SetFieldData('t5501InBlock', 'hogagb',      0, '03');
    $XAQuery->SetFieldData('t5501InBlock', 'pgmtype',     0, '00');
    $XAQuery->SetFieldData('t5501InBlock', 'gongtype',    0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'gonghoga',    0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'tongsingb',   0, '00');
    $XAQuery->SetFieldData('t5501InBlock', 'sinmemecode', 0, '000');
    $XAQuery->SetFieldData('t5501InBlock', 'loandt',      0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'memnumber',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'ordcondgb',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'stragb',      0, '000000');
    $XAQuery->SetFieldData('t5501InBlock', 'groupid',     0, '00000000000000000000');
    $XAQuery->SetFieldData('t5501InBlock', 'ordernum',    0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'portnum',     0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'basketnum',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'tranchnum',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'itemnum',     0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'operordnum',  0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'flowsupgb',   0, '0');
    $XAQuery->SetFieldData('t5501InBlock', 'oppbuygb',    0, '0');
    
    $XAQuery->Request(0);
    
    my $XAReal = Win32::OLE->new('XA_DataSet.XAReal.1')
        or croak Win32::OLE->LastError;
    
    $XAReal->LoadFromResFile("$FindBin::Bin/res/Real/SC0.res")
        or croak Win32::OLE->LastError;
    
    my $XARealEvents = sub {
        my ( $obj ) = @_;
    
        say $obj->GetFieldData('OutBlock', 'ordno');
    };
    
    Win32::OLE->WithEvents(
        $XAReal,
        $XARealEvents,
        '{16602768-2C96-4D93-984B-E36E7E35BFBE}',
    );
    croak Win32::OLE->LastError
        if Win32::OLE->LastError != 0;
    
    $XAReal->AdviseRealData;
    
    Win32::OLE->MessageLoop;


=head2 정리하며

지금까지 Etrade 증권사 API와 Perl을 이용해 주식을
조회하고 사고 팔수 있는 방법을 소개 했습니다.
여기서 한 걸음 더 나아가고 싶다면 Perl로 만들어진
전략엔진 및 위험관리 시스템인 L<GeniusTrader|http://www.geniustrader.org>와
L<TradeSpring|https://github.com/tradespring/TradeSpring>을 참고하면 큰 도움이 될 것입니다.
실제로 본격적인 시스템 트레이딩을 하려면 전략 또한 정말 중요하겠죠.
이 모든 것을 Perl로 잘 구현한 후 X-ing API와 연동해
호가 체결 조회 및 매수/매도 주문을 낸다면 자신만의
시스템 트레이딩 환경을 갖출 수 있습니다.
짜릿하지 않나요?

자, 행운을 빕니다! ;-)

=for html <img src="2011-12-21-9.jpg" alt="Good Luck!" width="700" />
I<그림 9.> Good Luck! L<(원본)|2011-12-21-9.jpg>

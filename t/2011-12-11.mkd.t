use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-11.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    리눅스와 Gnome, 노틸러스, GE.TT, Perl
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   keedi


=head2 저자

L<@keedi|http://twitter.com/#!/keedi> - Seoul.pm 리더, Perl덕후,
L<거침없이 배우는 펄|http://www.yes24.com/24/goods/4433208>의 공동 역자, keedi.k I<at> gmail.com


=head2 시작하며

L<리눅스|http://en.wikipedia.org/wiki/Linux>가 무엇인지 더이상 설명하지 않아도 되는 세상이 되었습니다.
불과 십 몇년 전까지만 해도 리눅스가 무엇인지, 왜 리눅스를
써야하는지 구구절절 설명하기 바빴는데 말이죠.
오랜 시간동안 리눅스는 서버 뿐만 아니라,
데스크탑 영역에서도 괄목할 만한 성장을 이루었습니다.
L<Gnome|http://www.gnome.org/>과 L<KDE|http://kde.org/> 두 진영은 놀랍게도 리눅스 태초부터
지금까지 대단한 뚝심으로 프로젝트를 개선시켜나가며 이어오고 있습니다.
그 중에서도 Gnome 데스크탑의 파일 관리자인 노틸러스는
Gnome 데스크탑의 기본 뼈대가 되는 부분이라고 해도 과언이 아닙니다.
노틸러스는 단순히 파일을 관리한다는 차원을 넘어 파일과 관련해
눈에 보이는 모든 것(그것이 로컬 자원이든, 원격 자원이든)을 제어합니다.
심지어 바탕화면과 바탕화면에서 보이는 파일조차도 말이죠.
따라서 노틸러스에 원하는 기능을 연동할 수 있다면
그 편의성은 상상 그 이상이라고 할 수 있습니다.

=for html <img src="2011-12-11-01.png" alt="GE.TT" width="700" />
<br />

I<그림 1.> GE.TT L<(원본)|2011-12-11-01.png>

L<GE.TT|http://ge.tt>는 L<Dropbox|http://www.dropbox.com>와 유사한 서비스로
파일을 저장하고 공유할 수 있는 클라우드 서비스입니다.
이미 Dropbox를 사용해보신 분이라면 알겠지만 특정 디렉터리에
파일을 저장하면 자동으로 원격의 저장소와 동기화가 됩니다.
이런 작업도 사실 노틸러스와의 연동으로 구현한 것이죠.
Gnome 데스크탑 환경에서 GE.TT 서비스를 연동해 마우스 클릭 두 번으로 
파일을 업로드하고 공유하는 것이 얼마나 쉬운지 궁금하지 않나요?
그리고 이 모든 작업의 가운데는 Perl이 있다는 사실에 곧 놀라게 될 것입니다. :)


=head2 준비물

노틸러스의 동작을 제어하기 위해서 설치 해야 할 도구가 있습니다.
데비안 계열의 리눅스를 사용하고 있다면 다음 명령을 이용해서 패키지를 설치합니다.

    #!bash
    $ sudo apt-get install nautilus-actions

필요한 모듈은 다음과 같습니다.

=over

=item -

L<CPAN의 Config::Tiny 모듈|https://metacpan.org/module/Config::Tiny>


=item -

L<CPAN의 Const::Fast 모듈|https://metacpan.org/module/Const::Fast>


=item -

L<CPAN의 File::HomeDir 모듈|https://metacpan.org/module/File::HomeDir>


=item -

L<CPAN의 File::Spec 모듈|https://metacpan.org/module/File::Spec>


=item -

L<CPAN의 IPC::Run 모듈|https://metacpan.org/module/IPC::Run>


=item -

L<CPAN의 Net::API::Gett 모듈|https://metacpan.org/module/Net::API::Gett>


=item -

L<CPAN의 Try::Tiny 모듈|https://metacpan.org/module/Try::Tiny>


=back

L<CPAN|http://www.cpan.org/>을 이용해서 설치한다면 다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ sudo cpan \
        Config::Tiny Const::Fast File::HomeDir File::Spec::Functions \
        IPC::Run Net::API::Gett Try::Tiny

사용자 계정으로 모듈을 설치하는 방법을 정확하게 알고 있거나
C<perlbrew>를 이용해서 자신만의 Perl을 사용하고 있다면
다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ cpan \
        Config::Tiny Const::Fast File::HomeDir File::Spec::Functions \
        IPC::Run Net::API::Gett Try::Tiny


=head2 잠깐!

(Updated: 현재는 L<패치된 버전이 릴리스|https://metacpan.org/module/Net::API::Gett>
되었으므로 참고만 하고 따라하지 않으셔도 됩니다. ;-)

현재 릴리스된 C<Net::API::Gett> 모듈 0.01 버전은 C<refreshtoken>으로
인증을 수행하는 부분이 구현되어 있지 않습니다.
저장소의 최신 버전에는 추가되었는데
L<0.02 버전이 조만간 릴리스될 계획|https://github.com/mrallen1/Net-API-Gett/commit/da1268b21ec7049ff867b94fefcb4ac3678b6d1e>이라고 하니까
우선은 L<패치된 버전|http://api2.ge.tt/0/3hi7hLB/0/blob/download>을 사용하도록 합니다.
C<cpanm>을 사용하고 있다면 다음 명령을 실행해서 패치된 버전을 설치합니다.

    #!bash
    $ cpanm http://api2.ge.tt/0/3hi7hLB/0/blob/download

C<cpanm>을 사용하고 있지 않다면 수동으로 설치합니다.

    #!bash
    $ wget -c http://api2.ge.tt/0/3hi7hLB/0/blob/download -O Net-API-Gett-0.01.tar.gz
    $ tar xvzf Net-API-Gett-0.01.tar.gz
    $ cd Net-API-Gett-0.01
    $ perl ./Build.PL
    $ ./Build
    $ ./Build install

시스템에 설치한다면 C<sudo> 명령을 이용해 설치합니다.

    #!bash
    $ sudo ./Build install


=head2 GE.TT API

GE.TT API와 관련해서는 L<Ge.tt Developers 페이지|http://ge.tt/developers>에서 확인할 수 있습니다.
우선 API를 사용하기 위해서 C<api_key>를 발급 받아야 합니다.
회원 가입을 한 후 L<Ge.tt Developers 페이지|http://ge.tt/developers>의
I<Create app>을 클릭한 다음 이름과 웹사이트 및 설명을 입력하고
C<api_key>를 발급 받습니다.

=for html <img src="2011-12-11-02.png" alt="GE.TT API 키 발급" width="700" />
<br />

I<그림 2.> GE.TT API 키 발급 L<(원본)|2011-12-11-02.png>

이렇게 C<api_key>까지만 발급받으면 GE.TT 서비스를 이용하는데 문제가 없지만,
이럴 경우 사용자 계정과 비밀번호가 노출될 위험이 있으므로
C<accesstoken>과 C<refreshtoken>을 이용해서 서비스를 이용하는 편이 더 안전합니다.

발급받은 C<api_key>와 계정 정보를 이용해 명령줄에서 다음 명령을 실행하면
C<accesstoken>과 C<refreshtoken>을 얻어올 수 있습니다.

    #!bash
    $ curl -X POST --data \
        '{"apikey":"...","email":"your@email.com","password":"..."}' \
        https://open.ge.tt/1/users/login 
    {
        "accesstoken":"a.0101.123123123123",
        "refreshtoken":"r.0101.acbcabacbacbacb",
        ...
    } 

얻어온 C<accesstoken>을 이용하면 이제 더 이상 사용자 계정과 비밀번호,
C<api_key> 없이 파일 공유와 관련한 API 호출을 수행할 수 있습니다.
다만 이 토큰은 유효한 기간이 있기 때문에 해당 기간이 지나면 만료됩니다.
기간이 만료되었을 때 다시 최신의 접근 토큰을 받기 위해
사용하는 것이 C<refreshtoken>입니다.
C<refreshtoken>이 없다면 C<accesstoken>을 받기 위해
사용자 계정과 비밀번호, C<api_key>를 다시 입력 해야 됩니다.
물론 이 접근 토큰의 유효한 기간 역시 사용자가 설정할 수 있는데
자세한 부분은 홈페이지의 개발 문서를 살펴보세요.


=head2 GE.TT 그리고 Perl

물론 GE.TT가 API를 지원하기 때문에 직접 POST 또는
REST를 이용해서 API를 호출할 수도 있습니다.
하지만 L<CPAN Net::API::Gett 모듈|https://metacpan.org/module/Net::API::Gett>이 있기 때문에
단 몇 줄의 코드로 파일을 공유할 수 있습니다.
다음은 GE.TT에 하나의 파일을 업로드한 후 파일의 링크 보여주는 예제입니다.

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    use Net::API::Gett;
    
    my $file = shift;
     
    my $gett = Net::API::Gett->new(
        access_token  => 'a.0101.123123123123',
        refresh_token => 'r.0101.acbcabacbacbacb',
    );
    
    my $file_obj = $gett->upload_file(
        title    => $file,
        filename => $file,
        contents => $file,
    );
     
    say "File has been shared at " . $file_obj->url;

간단하죠?  객체를 생성하고 C<upload_file()> 메소드를 이용하는 것이 전부입니다.


=head2 노틸러스 동작 추가

C<nautilus-actions> 패키지를 설치했다면
메뉴 모음(C<시스템 - 기본 설정 - 노틸러스 동작 설정>)에서
I<노틸러스 동작 설정> 항목이 추가된 것을 확인할 수 있습니다.
I<노틸러스 동작 설정> 프로그램의 영문 이름은 I<Nautilus Actions Configuration Tool>이니,
로컬 설정이 달라서 영문 버전을 사용한다면 참고하세요.

=for html <img src="2011-12-11-03.png" alt="시스템 - 기본 설정 - 노틸러스 동작 설정" />
<br />

I<그림 3.> 시스템 - 기본 설정 - 노틸러스 동작 설정

명령줄에서 직접 실행하려면 다음 명령을 실행합니다.

    #!bash
    $ nautilus-actions-config-tool

노틸러스 동작 설정 프로그램을 띄운 후 우리가 원하는 동작을 추가해보죠.
C<File - New action>을 누르거나 툴바 메뉴에서 C<+> 기호가 있는 아이콘을 클릭하면
왼쪽 영역인 I<Action list:>에 새로운 동작(action)이 추가됩니다.
클릭해서 원하는 이름으로 바꿉니다. C<Send to GE.TT> 정도면 적절하겠죠?
이 이름은 노틸러스에서 마우스 오른쪽 버튼을 클릭했을때 나타나는
팝업 메뉴에서 보일 이름입니다.

=for html <img src="2011-12-11-04.png" alt="노틸러스 동작 추가" width="700" />
<br />

I<그림 4.> 노틸러스 동작 추가 L<(원본)|2011-12-11-04.png>

이제는 팝업 메뉴에서 해당 항목을 클릭했을때 실행할 동작을 설정 해야 합니다.
오른쪽의 탭 영역에서 C<Command> 탭을 선택합니다.
C<Command> 탭 하부의 C<Command> 섹션의 값을 다음처럼 설정합니다.

=over

=item -

I<Path>: C<<< /home/<your_id>/bin/gett.pl >>>


=item -

I<Parameters>: C<%M>


=back

=for html <img src="2011-12-11-05.png" alt="Command 섹션 변경" width="700" />
<br />

I<그림 5.> Command 섹션 변경 L<(원본)|2011-12-11-05.png>

C<Path> 항목은 팝업 메뉴에서 C<Send to GE.TT>를 클릭했을 때 실행할 명령의 경로를 지정합니다.
C<Parameters> 항목은 명령을 실행할 때 인자로 넘겨줄 목록입니다.
노틸러스에서 여러 개의 파일을 선택한 후 메뉴를 호출한다면
선택한 모든 파일을 업로드 해야 겠죠.
C<%M>은 노틸러스에서 사용자가 선택한 파일의 전체 경로의 목록입니다.
C</home/askdna/share> 디렉터리에서 C<README.txt>와 C<SHOWME.png>를 선택했다면
C<%M> 항목은 C</home/askdna/share/README.txt>와 C</home/askdna/share/SHOWME.png>를
실행할 파일에게 넘겨줍니다.

또한 이렇게 C<%M>을 사용하려면 노틸러스 동작이
여러 개의 파일을 선택할 수 있도록 설정 해야 합니다.
C<Conditions> 탭을 선택한 다음 C<선택 사항이 포함되면 보임> 항목에서
C<Appears if selection has multiple files or folders> 체크박스를
활성화시킵니다.

=for html <img src="2011-12-11-06.png" alt="Conditions 섹션 변경" width="700" />
<br />

I<그림 6.> Conditions 섹션 변경 L<(원본)|2011-12-11-06.png>

마지막으로 이렇게 추가한 노틸러스 동작과 관련한 설정은
Gnome 데스크탑 환경이 기본으로 사용하고 있는 C<GConf>로 저장됩니다.
C<gconf-editor> 명령을 실행시키면 C</apps/nautilus-actions/configurations> 섹션
하부에 조금 전에 추가한 노틸러스 동작이 저장되어 있는 것을 확인할 수 있습니다.

=for html <img src="2011-12-11-07.png" alt="gconf-editor" width="700" />
<br />

I<그림 7.> gconf-editor L<(원본)|2011-12-11-07.png>


=head2 gett.pl

노틸러스 동작을 추가할 때 팝업 메뉴를 띄운 후 실제로 실행시킬
명령을 C<<< /home/<your_id>/bin/gett.pl >>>이라고 입력했습니다.
이제는 GE.TT로 전송하기 기능의 핵심인 C<gett.pl> 스크립트를 작성해보죠.
우선 C<gett.pl> 명령은 노틸러스로 부터 1개 이상의 파일을 인자로 받습니다.
C<@ARGV> 변수를 이용해서 각각의 인자를 처리하는 코드는 다음과 같습니다.

    #!perl
    die "Usage: $0 <file> [ <file> ... ]\n" unless @ARGV;
    
    for my $file ( @ARGV ) {
        next unless -f $file;
    
        # share the $file
    }

그리고 C<accesstoken>과 C<refreshtoken>을 스크립트에 저장하는 것은
유지 보수 및 배포의 측면에서 적절하지 못해보입니다.
이런 경우 환경 변수나 설정 파일을 이용하면 좋을 것 같은데
지금은 설정 파일을 이용하도록 하죠.
설정 파일의 경로는 C<~/.gett/config>, 형식은 INI라고 가정합니다.
다음은 설정 파일의 예입니다.

    #!ini
    [Connect]
    access_token = a.0101.123123123123
    refresh_token = r.0101.acbcabacbacbacb

L<INI 형식의 설정 파일|http://en.wikipedia.org/wiki/INI_file>은 L<CPAN의 Config::Tiny 모듈|https://metacpan.org/module/Config::Tiny>을
사용하면 쉽게 읽어오거나 쓸 수 있습니다.

    #!perl
    use Config::Tiny;
    use Net::API::Gett;
    
    #
    # GE.TT object
    #
    
    my $config = Config::Tiny->read( '/home/your_id/.gett/config' );
    my $gett = Net::API::Gett->new(
        access_token  => $config->{Connect}{access_token}  || q{},
        refresh_token => $config->{Connect}{refresh_token} || q{},
    );

필요한 부분은 모두 갖춰졌습니다. 남은 작업은 이 모든 것을 합치는 것이죠.
다음은 C</home/your_id/gett.pl> 스크립트의 전체 소스 코드입니다.

    #!perl
    #!/home/your_id/perl5/perlbrew/perls/perl-5.14.1/bin/perl
    
    use 5.010;
    use strict;
    use warnings;
    
    use Config::Tiny;
    use Const::Fast;
    use File::Basename;
    use File::HomeDir;
    use File::Spec::Functions;
    use IPC::Run qw( run );
    use Net::API::Gett;
    use Try::Tiny;
    
    # Get API Key from http://ge.tt/developers
    
    const my $GETT_DIR => catfile( File::HomeDir->my_home, '.gett');
    const my $CONF     => catfile( $GETT_DIR, 'config' );
    const my $LOG      => catfile( $GETT_DIR, "$$.log" );
    const my @ZENITY => (
        'zenity',
        '--text-info',
        '--width=600',
        '--height=200',
        '--title=GE.TT 파일 업로드',
    );
    
    die "Usage: $0 <file> [ <file> ... ]\n" unless @ARGV;
    
    open my $log, '>', $LOG
        or die "cannot open log file: $!\n";
    
    #
    # GE.TT object
    #
    my $config = Config::Tiny->read( $CONF );
    my $gett = Net::API::Gett->new(
        access_token  => $config->{Connect}{access_token}  || q{},
        refresh_token => $config->{Connect}{refresh_token} || q{},
    );
    
    #
    # Check access token is valid or not
    # Then update access token
    #
    say $log 'Check access token';
    check_access_token($gett);
    if ( $gett->access_token ne $config->{Connect}{access_token} ) {
        $config->{Connect}{access_token} = $gett->access_token;
        $config->write( $CONF );
    
        say $log 'Update access token: ' . $gett->access_token;
    }
    
    #
    # Share files
    #
    my @files;
    for my $file ( @ARGV ) {
        unless ( -f $file ) {
            say $log "$file is not exists";
            next;
        }
    
        my $file_obj = share($gett, $file);
        if ($file_obj) {
            push @files, {
                name => $file,
                obj  => $file_obj,
            };
            say $log "Sharing: " . $file_obj->url . " - $file";
        }
        else {
            say $log "Sharing failed: $file";
        }
    }
    
    #
    # Notify the result to user
    #
    my $result = "파일 업로드가 완료되었습니다.\n\n";
    $result .= join "\n", map { $_->{obj}->url . " - $_->{name}" } @files;
    run( \@ZENITY, \$result );
    
    sub check_access_token {
        my $gett = shift;
    
        #
        # Check access token is still valid and update it
        #
        if ( $gett->access_token ) {
            try {
                $gett->my_user_data;
            }
            catch {
                say $log "access_token is invalid or outdated.";
                if ( $gett->refresh_token ) {
                    unless ( $gett->login ) {
                        say $log 'cannot login GE.TT';
                        die;
                    }
                }
                else {
                    say $log 'refresh_token or valid access_token is needed.';
                    die;
                }
            };
        }
        else {
            unless ( $gett->login ) {
                say $log 'cannot login GE.TT';
                die;
            }
        }
    }
    
    sub share {
        my ( $gett, $file ) = @_;
    
        my $basename = basename($file);
        my $file_obj = $gett->upload_file(
            title    => '[gett.pl] ' . $basename,
            filename => $basename,
            contents => $file,
        );
        
        return $file_obj;
    }

[][]
첫 줄의 쉬뱅 라인에 C<#!/home/your_id/perl5/perlbrew/perls/perl-5.14.1/bin/perl>처럼
전체 Perl 경로를 기입한 점을 유의하세요.
시스템 Perl을 사용한다면 상관없지만 C<perlbrew>를 사용하거나 또는
직접 설치한 Perl을 사용한다면 반드시 전체 경로를 기입 해야 합니다.
그렇지 않으면 노틸러스 동작이 실행시킬때 기본 Perl인 C</usr/bin/perl>을
이용해서 스크립트를 실행시키므로 필요한 모듈이 설치되지 않았다던가
하는 문제로 인해 제대로 실행되지 않을 수 있기 때문입니다.


=head2 Send to GE.TT!!

이제 노틸러스에서 GE.TT 사이트로 파일을 공유해볼까요?
노틸러스에서 하나 이상의 파일을 선택한 다음 마우스 오른쪽
버튼을 눌러서 C<Send to GE.TT> 항목을 선택합니다.

=for html <img src="2011-12-11-08.png" alt="GE.TT로 파일 공유하기" />
<br />

I<그림 8.> GE.TT로 파일 공유하기

C<gett.pl> 스크립트는 파일 업로드에 성공한 항목의 결과를 모두 모아서
C<zenity>에게 보내주므로 일정 시간이 지나면 Gnome 데스크탑 화면에
결과를 보여줍니다.

=for html <img src="2011-12-11-09.png" alt="성공!!" width="700" />
<br />

I<그림 9.> 성공!! L<(원본)|2011-12-11-09.png>

실제 GE.TT 사이트에 로그인해서 확인해보면 정상적으로
파일 업로드에 성공했음을 알 수 있습니다.
이제 링크를 필요한 사람에게 알려주는 일만 남았네요. :)

=for html <img src="2011-12-11-10.png" alt="GE.TT 사이트에서 확인한 화면" width="700" />
<br />

I<그림 10.> GE.TT 사이트에서 확인한 화면 L<(원본)|2011-12-11-10.png>


=head2 정리하며

사실 GE.TT 서비스는 쉐어와 파일이라는 개념을 두고 쉐어 안에
여러 개의 파일을 넣어서 공유할 수 있습니다.
즉 쉐어가 일종의 디렉터리 또는 파일을 감싸는 보자기인 셈입니다.
현재의 구현은 각각의 파일에 대해 각각의 쉐어를 생성해서 
하나의 쉐어에 하나의 파일이 저장되도록 했습니다.
노틸러스에서 선택해서 C<Send to GE.TT>를 실행시키는 경우
해당 파일들은 하나의 쉐어를 생성하고 여러 파일이 포함되는
방식으로 구현하는 것이 더 편리할 것입니다.
이 부분은 C<Net::API::Gett> 모듈 문서를 참고해서 스크립트를
약간만 수정하면 처리할 수 있는데 이 부분은 여러분에게 맡기도록 하죠.

리눅스는 멋진 운영체제입니다.
Gnome은 멋진 데스크탑 환경입니다.
Perl은 멋진 언어입니다.
이 세 가지 멋진 녀석들이 합쳐지면 그 시너지 효과는 정말 대단합니다.
Gnome의 유연한 구조 덕에 사용자는 원하는 고급 기능을
정말 손쉽게 시스템에 통합해 추가할 수 있습니다.
Perl의 강력함과 CPAN의 방대함 덕에 수고스럽고,
조금은 번거로운 네트워크 프로그래밍은 너무나도 간단해집니다.
GE.TT 클라우드 서비스를 예로 들었지만 기사에서 설명한 모든 기법은
어떠한 서비스와 연동한다 하더라도 적용되는 부분입니다.

자, 이제 무엇을 제물로 삼아 노틸러스에 연동할지 주변을 둘러보세요!

Enjoy Your Perl! ;-)


use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-13.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    How to Use CPAN, Actually
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   y0ngbin


=head2 저자

L<@y0ngbin|twitter-y0ngbin> - aka 용사장 / Minivelo++ / 맞춤법 전문가


=head2 시작하며

 어떤 사람들을 Perl을 좋아합니다. 어떤 사람들은 Perl을 그다지 좋아하지 않습니다.
하지만 여러분이 어느쪽이든 상관없이 I<어떤 작업>을 해야하는 상황이라면
I<여러분이 필요한 무언가>는 L<CPAN|http://search.cpan.org/>에 이미 존재할 확률이 매우 높습니다.
CPAN은 단일 언어 공개 라이브러리 저장소 중에서 가장 큰 규모와 긴 역사,
튼튼한 커뮤니티를 가지고 있고, 지금 이 순간에도 그들만의 방식으로
계속 발전해 나가고 있기 때문입니다.

 심지어 어떤 사람들은 Perl을 I<CPAN을 사용하기 위한 도구>라고 지칭할
정도로 Perl과 CPAN은 밀접한 관계를 맺고 있습니다.
하지만 실제로 CPAN을 충분히 활용하려면 책에서 다루는 내용을 익히는 것만으로는 조금 부족할 수 있습니다.
오늘은 우리가 I<실제로> CPAN을 사용하고자 할 때 알아야 할 내용을 I<실용적인 관점>에서 소개하겠습니다.

이 글에서 대문자 CPAN은 Perl의 CPAN 저장소를 지칭하고 소문자
C<cpan>은 CPAN을 사용하기 위한 L<CPAN 공식 프로그램|http://search.cpan.org/perldoc?App::Cpan>을 지칭합니다.


=head2 CPAN

CPAN은 Comprehensive Perl Archive Network의 약자입니다.
즉, 직역하면 '편리한 펄 저장소 네트워크' 정도입니다.
현재 102,000개 이상의 공개 모듈이 관리되고 있습니다.
Perl의 모듈은 Java의 이름 공간(Namespace)과 같은 개념으로서,
각각의 계층구조를 가지고 있으며 계층은 C<::>을 구분자로 사용합니다.
C<Net::>, C<Algorithm::>과 같이 최상위 이름 공간은 모듈의 역할을 설명합니다.
C<Moose::>나 C<Catalyst::>와 같이 독특한 최상위 이름 공간으로 등록되는 경우도 있습니다.
이는 엄숙함을 강요하지 않는 자유로운 펄 문화의 단면을 보여주는 부분이기도 합니다.

CPAN은 모듈 저장소인 동시에 MSDN과 같은 거대한 문서 저장소이기도 합니다.
이런 환경은 L<POD(Plain Old Documentation format)|http://perldoc.perl.org/perlpod.html>라고 불리는 펄의 마크업 시스템 덕입니다.
POD를 통해 소스코드에 문서를 포함할 수 있습니다. CPAN에 등록되는 모든 펄 모듈은 관습적으로 정해진 양식의
POD 문서가 포함되어 있습니다. 그 외에도 방대한 규모의 지침서와 문서가 엮여 있기도 합니다.

=over

=item -

L<perltoc|cpan-perltoc>: 펄 내장 문서 목록


=item -

L<Catalyst::Manual::Intro|cpan-cmi>: 카탈리스트 메뉴얼 목록


=item -

L<Catalyst::Manual::Cookbook|cpan-cmc>: 카탈리스트 요리책


=back

Perl과 CPAN을 좋아하는 사람들이 가장 자부심을 느끼는 부분은
CPAN의 방대한 규모뿐만 아니라 엄격하게 관리되는 모듈의 품질입니다.
오랜 기간동안 복잡한 의존 관계를 가진 프로젝트를 관리해
보신 분이라면 하위 호완성을 지키면서 기능을 추가해 나가는 것이 마치
I<뒤를 바라보며 앞으로 뛰는 것>처럼 힘들고 어려운 일이라는 점을 잘 알고
있을 것입니다.
하지만 Perl과 CPAN 모듈은 오래 전부터 각 모듈 단위의 테스트를 엄격하게 지키고 있고
I<지원하는 모든 Perl 버전에서의 플렛폼 별 모듈 동작 상황>을 L<자동으로 테스팅하고 관리|http://www.cpantesters.org/>
하는 플렛폼을 만들어 유지하고 있습니다.

C 언어로 작성된 코드가 포함된 XS 모듈도 존재하기 때문에
모든 CPAN 모듈이 완벽한 이식성을 가지고 있는 것은 아닙니다.
하지만 여전히 각 플랫폼, 각 펄의 버전, 각 모듈의 의존성이 서로 어떻게
영향을 끼쳐 문제가 발생했는지 기록하고, 이를 통해
거대한 산은 계속 개선될 수 있습니다.
(예를 들어 Advent Calendar 2일차에 소개된 L<File::Map|http://search.cpan.org/perldoc?File::Map> 모듈의
Perl 버전별 Windowns 플랫폼 호환은 L<여기에서|http://www.cpantesters.org/distro/F/File-Map.html> 확인할 수 있습니다.)

그 밖에 CPAN은 L<RT|http://rt.cpan.org/>라는 이슈트레커를 이용해 모듈별로 이슈를 관리하고 있으며
CPAN에 모듈을 등록하기 위한 내부 개발자 등록 시스템으로 L<PAUSE|http://pause.perl.org/>를 운영하고 있습니다.


=head2 perl과 cpan

지금까지 CPAN의 특징과 장점에 대해 알아보았습니다.
이제 실전을 위해 여러분의 환경에서 자유자재로 perl과 cpan을 사용하는데
알아야 할 것들을 살펴봅시다.


=head3 '내가 사용하는 펄은 무슨 펄이지?'

펄 개발 환경을 구축하는데 있어 가장 먼저 확실히 짚고 넘어가야 할 것이 있습니다.
바로 여러분이 현재 사용하고 있는 C<perl>이 어떤 perl인지 확인하는 것입니다.
아래와 같이 두 가지 사항을 확인합니다. (*NIX 기준)

    #!bash
    $ which perl
    $ perl -V

C<which perl>을 통해 여러분이 현재 사용하고 있는 perl 바이너리의 경로가 무엇인지 확인하고
C<perl -V>를 통해 그 실행 파일이 참조하는 환경에 등록된 C<@INC>가 무엇인지를 확인합니다.
C<@INC> 목록은 C<perl -V>의 긴 출력 중 가장 마지막 항목입니다.

시스템에 존재하는 perl마다 별도의 C<@INC>를 구성할 수 있기 때문에
어떤 환경에서 perl을 호출했는지에 따라 의도치 않게 문제가 꼬이는 경우가 있습니다.
무엇인가 상황이 잘못 돌아가고 있다고 느껴진다면 꼭 지금 놓인 perl의 환경을 확인해야 합니다.


=head3 @INC

perl과 CPAN을 잘 활용하기 위해 넘어야 하는 중요한 관문중 하나는 C<@INC>에 대한 이해하는 것입니다.
사실 C<@INC>는 별로 특별하거나 어려운 개념이 아닙니다.
C<@INC>는 java의 C<CLASSPATH>, php 의 C<include_path>, 또는 우리가 shell
에서 사용하는 C<PATH> 환경변수와 아주 비슷한 Perl의 내부 환경 변수입니다.
즉, 특별한 인자없이 실행한 perl은 특정 모듈을 찾을 때,
이전에 다룬 것과 같이 C<perl -V>로 확인한 C<@INC> 배열에 등록된
디렉토리들을 I<순서대로> 참조하여 모듈의 이름 공간에 해당하는 파일을 찾습니다.

이 때, C<@INC>에 등록된 디렉토리는 아래와 같이 구성되어 있습니다.

    #!plain
    |-- 5.12.2
    `-- site_perl
        `-- 5.12.2

위의 예에서 상위의 5.12.2 디렉터리 밑에는 많은 파일과 디렉터리가 놓입니다.
이 디렉터리에는 기본 모듈(또는 코어 모듈, Core Modules)이 자리합니다.
기본 모듈이란 펄이 배포될 때 기본적으로 같이 배포되는 모듈로서 실제 펄과 한 몸으로 생각하는 환경입니다.
여러분이 Perl 5.10 버전을 사용한다면 File::Basename, Encode와 같은 모듈이 반드시 존재한다고 가정할 수 있습니다.
펄 버전별 기본 모듈은 조금씩 변화가 있었기 때문에 자세한 변경 사항은
각 펄 버전마다 같이 배포되는 L<펄 델타 문서|http://search.cpan.org/perldoc?perl5141delta>에서 확인할 수 있습니다.

반면, site_perl 디렉터리 하위에 펄 버전 디렉터리가 있는 것을 볼 수 있습니다.
이 디렉터리는 바로 우리가 C<cpan> 명령 등을 통해 추가적으로 설치한 외부 CPAN 모듈이 저장되는 공간입니다.
즉, cpan을 통해 설치하거나 직접 압축 파일을 내려받아 설치했거나 상관없이 사용자가 추가적으로 설치한 모듈은
site_perl 디렉터리 하위의 해당 펄 버전 디렉터리 밑에 놓입니다.

일반적으로 코어 모듈은 수동으로 삭제하거나 변경을 하지않지만 site_perl에
저장된 모듈은 cpan이 따로 모듈 삭제 방법을 제공하지 않기 때문에 정말 필요하다면
직접 관련 파일을 삭제할 수도 있습니다.


=head2 드디어 cpan!

C<cpan>과 C<perl -MCPAN -eshell>은 B<같을수도 있지만 다를수도 있습니다.>
C<cpan>은 첫 줄의 shebang line에 의해서 해석기가 결정되는 펄 스크립트이기 때문에
쉘의 C<PATH> 문제로 실제 여러분이 의도한 perl과 다른 환경(C<@INC>)의 perl 환경에 모듈을 설치할 수도 있습니다.
혹시 cpan을 통해 설치한 모듈이 정상적으로 설치되었지만 찾을 수 없거나
의도한데로 동작하지 않는다면 꼭 먼저 B<어떤 펄>을 통해 실행되었는지 찬찬히 따져보아야 합니다.
또 상황에 따라 CPAN 클라이언트를 실행하는 방법으로
C<cpan>이외에 C<perl -MCPAN -eshell>을 기억하고 있으면 유용합니다.
이렇게 호출할 경우 적어도 하나의 변수의 개입을 줄일 수 있기 때문입니다.


=head3 cpan

cpan은 기본적으로 쉘과 같은 형태로 동작합니다. cpan의 쉘에서 사용할 수 있는 주요 명령은
C<h>를 입력해 확인할 수 있습니다. 주로 쓰는건 다음 3가지 입니다.

=over

=item -

i [word]: 모듈 검색


=item -

install [module]: 모듈 설치


=item -

upgrade: 현재 설치된 전체 모듈의 최신상태 유지


=back

여러분은 보통 모듈 설치시에 선의존관계가 있는 모듈을 설치하고자 할 것입니다.
이 경우, cpan 명령을 실행할때 C<PERL_MM_USE_DEFAULT> 환경변수를 참(C<1>)으로 설정하면 cpan이 추가적인 질문없이
의존 모듈을 모두 설치해 줍니다. (cpanm이나 최신 버전의 cpan에서는 이것이 기본 동작입니다.)


=head3 .cpan

마지막으로 CPAN을 쓰기 위해 알아야하는 것은 C<$HOME/.cpan>입니다.
실제로 우리가 C<cpan> 명령을 통해서 모듈을 설치할때 사용하는 모든 파일들은
이 디렉터리에서 관리됩니다.
여기서 알아야할 주요 파일/디렉토리는 아래와 같습니다.

=over

=item -

CPAN/MyConfig.pm: 내가 설정한 C<cpan>의 설정내용이 들어있습니다. 이 파일을 삭제하면 C<cpan>의 설정을 다시할수 있습니다.


=item -

build/: cpan을 통해 설치한 모든 모듈의 build가 존재합니다.


=item -

sources/: cpan을 통해 내려받은 모든 모듈의 압축된 원본 소스파일을 보관합니다.


=back


=head2 cpan을 넘어서

사실 지금까지 알아본 cpan의 사용 방법은 최근 1~2년 사이에 조금 '구식'이
되어버린 방법입니다. 본질적으로 CPAN을 사용하는 방식에는 크게
달라진 것이 없지만 최근 펄 커뮤니티의 분위기는 cpan을 좀더 쉽고
효율적으로 사용할수 있도록 도와주는 빛나는 아이디어들이 빠르게 채택되며
지지를 받고있는 상황입니다. 위에서 살펴본 내용을 충분히 이해했다면
아래 살펴볼 모듈을 만나는 순간 cpan이 부족했던 2%를 채워주는 통쾌함을
느낄 수 있을 것이라 확신합니다. :)


=head3 local::lib - root 권한없이 모듈을 설치하자

L<local::lib|http://search.cpan.org/perldoc?local::lib>:
여러분이 사용하는 펄(C<which perl>)이 시스템의 기본 펄(C</usr/bin/perl>)이라면
일반적으로 C<@INC>는 C</usr/local/lib> 이하입니다.
C<root> 권한이 없는 일반 사용자라면 이 경로에 쓰기 권한이 없을 것입니다.
root 권한으로 cpan을 실행해 설치할 수도 있지만 root 권한을 획득할 수 없는 환경일 수 있습니다.
또 시스템에서 기본 펄의 모듈을 사용할 것이기 때문에 이 모듈을 새로 설치하면 충돌이 발생할 수도 있습니다.
따라서 별도의 독립된 구성의 CPAN 라이브러리를 구성하는 것이 좋습니다.
C<local::lib>을 사용하면 깔끔하게 사용자별로 독립된 개발환경을 구축할 수 있습니다.

local::lib의 동작방식은 간단합니다. perl 실행기는 실행시점에 C<PERL5LIB>
환경변수를 참조해서 등록되어있는 PATH를 C<@INC>의 I<첫번째>로 등록합니다.
local::lib은 shell이 실행될때 구동되는 설정파일(C<.profile>, C<.bash_profile>)에
PERL5LIB을 등록해주는 간단한 일을 추가합니다.

local::lib을 사용하면 자신이 원하는 모듈을 root 권한없이 자유롭게
설치하고 사용할 수 있습니다.


=head3 perlbrew - 최신 버전의 perl을 사용하자

[perlbrew][cpan-perl-brew]:
시스템에서 제공하는 펄의 버전이 낮다면 가장 먼저
생각할 수 있는 방법은 홈 디렉토리에 직접 펄 소스를 내려받고
컴파일해서 사용하는 것입니다. 실행 파일 생성을 위해 필요한 기본적인
컴파일러와 개발환경만 구축되어있다면 펄을 직접 빌드해 사용할 수 있습니다.

물론 perlbrew를 사용하지 않고 펄 소스를 직접 내려받고 적절한 prefix 옵션을 주고
컴파일해 설치해도 동일한 효과를 볼 수 있지만
perlbrew는 사용자가 해야하는 일련의 과정들을 자동으로 진행해 주기때문에 좀 더
관리하기 수월합니다.

perlbrew를 사용하면서 얻을수 있는 부수적인 이점은, 앞서 소개한 local::lib의
효과를 자연스럽게 포함한다는 점입니다. perlbrew를 통해 설치된
perl의 기본적인 prefix는 C<$HOME/perl5/perlbrew/perls>이기 때문에
설치된 사용자가 C<@INC>에 쓰기 권한을 가지고 있기 때문입니다.
또, perlbrew를 통해 서로 다른 버전의 펄을 여러개 설치하고 그 사이를
명령을 통해 쉽게 전환할 수 있습니다.

perlbrew를 통해 펄을 설치할 때 일반적으로 많이 사용하는 쓰레드 지원을 켜는 옵션은
다음과 같습니다.

    #!bash
    $ perlbrew -v install perl-5.12.3 -D=usethreads


=head3 minicpan - 빠르고 쾌적하게 오프라인 환경에서 CPAN을 사용하자

L<minicpan|http://search.cpan.org/perldoc?minicpan>\:
CPAN은 전세계의 많은 L<로컬 미러|http://www.cpan.org/SITES.html>를 확보하고 있습니다.
적절한 미러를 선택하면 빠르게 모듈을 받을 수 있습니다.
하지만 의존성이 높은 모듈을 네트워크를 통해 받는 시간이 부담스러울 수 있습니다.
또는 장기간 오프라인에서 작업을 해야하는데 필요한 모듈과 그 의존관계의
모듈을 미리 파악할수 없는 상황이라면 minicpan이 아주 적절한 해결책이 됩니다.

minicpan은 현재 CPAN 저장소에서 제공하는 모든 모듈의
최신버전을 특정 리모트 서버에서 내려받아 로컬에 저장합니다.
간단한 minicpan 명령을 통해 102,000여 개의 CPAN 모듈 전체를 최신 버전으로 내 PC에
내려받을 수 있습니다. 총 차지하는 크기는 약 2GB입니다.
(2011년 12월 기준 CPAN 전체 모듈의 최신버전 크기는 약 1.9GB입니다.
이 기사의 초고를 썼던 2011년 3월에는 1.3G였습니다.)

minicpan이 하는 일은 모듈을 내려받는 일이 전부이므로 실제 cpan이 해당 경로를
참조하도록 하려면 cpan의 설정을 수정해야 합니다.

    #!bash
    minicpan -l /Users/yongbin/perl5/minicpan -r http://cpan.mirror.cdnetworks.com/

예를 들어 위와 같이 저장소를 전부 내려받았다면, C<cpan>을 싱행한 뒤 CPAN의 명령행에

    #!bash
    o conf urllist unshift /Users/yongbin/perl5/minicpan/
    o conf commit

위 두줄을 입력하거나. 혹은 C<$HOME/.cpan/CPAN/MyConfig.pm>을 편집해 urllist 최상위에 local mirror 경로를 넣습니다.


=head3 cpanm & cpan-outdated - CPAN을 사용하는 가장 현대적인 방법

L<cpanm|http://search.cpan.org/perldoc?App::cpanminus>과 L<cpan-outdated|http://search.cpan.org/perldoc?cpan-outdated>는 재작년부터 펄 커뮤니티 내부에서
큰 인기를 끌고 있는 CPAN 클라이언트입니다. cpanm는 펄에 내장되어있는 cpan과 cpanplus와 같은
CPAN 클라이언트보다 좀 더 가볍고 쉽게 CPAN을 사용하도록 하기 위해서 제작되었습니다.
cpanm의 사용방법은 cpan과 크게 다르지 않습니다. cpan은 기본적으로 쉘 환경을 제공하지만
cpanm은 명령행만 제공합니다. 하지만 이것으로 충분히 원하는 작업을 수행할 수 있습니다.

    #!bash
    # Fey::ORM 에 필요한 모든 의존모듈을 찾아 설치합니다
    $ cpanm Fey::ORM
    
    # 의존성 에러 구문에서 copy & paste 하기 편리합니다(cpan에도 채용됨)
    $ cpanm Fey/ORM.pm
    
    # cpanm with minicpan
    $ cpanm --mirror ~/mirrors/minicpan/ --mirror-only Fey::ORM
    
    # 현재 작성하는 모듈과 모든 의존모듈을 시스템에 설치합니다
    $ cpanm .                                                   

cpanm은 CPAN 저장소에 모듈을 시스템에 설치하지만 cpan과는 다른 메타정보를 참조하며 내부적인
설치방법도 조금 다릅니다. 하지만 최종사용자 입장에서는 좀더 빠르고 간편하게 CPAN을 사용할 수 있습니다.

cpanm이 cpan shell의 install 관련 명령을 보충해 준다면 cpan-outdated는 cpan 쉘의 upgrade 명령을 보충해 줍니다
앞서 언급했던 것처럼 CPAN에 올라간 모듈은 매일 업데이트 되고 있기 때문에 오늘 설치한 모듈이
언제 구버전이 될 지 알 수 없습니다. 따라서 수시로 사용자는 자신이 보유한 모듈을 최신 상태로 유지해야합니다.
기존에 설치된 모듈의 업데이트를 위해 사용하는 도구가 cpan-outdated입니다. 사용방법은 다음과 같습니다.

    #!bash
    $ cpan-outdated | cpanm


=head2 정리하며

이처럼 CPAN은 크고 방대하며 견고하게 관리되고 있지만 그렇다고
필요 이상으로 엄하게 제한하지도 않습니다.
의미있는 작업을 모듈로 만들었는데 설령 그 모듈이 소수의 사람에게만 의미가 있고
그 구현이 여러면에서 아직 서툴더라도
여러분은 그것을 CPAN에 올릴 수 있을 것입니다.

CPAN은 그 자체가 거대한 생태계와 같은 구조를 가지고 있습니다.
모든 모듈들이 스스로를 위해 존재하며, 그런 존재가 모여 다양성을 확보합니다.
다양성은 특정 문제를 해결하는데 있어 우리가 선택할수 있는 다양한 기회를 제공합니다.

한 때 옳다고 생각한 방법이 틀려 다시 돌아가고자 할 때에도 모두의 위험을 줄여줄 수 있습니다.
이는 다수를 위한 소수의 안전판을 제공하는 것입니다. 또 모든 모듈은 스스로 진화해 나갑니다.
때로는 비슷한 역활을 하는 모듈끼리 경쟁하며 최종적으로는 사람들이 더 많이
선택한 모듈들이 살아남으며 오랜시간 관리되지 않는 모듈은 한때는
유용했더라도 자연스럽게 도퇴됩니다. 이런 CPAN의 모습은 펄이 가지고 있는
기본 철학을 충실하게 보여주고 있습니다.

CPAN에 익숙하지 않는 분들이 CPAN을 사용하는데 알아야하는 내용들을
제 경험에 비추어 안내 형식으로 정리해 보았습니다.
이 글을 통해 조금이나마 사람들이 펄과 CPAN을 이용해 문제를 해결하는데
도움이 되었기를 바랍니다.
그리고 이 글을 통해 보다 많은 분들이 CPAN을 접하게 되기를 바랍니다.
또 언젠가 혼자 쓰기는 아까운 멋진 무언가를 만들게 된다면
다같이 가벼운 마음으로 CPAN을 통해 공유하며 우리가 사는 세상을 조금 더 풍성하게 만들어 가게
되기를 바랍니다.

감사합니다.


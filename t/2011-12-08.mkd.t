use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-08.mkd';
is markdown_to_pod($file), get_pod(\*DATA), "converting $file";

__DATA__
=encoding utf8

Title:    FormNa게 Form 생성하기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   mintegrals


=head2 저자

L<@mintegrals|http://twitter.com/#!/mintegrals> -
랩의 귀재, I<MC.민나이퍼>라고 불리며 현재 Silex에서 I<여자>를 맡고 있다.
본의 아니게 올해 Seoul.pm 크리스마스 달력에서도 I<여자>를 맡게 되었다.
Perl과 Catalyst 웹프레임워크, 발사믹 목업, git을 주로 사용해 개발하고 있다.
현업에 갓 입문한 새내기 개발자, 하지만 Perl 영재교육을 받으며 무서운 속도로 성장중.
Perl에 입문한 첫 해에 크리스마스 달력을 쓰지만 정작 자신의 글이
올라오는 날에는 수술로 인해 아무것도 보지못한다.
눈을 뜨기 위해 공양미 150석이 필요하다는 후문.


=head2 시작하며

I<부제 : 가변데이터에 대해 문서 자동으로 생성하기>

생활하다보면 특정한 문서 틀이 필요할 때가 있습니다.
그럴 때 우리는 I<'서식 파일'>, I<'보고서 양식'>을 검색하곤 합니다.
그리고 적당한 틀이있는 파일(주로 DOC 또는 HWP)을 다운받은 후
특정 위치에 원하는 내용을 내용을 채워넣습니다.
이렇게 양식 파일을 다운 받는 것은, 일정한 틀은 유지하면서
데이터만 변경해서 문서를 만들어야 할 때가 많기 때문입니다.
일상 생활의 예를 들면 마트에서 주는 영수증부터, 회사의 거래내역서,
이력서, 주소록, 월급 명세서 등 다양합니다.
이러한 보고서 서식(form)을 제공하는 사이트로 국내에는
L<비즈폼|http://www.bizforms.co.kr>이나 L<예스폼|http://www.yesform.co.kr> 등이 있습니다.
하지만 이런 사이트에서 제공하는 파일을 이용하면 한계가 있습니다.
한 두장 정도는 어떻게든 만들 수 있겠지만
주기적, 정기적으로 바뀌는 내용을 갱신해야 한다거나,
많은 양의 자료를 바꿔가며 뽑아내야 한다면 현실적으로 무리가 있습니다.
바로 이때 Perl과 ODF를 사용하면, 이러한 Form들을 FormNa게 찍어낼 수 있습니다.


=head2 준비물

필요한 모듈은 다음과 같습니다.

=over

=item -

L<CPAN의 OpenDocument::Template 모듈|https://metacpan.org/module/OpenDocument::Template>


=item -

L<CPAN의 Catalyst 모듈|https://metacpan.org/module/Catalyst>


=back

직접 L<CPAN|http://www.cpan.org/>을 이용해서 설치한다면 다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ sudo cpan OpenDocument::Template Catalyst

사용자 계정으로 모듈을 설치하는 방법을 정확하게 알고 있거나
C<perlbrew>를 이용해서 자신만의 Perl을 사용하고 있다면
다음 명령을 이용해서 모듈을 설치합니다.

    #!bash
    $ cpan OpenDocument::Template Catalyst


=head2 오픈도큐먼트와 함께라면

오픈도큐먼트와 함께라면 문서를 찍어내는데 거리낄 것이 없습니다.
지금부터 ODT를 이용하여, 문서를 찍어낼 것입니다.
ODT를 이용해서 문서를 생성하기 위해 우선 ODF 파일의 구조를 파악해야합니다.


=head3 ODF: OpenDocumentFormat

오픈도큐먼트 형식(ODF)은 초기 L<오픈오피스|http://www.openoffice.org>에서 XML파일 포맷을
기반으로 구현한 것을 L<OASIS 컨소시엄|http://www.oasis-open.org>(Organization for the Advancement
of Structured Information Standards)이 표준화 한 파일 형식입니다.
이 포맷은 오픈 XML기반 문서 파일 포맷으로, 기준에 따라 재사용 가능하고,
텍스트 문서(ODT), 스프레드시트(ODS), 차트 및 그래픽 요소(ODG)등에 이용됩니다.

ODF포맷을 사용한 대표적인 응용 프로그램 및 오피스 제품은 다음과 같습니다.

=over

=item -

L<LibreOffice|http://www.libreoffice.org>


=item -

L<OpenOffice|http://www.openoffice.org>


=item -

L<AbiWord|http://www.abisource.com>


=item -

L<KOffice|http://www.koffice.org>


=item -

L<Google Docs|https://docs.google.com/>


=item -

L<MS Office 2010/2007 SP2|http://office.microsoft.com/ko-kr/>


=back


=head3 ODT: OpenDocumentText

즉, ODT란 오픈도큐먼트 포맷(ODF)이 사용된 워드프로세서 텍스트 문서 입니다.
그럼 ODT는 어떻게 구성되어 있을까요?
오픈도큐먼트포맷(ODF)은 일반적으로 여러 개의 XML 문서와 이진 파일을
하나의 ZIP 컨테이너 안에 묶는 형태입니다.
확장자는 C<.odt> 형식을 따르지만 실제로는 ZIP 압축 파일인 것이죠.

ODT 뿐만 아니라 일반적인 오픈도큐먼트포맷(ODF)의 파일 구성을 살펴봅시다.
오픈오피스(또는 ODF 쓰기를 지원하는 프로그램)를 열어
아무 글이나 작성한 후 C<sample.odt> 파일로 저장합니다.
이제 C<unzip> 유틸리티를 써서 압축을 풀고 디렉터리 구조가 어떤지 살펴보죠.

    #!bash
    $ unzip sample.odt
    Archive:  sample.odt
     extracting: mimetype
      inflating: content.xml
      inflating: manifest.rdf
      inflating: styles.xml
     extracting: meta.xml
      inflating: Thumbnails/thumbnail.png
      inflating: Configurations2/accelerator/current.xml
       creating: Configurations2/progressbar/
       creating: Configurations2/floater/
       creating: Configurations2/popupmenu/
       creating: Configurations2/menubar/
       creating: Configurations2/toolbar/
       creating: Configurations2/images/Bitmaps/
       creating: Configurations2/statusbar/
      inflating: settings.xml
      inflating: META-INF/manifest.xml

무언가 굉장히 많은 파일들이 생겼지만, 우리가 하려는 작업인
문서의 내용을 조작하고 생성하는 관점에서 다가간다면
핵심은 C<content.xml>, C<meta.xml>, C<styles.xml> 세 개의 파일입니다.
C<content.xml> 파일은 문서를 통해 보여지는 대부분의 내용을 담고있습니다.
일반적으로 텍스트, 표, 프레젠테이션 등의 구조와 내용입니다.
C<meta.xml> 파일은 문서의 MIME 타입을 기술합니다.
생성 시간, 최종 수정 시간, 문서 수정 시 걸린 전체 시간,
낱말/쪽/표/그림 개수 같은 문서 정보에 해당하는 항목들이 담겨있습니다.
C<styles.xml> 파일은 XML 형식으로 된 CSS라고 보면 됩니다.
글꼴(font), 인치 당 문자 수(pitch), 장식(decoration), 여백(spacing),
탭 위치(tab stop) 등 문서 편집시 이용할 수 있는 다양한 스타일이 정의되어 있습니다.


=head2 크리스마스 카드

내친 김에 연말이니, 크리스마스 카드나 연하장을 만들어볼까요?
어릴 적 크리스마스 카드를 쓰던 기억이 나나요?
처음엔 공 들여서 이런저런 이야기를 쓰다가 써야 할 친구들이 점차 늘어나면,
내용은 계속 똑같이 베껴 쓰면서 받는 친구의 이름만 바꾸곤 했죠. :-)
그렇다면 처음 한번만 예쁘게 카드를 꾸미고,
이름만 쓰면 크리스마스 카드가 나오게 할 수 있다면,
트위터나 페이스북 친구에게 크리스마스 카드를 돌리는 것은 일도 아니겠죠.
만들어 봅시다.

우선 오픈오피스를 열어 C<xmas-card.odt>를 만듭니다.
여기서 만든다는 것은 I<꾸미고 싶은 만큼 잔뜩 꾸미는 것>을 말합니다.
다음으로 자료가 변경해서 들어갈 부분을 표시합니다.
예를 들어, 크리스마스 카드의 경우 받는 사람의 이름이나 날짜는 계속 바뀌겠죠.
네, 그것이 핵심입니다!
문서를 계속 I<우려서> 자동 생성하되, 필요한 부분의 데이터만 받아서 이용하자구요!
그렇다면 가변 데이터에 해당하는 부분을 C<xxxx>라고 표시합니다.

=for html <img src="2011-12-08-1.png" alt="xxxx 표시" width="700" />
<br  />

I<그림 1.> xxxx 표시 L<(원본)|2011-12-08-1.png>

사실 여기까지(틀을 만드는 것) 진행했으면 벌써 절반 이상 된 것입니다.
이젠 C<unzip> 유틸리티를 사용해 C<xmas-card.odt> 파일의 압축을 풉니다.
압축을 푼 다음 C<content.xml>과 C<style.xml>만 남겨두고 나머지는 모두 지웁니다.

이제 C<content.xml>을 열어 C<xxxx>를 찾아봅니다.
C<xxxx>로 표시한 것은 가변 데이터의 위치를 쉽게 찾기 위해서 입니다.
수 많은 문자열 중 절대 겹치지 않을 것 같은 C<xxxx>로
표시했기 때문에 편집기의 찾기 기능을 잘 이용하면 손쉽게 편집할 수 있습니다.
그리고 C<xxxx>를 찾아서 사용할 변수로 바꿔줍시다.
이 때 변경할 변수라 함은 L<CPAN의 Template 모듈|https://metacpan.org/module/Template> 모듈에서
사용하는 문법을 이용한 변수이니 자세한 내용은 해당 모듈의 공식 문서를 확인하세요.

앗! 그런데 C<content.xml>을 열어보면 XML 형식인 만큼 바이너리 형식은 아니라서
읽을 수는 있지만 용량을 줄이기 위해 불필요한 빈 칸이 모두 제거되어
알아보기가 너무 힘들어 어떻게 수정해야 할지 막막합니다.
이럴 땐, L<CPAN의 XML::Tidy 모듈|https://metacpan.org/module/XML::Tidy>을 설치하고
다음 명령을 실행하면 들여쓰기가 잘되어 가독성이 높은 XML 파일로 바뀝니다.

    #!bash
    $ xmltidy content.xml

다시 C<xxxx>가 씌여있는 곳을 찾아봅니다.

=for html <img src="2011-12-08-2.png" alt="XML에서 xxxx가 있는 위치" />
<br  />

I<그림 2.> XML에서 xxxx가 있는 위치

네, 있습니다. 그럼 이부분의 값만 바꿔주면, 이 안에 넣고 싶은 데로 넣을 수 있겠죠?
이 부분을 템플릿 툴킷 형식인 C<[% name %]>, C<[% date.y %]>, ... 등으로 바꿔줍니다.

=for html <img src="2011-12-08-3.png" alt="xxxx 부분을 변환" />
<br  />

I<그림 3.> xxxx 부분을 변환

거의 다왔습니다. 이제는 Perl이 나설 차례입니다.
우선 템플릿을 이용해 ODT를 생성해줄 핵심 모듈인
L<CPAN의 OpenDocument::Template 모듈|https://metacpan.org/module/OpenDocument::Template>을
이용해서 우리가 원하는 크리스마스 카드를 생성하겠습니다.

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use utf8;
    use strict;
    use warnings;
    use DateTime;
    
    use OpenDocument::Template;
    
    my %content = (
        name => '이민선',
        date => {
            'y' => '2011',
            'm' => '12',
            'd' => '8',
        },
    );
    
    my $dt = DateTime->now( time_zone => 'Asia/Seoul' );
    my $time = sprintf(
        '%04d%02d%02d-%02d%02d%02d',
        $dt->year, $dt->month,  $dt->day,
        $dt->hour, $dt->minute, $dt->second,
    );
    
    my $template_dir = 'template';
    my $src          = 'template.odt';
    my $dest         = "result/$time-$name.odt";
     
    my %config;
    my $config{templates}{'content.xml'} = \%content;
     
    my $odt = OpenDocument::Template->new(
        config       => \%config,
        template_dir => $template_dir,
        src          => $src,
        dest         => $dest,
    );
    $odt->generate;

레퍼런스를 사용한다는 것을 빼면 코드 자체에 어려운 부분은 없습니다.
결국 핵심은 C<OpenDocument::Template> 객체를 생성하는 부분인데
객체 생성시 각각의 속성이 의미하는 부분을 살펴보면 다음과 같습니다.

=over

=item -

I<src>:          템플릿 원본 ODT 파일을 지정합니다.


=item -

I<config>:       변경될 내용들을 담고 있는 해시 레퍼런스입니다. 템플릿으로 사용하는 파일의 이름과 사용할 변수 정보가 들어있습니다.


=item -

I<template_dir>: C<config>에서 템플릿으로 사용할 파일을 저장하는 디렉토리입니다.


=item -

I<dest>:         자동으로 생성되는 ODT 파일의 경로를 지정합니다.


=back

이제 앞의 스크립트를 실행하면 크리스마스카드가 ODT로 생성됩니다.

완성입니다!

=for html <img src="2011-12-08-4.png" alt="크리스마스카드" width="700" />
<br  />

I<그림 4.> 완성된 크리스마스 카드 L<(원본)|2011-12-08-4.png>

이 코드를 조금 더 발전시키면 표준입력이나 명령행 인자로 변경될 값인
이름과 시간 정보를 받을 수 있도록 수정하면 훨씬 더 수월하게 ODT를
생성할 수 있겠죠? :)


=head2 카탈리스트와 함께 춤을!

지금까지 만든 내용을 이용해서 웹 응용으로 구현한다면
웹의 특성상 접근성이 대폭적으로 향상되겠죠?
예를 들어, 자주 사용하는 보고서나 문서의 서식을 처음 한 번만 만들어 놓고,
웹에 저장한 다음, 바뀔 부분을 브라우저의 폼을 이용해서 입력하게 한 후
버튼 클릭 한 번으로 미려한 문서가 나온다면... 와우! 생각해도 멋집니다!

그럼 FormNa게 한 번 만들어볼까요?

=for html <img src="2011-12-08-5.png" alt="Catalyst 로고" />
<br  />

I<그림 5.> Catalyst 로고

L<Catalyst|http://www.catalystframework.org>는 Perl의 대표적인 웹프레임워크입니다.
워낙 방대한 관계로 여기서 Catalyst의 자세한 부분을 다루지는 않습니다.
대신 다음 자료를 참고한다면 Catalyst 개발을 시작할 때 좋은 지침서가 될 것입니다.

=over

=item -

L<나의 Catalyst 답사기 - 2010년 Seoul.pm 크리스마스 달력|http://advent.perl.kr/2010/2010-12-12.html>


=item -

L<Catalyst 를 이용한 웹 서비스 개발 #1|http://jeen.tistory.com/93>


=item -

L<CPAN Catalyst::Manual 모듈|https://metacpan.org/module/Catalyst::Manual>


=item -

L<Catalyst 공식 위키|http://wiki.catalystframework.org/wiki/>


=item -

L<Catalyst 크리스마스 달력|http://www.catalystframework.org/calendar>


=back

잠깐! Catalyst가 최근 남미에서 L<W3C|http://www.w3.org/> 주최로 열린
L<공공정보 웹서비스화 경연대회|http://mdk.per.ly/2011/12/06/perl-rocks-latin-america/>에서
I<당당하게 우승>했다고 합니다.
개발의 신속 정확성을 다투는 대회에서 Rails, Django, CodeIgniter
등의 프레임워크를 제치고 우승했다면 인정해줘야겠죠? :)

지금부터 진행하는 작업은 작업 순서와 상관없지만,
컨트롤러와 뷰, ODT 템플릿 처리 세 부분 모두 완성되어야
FormNa는 서식 파일을 받아볼 수 있습니다.


=head3 컨트롤러

사용자가 웹에서 입력한 값을 이용해 서식 파일을 만들고자 합니다.
C<form_create_do> 컨트롤러는 C<form_index.tt> 파일에서 넘겨 준 변수를
가져와 C<content.xml>에 넘겨줍니다.

    #!perl
    sub form_create_do :Chained('index') :PathPart('form_create_do') :Args(0) {
        my ( $self, $c ) = @_;
    
        my $subject        = $c->req->param('subject')        || q{};
        my $short_comment  = $c->req->param('short_comment')  || q{};
        my $detail_comment = $c->req->param('detail_comment') || q{};
        my $picture        = $c->req->param('picture')        || q{};
        my $phone          = $c->req->param('phone')          || q{};
        my $name           = $c->req->param('name')           || q{};
    
        my %formna_config;
        $formna_config{templates}{'content.xml'} = {
            subject        => $subject,
            short_comment  => $short_comment,
            detail_comment => $detail_comment,
            picture        => $picture,
            phone          => $phone,
            name           => $name,
        };
    
        my $time = sprintf(
            '%04d%02d%02d-%02d%02d%02d',
            $dt->year, $dt->month,  $dt->day,
            $dt->hour, $dt->minute, $dt->second,
        );
    
        my $tpl_dir = sprintf '%s/templates',     $c->config->{odt}{root_notice};
        my $src     = sprintf '%s/template.odt',  $c->config->{odt}{root_notice};
        my $dst     = sprintf '%s/result/%s.odt', $c->config->{odt}{root_notice}, $time;
       
        my $odt = OpenDocument::Template->new(
            config       => \%formna_config,
            template_dir => $tpl_dir,
            src          => $src,
            dest         => $dst,
        );
        $odt->generate;
        $c->log->debug('Generated $dst');
    
        $c->res->headers->content_type('application/vnd.oasis.opendocument.text');
        $c->res->headers->header( "Content-Disposition" => qq{attachment;filename="$time.odt";} );
        my $fh = IO::File->new( $dst, 'r' );
        $c->res->body($fh);
        undef $fh;
    }

C<form_create_do> 컨트롤러의 가장 아래쪽 다섯 줄의 코드는 생성한 ODT 파일을
다운로드 받을 수 있게 적절한 HTTP 응답 헤더를 만든 후 파일의 내용을
응답 본문에 뿌려줍니다.


=head2 # 뷰

값을 넘겨 줄 부분을 다음과 같이 폼을 이용해 사용자의 입력을 받습니다.

    #!xml
    [% meta.title = '전단지 생성' -%]
    <form  action="[% c.uri_for('form_create_do') %]"  method="post" enctype="multipart/form-data">
      <div>
      <label>제목</label>
        <input type="text" name="subject" />
      </div>
      ...(생략)...


=head3 content.xml

처음 크리스마스 카드를 만들 때 처럼 ODT를 생성한 후
C<content.xml> 파일을 변경합니다.

    #!xml
    <text:p text:style-name="Standard">[% subject %]</text:p>
    <text:p text:style-name="Standard">[% short_comment %]</text:p>
    <text:p text:style-name="Standard">[% detail_comment %]</text:p>
    <text:p text:style-name="Standard">[% picture %]</text:p>
    <text:p text:style-name="Standard">[% phone %]</text:p>


=head2 폼나는 FormNa!

앞의 같은 작업을 통해 자주 사용하지만, 만들기는 번거로운 몇 가지 틀을 만들었습니다.

=over

=item -

이력서


=item -

문어발 전단지


=item -

FTA 국회의원 상장 만들기


=back

드디어 완성되었습니다! L<폼나는 FormNa|http://formna.silex.kr>!

=for html <img src="2011-12-08-6.png" alt="폼나는 FormNa" width="700" />
I<그림 6.> 폼나는 FormNa L<(원본)|2011-12-08-6.png>

주의할 점은 이렇게 만든 문서는 ODF를 지원하는 도구 중에서
MS Office를 제외하고는 정상적으로 보입니다.
MS Office 최신 버전은 ODF를 지원한다고 하는데 이렇게 자동 생성한 경우
일부만 보여주고 중간에 오류를 출력하면서 렌더링을 멈추는 현상이 있습니다.
뭐... OpenOffice나 LibreOffice를 쓰면 되겠죠? 무료인데 안 쓸 이유가 없잖아요? ;-)


=head2 몇 가지 팁!


=head3 팁 하나.

C<xxxx>를 넣고 C<xxxx>를 찾아 변수를 바꾸는 작업을 해보면 꽤 귀찮습니다.
틀이 될 문서를 만드는 과정이라면 수도 없이 특정 문자를 변수로 변경해야 하는데
이를 해결하려면 애초에 C<template.odt>를 만들때 변수가 들어가야 하는 곳이라면
처음부터 C<[% .. %]>와 함께 넣으면 작업이 더욱 간편해집니다.


=head3 팁 둘.

ODT 파일에 C<뷁뷁샭략> 같은 문자가 들어가기도 합니다.
이것은 인코딩 문제로 Catalyst의 설정 파일에서 UTF-8을 설정하면 해결됩니다.

C<TT.pm> 모듈에는 C<<< ENCODING => 'utf8' >>>을 추가합니다.

    #!perl
    __PACKAGE__->config(
        TEMPLATE_EXTENSION => '.tt',
        render_die         => 1,
        ENCODING           => 'utf8',
    );

C<FormNa/Web.pm> 모듈에는 유니코드 인코딩 모듈을 추가합니다.

    #!perl
    use Catalyst qw/
        -Debug
        ConfigLoader
        Static::Simple
        Unicode::Encoding
    /;

마지막으로 Catalyst 설정 파일에도 추가합니다.

    #!plain
    <View Default>
        ENCODING utf8
    </View Default>


=head2 정리하며

이렇게 ODT와 L<OpenDocument::Template 모듈|https://metacpan.org/module/OpenDocument::Template>을 이용해
ODT를 만들 때의 가장 큰 장점은 I<일관된 예쁜> 보고서를 만들 수 있다는 것입니다.
실제로 회사에서 처리했던 업무가 이와 비슷했습니다.
데이터베이스에 저장한 모 대학병원 연구실의 연구별 예산을 필요할 때마다
즉석에서 ODT 파일을 생성한 다음 PDF로 변환해 사용자가 예산내역서를
다운로드 받을 수 있게 하는 작업이었습니다.
만들고 싶은 보고서 서식을 해당 도구를 적극적으로 이용해서 만들고,
반복문과 조건문 등을 적절히 사용해서 사용자 입력, 또는 데이터베이스의
자료를 잘 배치한다면 일관되면서도 미려한 문서를 마음껏 생성할 수 있습니다.


=head2 후기

평소에 쭉 해왔던 작업이라 빠른 시간 내에, 조사 및 구현, 기사 작성을
할 수있으리라고 생각했지만 오해였던 것 같습니다.
글을 쓸 수 있게 도와주신 L<@keedi|http://twitter.com/#!/keedi>님과
L<@y0ngbin|http://twitter.com/#!/y0ngbin>님께 감사드립니다.
또 막판에, 비루한 웹 UI에 희망을 불어넣어 준
L<@am0c|http://twitter.com/#!/am0c>군에게도 고마운 마음을 전합니다.
L<폼나는 FormNa|http://formna.silex.kr> 사이트는 proof-of-concept 단계의 예제에 가깝지만,
사용하시는 분들과 Perl 및 Catalyst를 공부하시려는 분들께 도움이 되길 바래봅니다.

Don't forget L<fork me on GitHub|https://github.com/mintegrals/FormNa>!! ;-)

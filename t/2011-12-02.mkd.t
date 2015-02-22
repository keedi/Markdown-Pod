use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-02.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    Perl 원라이너(one-liner)로 Octopress 따라잡기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   pung96


=head2 저자

L<@pung96|http://twitter.com/#!/pung96> - Perl 원라이너의 귀재, 블랙홀이 있을 것으로 추정되는
스위스 제네바와 핀란드를 오가며 중이온 연구에 매진 중인 물리학자,
하지만 Perl과 C++, 심지어 Python까지 자유자재로 구사하는 물리학자를 가장한 프로그래머,
훈훈한 외모로 인해 유부남임에도 불구하고 I<훈중년>이라는 별칭을 획득.


=head2 시작하며

한 줄의 Perl 코드로 필요한 알고리즘을 작성하는 Perl 원라이너(one-liner)는 매우 유용합니다.
간단한 코드를 작성할 때라던가, 쉘과 결합해서 사용해야 할 때라면 더더욱 그러하지요.
이미 세상에는 훌륭한 원라이너 문서가 많은데 이를 반복한다면 무척 지루한 일이겠죠.
대신 Ruby로 만든 L<GitHub|http://github.com> 블로그 툴인
L<Octropress|http://octopress.org/>를 Perl 원라이너로 살짝 흉내어
Perl 원라이너를 어떻게 쓸 수 있는지 살펴보겠습니다.


=head2 원라이너의 철학

원라이너란 명령줄에서 엔터키를 누르기 직전까지의 한 줄안에 원하는 동작을
실행시킬 수 있는 만큼 필요한 명령을 사용해서 코드를 작성하는 것을 말합니다.
그래서 원라이너는 I<간단하게> 쓰기 위한 도구인 만큼 I<최적화라던가 미학 따윈
소나 줘버려!>와 같은 마음가짐으로 내키는 대로 작성하면 됩니다.
사실 이 문서의 코드들도 이런 마음가짐대로 I<마구> 작성한 것들입니다. ;-)
또한 코드 안팎에서 쉘의 기능을 충실히 이용해야 한다는 점을 잊지 마세요.
C<system>이라던가 역따옴표, C<while> 구문, 환경 변수 등 가리지 않도록 합니다.


=head2 준비물

원라이너로 Octopress를 따라잡으려면 다음 항목들을 준비해야 합니다.

=over

=item -

GitHub 계정


=item -

블로그용으로 사용할 GitHub의 저장소


=item -

L<이미 만들어 놓은 예제 블로그|https://github.com/pung96/blog>


=item -

L<CPAN의 YAML 모듈|https://metacpan.org/module/YAML>


=item -

L<CPAN의 Text::Xslate 모듈|https://metacpan.org/module/Text::Xslate>


=item -

L<CPAN의 Text::Markdown 모듈|https://metacpan.org/module/Text::Markdown>


=back


=head2 미리 둘러보기

L<이미 만들어놓은 예제 블로그|https://github.com/pung96/blog>를 방문해보면,
Octopress에서 I<훔쳐온> 테마를 기반으로 한 아주 간단한 블로그를 볼 수 있습니다.
물론 Octropress에 비하면 아주 사소한 기능만을 구현했지만,
이 이상의 것을 구현하려 한다면 Perl 원라이너는를 사용하는 것은 적절하지 않습니다.
편집기를 열어서 모듈을 만드는 것이 좋겠지요. :-)

L<![Octopress 뺨치는 Perl 원라이너 블로그][img-01]|2011-12-02-1.png>

Octropress는 GitHub 저장소를 블로그로 만들기 위해
C<gh-pages>와 C<source> 두 개의 가지를 사용합니다.
C<gh-pages> 가지에서는 HTML 파일을 발행하며,
C<source> 가지는 실제 블로그 컨텐츠와 기타 여러 파일을 저장합니다.


=head2 디렉토리 구조

    #!plain
    -- blog                     # source 브랜치
      |-- _scratch              # 작업용 임시 디렉토리
      |-- _deploy               # html 디렉토리. ph-graphs 브렌치
      |-- .gitignore
      |-- init.sh               # 초기화 스크립트
      |-- build.sh              # 빌드 스크립트
      `-- source
          |-- _post             # 블로그 포스트 디렉토리
          |  |-- 2011-11-30-3rd-post.markdown
          |  |-- 2011-11-30-4th-post.markdown
          |  `-- 2011-11-30-first-post.markdown
          |-- _layout
          |  |-- default.html   # 기본 템플릿
          |  |-- index.html     # 첫 페이지용 블로그 포스트 템플릿(default.html에 include 됨)
          |  `-- post.html      # 각 페이지를 위한 블로그 포스트 템플릿(default.html 에 include 됨)
          `-- favicon.png, stylesheets, javascripts

C<.gitignore>를 보면  C<_scratch>, C<_deploy> 폴더는 C<source> 가지에 추가되지 않습니다.
Octropress의 구현을 살펴보기 전 까지는 C<_deploy> 폴더처럼 발행을 위한 디렉토리를
어떻게 관리할지에 대해 많은 고민을 했었는데, 이 방법은 생각도 못했네요.
단순히 소스용 가지와 발행용 가지 두 개를 만들어 다른 디렉토리로 관리하면 끝입니다.
천재...


=head2 출발!!

L<이미 만들어놓은 예제 블로그|https://github.com/pung96/blog>를 이용하는 방법을 기준으로 설명하겠습니다.
예제 블로그를 방문해 가벼운 마음으로 I<Fork>한 후 저장소를 클론합니다.

    #!bash
    git clone git@git.github.com:<username>/blog.git -b source
    cd blog
    ./init.sh

C<init.sh> 파일의 내용은 다음과 같습니다.

    #!bash
    git clone -b gh-pages git@git.github.com:<username>/blog.git _deploy
    mkdir -p _scratch

C<_deploy> 디렉토리와 C<_scratch> 디렉토리를 만들어주는 간단한 스크립트입니다.
C<<< <username> >>>은 당연히 바꾸어 주어야 겠지요?

C<build.sh> 파일은 작성한 마크다운 문서를 이용해 HTML 파일을 만들고
다시 GitHub로 밀어넣는 Perl 원라이너의 집합입니다. 
지금부터 C<build.sh> 파일을 분석해볼까요?


=head3 초기화

먼저 C<_deploy>, C<_scratch> 디렉토리를 깨끗하게 비우고
작업할 파일을 C<_scratch> 디렉토리로 복사합니다.

    #!bash
    rm -rf _deploy/* _scratch/*
    cp -a source/_posts/* _scratch/


=head3 블로그 포스트 파일 구성

블로그 포스트 파일을 메타 정보와 컨텐츠로 분리해야 합니다.
자, 이제 마크다운 파일을 살펴보죠.
파일의 형식은 Octopress의 블로그 포스트 형식을 그대로 사용합니다.

    #!yaml
    ---
    layout: post
    title: "4th-post"
    date: 2011-11-30 18:19
    comments: true
    categories: 
    ---
    
    # 4th post
    이곳이 블로그 내용을 적는 곳이죠.

안타깝게도 이 형식은 완전한 YAML 형식이 아니라서 약간의 지저분한 코드가 필요합니다.
먼저 제목 등의 정보가 저장된 부분을 추출해서 YAML 파일로 저장하고 나머지 부분을 남겨보겠습니다.

    #!bash
    perl -i -0 -mYAML=Load -ne'BEGIN{open$y, ">_scratch/posts.yml"}/^---\s*$(.*?)^---\s*$(.*)/sm;print$y "---\nfile: $ARGV", $1;print $2' _scratch/*.markdown

추출된 정보들은 파일 정보를 추가해 하나의 YAML 파일에 통합해 저장합니다.
이런 정보를 버클리 DB와 같은 본격적인 데이터베이스에 저장한 후 사용하는 것도 좋은 방법입니다.
하지만 YAML 역시 거의 완전한 텍스트 기반 데이터베이스로 사용할만하며,
파일 자체를 사람이 바로 읽을 수 있다는 큰 장점이 있습니다.


=head3 메타 정보 가공하기

우선 날짜에 따라 정렬해보겠습니다.
C<DumpFile>처럼 C<LoadFile("posts.yml")>을 사용할 수도 있지만
앞에서 무심코 C<-0>을 적어버렸기 때문에 그냥 파일을 읽어들여서
Load에 파일 내용을 통째로 넣었습니다.

L<CPAN의 DateTimeX::Easy 모듈|https://metacpan.org/module/DateTimeX::Easy>을 사용해
날짜 및 시간 정보(2011-11-30 18:19)를 파싱해서 정확한 값을 사용할 수도 있지만
여기서는 그냥 문자열 비교를 사용해 정렬하는 것으로도 충분했습니다. 

    #!bash
    perl -0 -MYAML=Load,Dump -ne'print Dump(sort{$b->{date}cmp$a->{date}}Load($_))' _scratch/posts.yml > _scratch/posts2.yml

순서에 따른 아이다와 포스트의 URL(예: C</blog/blog/2011/11/30/4th-post>)을 YAML DB에 추가합니다.
C</blog/blog> 이렇게 중복이 생겼네요. 그냥 넘어갑시다.

    #!bash
    perl -0 -MYAML=Load,Dump -ne'print Dump(map {$_->{file}=~/(\d+)-(\d+)-(\d+)-(.*?)\./;$_->{url}="blog/$1/$2/$3/$4";$_->{iid}=$id++;$_}Load($_))' _scratch/posts2.yml > _scratch/posts.yml

잘 추출되어 정렬되었는지, 필요한 정보가 추가되고 있는지
L<CPAN의 Data::Dumper 모듈|https://metacpan.org/module/Data::Dumper>을 이용해 확인해봅시다.
C<Data::Dumper> 모듈은 원라이너 코딩시 가장 많이 사용하는 모듈 중의 하나입니다.

    #!bash
    perl -0 -MYAML=Load -MData::Dumper -ne'print Dumper Load($_);' posts.yml

두개의 YAML 파일을 관리하는 것은 귀찮으니 앞으로 쓰일 YAML 파일들을 하나로 통합해 버립니다.
C<cat>으로 합치면 간단하게 끝납니다.

    #!bash
    cat _config.yml _scratch/posts.yml > _scratch/all.yml

이번에는 마크다운으로 저장한 페이지를 HTML로 바꿉니다.
C<Text::Markdown> 모듈이 알아서 다 해 줍니다.
C<-i> 옵션을 사용해서 한방에 파일들을 변환해 버렸습니다.
사실 C<-i> 는 굉장히 위험한 옵션입니다.
사용하기 전에 파일을 백업하거나 C<-i.bak> 같은 방법을 쓰는 등 각별한 관리가 필요합니다.
저 역시 숱하게 파일을 날려버리고 여러번 울었었죠!
특히 C<-p> 옵션 대신 무심코 C<-n> 옵션을 쓴다면 깨끗해진 파일들을 보게 됩니다.
이런!;;;

    #!bash
    perl -i -0 -mText::Markdown=markdown -ne'print markdown($_)' _scratch/*.markdown

C<Text::Xslate> 모듈을 이용해 미리 작성한 템플릿에 만들어진 HTML 파일을
집어넣어서 실제 보여줄 페이지를 만듭니다.
제목이나 앞뒤 페이지 네비게이션을 위해서 메타정보도 함께 전달해야 합니다.

    #!bash
    perl -mYAML=LoadFile -MText::Xslate -e'($s,@p)=LoadFile("_scratch/all.yml");map{open$f,">$_->{file}";print$f Text::Xslate->new->render("source/_layouts/default.html",  { site=>$s,  page=>$_, type=>"post.html", posts=>\@p})}@p'

최종 작성된 파일들을 C<_deploy> 폴더의 C<blog/년도/월/날짜/제목/index.html> 형식으로 보내줍니다.

    #!bash
    ls _scratch/*.html | perl -nle'/(\d+)-(\d+)-(\d+)-(.*?)\./;$d="_deploy/blog/$1/$2/$3/$4";system("mkdir -p $d && cp $_ $d/index.html");'

이제 메인 페이지를 만들겠습니다.
첫 페이지에 보여줄 포스트의 개수를 정하고 페이지 네비게이션을 만들면 좋겠지만,
I<귀찮아서> 그냥 모든 포스트를 한 화면에 넣었습니다.
똑같은 템플릿을 사용하면서 템플릿 내에서 C<for> 반복문을 이용해 모든 포스트를 출력합니다.

    #!bash
    perl -mYAML=LoadFile -MText::Xslate -e'($s,@p)=LoadFile("_scratch/all.yml");open$f,">_deploy/index.html";print$f Text::Xslate->new->render("source/_layouts/default.html",  { site=>$s,  pages=>\@p,  type=>"index.html", posts=>\@p})'

와우! 이제 다 끝났습니다.
Octopress 에서 I<훔쳐온> 정체를 알 수 없는
각종 CSS와 자바스크립트 파일들을 C<_deploy> 폴더로 복사합시다.

    #!bash
    rsync -a source/favicon.png source/images source/javascripts source/stylesheets _deploy/

C<_deploy> 폴더로 이동해 추가, 변경, 삭제된 파일들을 업데이트 한 후
원격 저장소의 C<gh-pages> 브랜치로 밀어 넣습니다.

    #!bash
    cd _deploy
    git add .
    git add -u
    git commit -m "Site updated at `date`"
    git push origin gh-pages --force


=head2 놀랍게도 끝

C<source> 가지를 C<push>하는 것 있지 마세요!

    #!bash
    git add .
    git commit -a -m <log>
    git push origin source

이제 C<<< https://<username>.github.com/blog >>> 주소의 여러분 만의 블로그가 생성되었습니다.

I<참 쉽죠잉~> ;-)


=head2 보너스

처음 계획할 때 생각했던 것보다 다양한(?) 코드가 나오지 않은 것 같아
아쉬움을 달래기 위해 간단한 원라이너 라이프핵 두 가지를 더 소개합니다.


=head2 Perl 코드 내에 쉘 환경 변수를 넣기

환경 변수를 넣으려면 C<$ENV{VarName}> 해시 변수를 사용할 수도 있지만,
쉘의 문자열 병합 기능을 이용할 수도 있습니다.

    #!bash
    perl -e'print "Current Term is '$TERM'\n"'


=head2 여러 개의 파일 열기

속도에 아주 민감한 코드가 아니라면, 여러 파일을 처리할 때 원라이너 Perl 코드 내에서
파일을 여는 대신 쉘의 C<while> 루프를 사용할 수도 있습니다.

    #!bash
    ls *.root | while read x;do perl -nle'do something' $x > $x.new ;done

생각해보면 당연한 거죠?
하지만 저는 Perl 원라이너 안에서 이중 반복문을 사용할 때가 더 많답니다. :-)


=head2 정리하며

Perl 원라이너는 정말 강력합니다.
몇 가지 옵션과 CPAN의 모듈, 그리고 심지어 유닉스 유틸리티와 파이프를 연결하면
한 줄의 원라이너 코드로 할 수 없는 일을 찾는 것이 더 어려울 것입니다.
물론 지금까지의 모든 작업을 모듈로 리팩터링 해서 우아하게(?) 만들 수도 있지만
불과 몇 줄 코드의 집합을 단 두 개의 파일로 정리해서 간단히 끝내버렸는데,
오히려 이 편이 더 멋있지 않나요?

이 문서에서는 마크다운 문서만 다루었지만 POD 등의 다른 형식을 추가하는 것도 어렵지 않겠죠.
이미 모든 것은 L<CPAN님|http://www.cpan.org/>께서 알고 계십니다.
비슷한 방식으로 L<ikiwiki|http://ikiwiki.info>를 GitHub에서 서비스 하는 것도 간단하고 재밌겠네요.
C<_deploy> 디렉토리는 단순한 정적 파일들만을 가지고 있기 때문에 GitHub로 밀어넣는 것 뿐만 아니라,
다른 웹서버나 L<dotcloud|http://dotcloud.com>, L<Amazon S3|http://aws.amazon.com/s3> 같은 클라우드 서비스를 이용할 수도 있겠죠.
숙제로 남겨두기로 할까요?

Octopress도 매우 훌륭한 도구입니다.
Perl 사용자는 Perl 도구만 써야한다는 강박을 가진 것은 아니지만
Perl로 만들어진 것이 아니면 수정할 수가 없어서 재미가 없고 답답한 느낌이 들어요.
누가 Perl로 Octopress 에 버금가는 도구를 만들어주면 좋겠는데...

여기까지. 더 이상은 무리! ;-)


=head2 Perl 원라이너 참고문서

=over

=item *

L<perldoc perlrun|http://perldoc.perl.org/perlrun.html>


=item *

L<HOT PERL ONE LINERS|http://www.unixguide.net/unix/perl_oneliners.shtml>


=item *

L<One-liner Program|http://en.wikipedia.org/wiki/One-liner_program>


=item *

L<Cultured Perl: One-liners 101|http://www.ibm.com/developerworks/linux/library/l-p101/>


=item *

L<pung96's perlog|http://perlog.pung96.net>


=back


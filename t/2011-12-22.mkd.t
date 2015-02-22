use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-22.mkd';
is markdown_to_pod($file), get_pod(\*DATA), "converting $file";

__DATA__
=encoding utf8

Title:    Perl, 오늘 급식은 뭐야?
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   cheese_rulez


=head2 저자

L<@cheese_rulez|http://twitter.com/cheese_rulez> -
a.k.a. 치즈군, 평범한 고등학생, 리듬게임이 좋아요, 오덕.


=head2 시작하며

학교 생활을 하다보면 신경 쓰이는게 많습니다.
예를 들면, 옆자리의 예쁜 여자아이, 2학년의 예쁜 선배,
동아리의 마음씨 곱고 짱 예쁘신 3학년 선배님이 있습니다.
음, 그렇습니다. 사실 현실의 학교에서 그럴 일은 없습니다.
이렇게 신경쓰고 싶은 것도 얼마 없는 지루한 학교 생활에
유일하게 활기를 불어넣어주는 건 당연 급식입니다.
4교시를 마치는 종소리가 울리면 당번들은 발에 부스터라도
달린 듯 급식차를 가지러 뛰어나가고, 우리는 가슴을 조아립니다.
그 두근거림을 두 배로 UP 해주는 것은 바로 급식 안내장!
하지만 저희 학교는 그런걸 나누어주지 않습니다. 슬픕니다.
다행히도 학교 홈페이지에 영양사 선생님께서 꾸준히 급식 정보를 올려주지요!
하지만 문제가 있었으니... 메뉴가 플래시입니다.

=for html <img src="2011-12-22-1.png" alt="안녕, 나는 플래시." width="700" /><br  />

I<그림 1.> 안녕, 나는 플래시. (L<원본|2011-12-22-1.png>)

친구가 던져준 아이팟으로는 확인도 못한단 말이에요.
하지만 방법이 있습니다. 우리에겐 Perl이 있으니까요!


=head2 계획하기

먼저, Perl을 사용해 오늘의 급식을 알려주는 간단한 스크립트를 만들어봅시다.
단순히 급식을 가져와 출력하는 형태가 완성된 다음에는 어떻게 활용해야 할까요?
이 프로그램을 재료로 다시 어떻게 요리하느냐에 따라 더 굉장하고, 맛있는 것을 만들 수 있을 것입니다.

예를 들어, 올해 달력의 6일 기사 L<'초소형 프레임워크와 함께 춤을!'|http://advent.perl.kr/2011/2011-12-06.html>에
나온 L<Dancer|http://perldancer.org/>나, 아파치와 CGI를 이용해 급식을 보여주는
웹 사이트(L<gms.jubeat.kr|http://gms.jubeat.kr/>)를 만들 수 있습니다.
작년 달력의 4일 기사 L<'선물 세 가지'|http://advent.perl.kr/2010/2010-12-04.html>에 나온
L<Net::Twitter::Lite|https://metacpan.org/module/Net::Twitter::Lite> 모듈을 이용해
트위터 봇(L<@GMS_Lunchbot|http://twitter.com/GMS_Lunchbot>)도 만들 수도 있구요.
작년 달력의 2일 기사 L<'Net::Google::Calendar 를 이용한 무료 SMS알림이 만들기'|http://advent.perl.kr/2010/2010-12-04.html>를
응용해 매일 학교 급식을 문자로 받아볼 수도 있지요.
이렇게 활용 방법에 따라 무궁무진하게 발전시킬 수 있습니다!
그럼 우선 간단한 스크립트에서 출발해 보도록 해요. 자, 시작해볼까요?


=head2 재료 준비하기

우선, 아래와 같이 재료를 준비해주세요.

=over

=item -

Perl


=item -

L<LWP::UserAgent|https://metacpan.org/module/LWP::UserAgent> 모듈


=item -

L<Encode|https://metacpan.org/module/Encode> 모듈


=item -

L<DateTime|https://metacpan.org/module/DateTime> 모듈


=back

윈도 환경이라면 L<딸기 Perl|http://strawberryperl.com/>을 설치합니다.
나머지 모듈은 우리의 CPAN 대형 마트를 통해 구할 수 있습니다!
L<LWP::UserAgent|https://metacpan.org/module/LWP::UserAgent>는 웹페이지를 가져오는 데 필요합니다.
L<Encode|https://metacpan.org/module/Encode>는 문자열 인코딩을 자유자재로 다루어줍니다.
시간을 구하기 위해서는 Perl에 기본 내장된 L<POSIX|https://metacpan.org/module/POSIX> 모듈을 쓰는 것도 나쁘지 않지만,
L<DateTime|https://metacpan.org/module/DateTime>을 쓰는 것이 더 좋다고 하네요.


=head2 요리 시작!

바로 코드를 봅시다. 기본적인 코드는 아래와 같습니다.

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    
    use LWP::UserAgent;
    use DateTime;
    use Encode qw(encode);
    
    my $dt    = DateTime->now;
    my $year  = $dt->year;
    my $month = $dt->month;
    my $day   = $dt->day;
    my $date  = sprintf "%s년 %s월 %s일", $year, $month, $day;
    
    my $enc      = $^O eq "MSWin32" ? "EUC-KR" : "UTF-8";
    my $ua       = LWP::UserAgent->new;
    my $url      = "http://gms.hs.kr/submain.html?tmode=school_eat&eatmode=view&nm=&year=$year&month=$month&date=$day";
    my $response = $ua->get($url);
     
    my ( $lunch, $dinner );
    if ( $response->is_success ) {
        my $contents      = $response->decoded_content;
        ($lunch, $dinner) = get_food($contents);
        $lunch  //= '없습니다.';
        $dinner //= '없습니다.';
    }
    else {
        my $err = $response->status_line;
        die "정보를 받아오는 중에 오류가 발생했습니다! : $err\n";
    }
    
    say "$date 오늘의 급식 정보 --";
    say "중식 : $lunch";
    say "석식 : $dinner";
    say "이상, 오늘의 급식이었습니다.";

순서대로 코드를 간단히 둘러봅시다.

    #!perl
    my $ua       = LWP::UserAgent->new;
    my $url      = "http://gms.hs.kr/submain.html?tmode=school_eat&eatmode=view&nm=&year=$year&month=$month&date=$day";
    my $response = $ua->get($url);

위처럼 C<LWP::UserAgent> 모듈을 사용해 학교 웹사이트에서
C<$year>년 C<$month>월 C<$day>일의 급식을 받아옵니다.
여기서 오늘 날짜의 변수는 C<DateTime> 모듈을 사용해 쉽게 가져올 수 있습니다.

    #!perl
    my ( $lunch, $dinner );
    if ( $response->is_success ) {
        my $contents      = $response->decoded_content;
        ($lunch, $dinner) = get_food($contents);
        $lunch  //= '없습니다.';
        $dinner //= '없습니다.';
    }
    else {
        my $err = $response->status_line;
        die "정보를 받아오는 중에 오류가 발생했습니다! : $err\n";
    }

우리의 C<$ua>가 가져온 결과는 C<$response>에 담겼습니다.
성공적으로 결과를 받으면 웹페이지의 내용을 전부 C<get_food> 함수에 전달합니다.
그리고 결과로 점심과 저녁의 메뉴를 받았습니다.
만약 인터넷 연결이나 서버의 문제 등으로 데이터를 가져오지 못하면
오류를 뿜고 종료합니다. 정말 간단하죠?
여기까지가 기본 형태입니다.
학교 홈페이지마다 웹사이트 코드의 구조는 다를테니
C<get_food> 함수의 구현은 여러분의 학교에 맞게 작성해야 합니다.
그럼 두 학교 사이트를 통해 연습해볼까요?

먼저 L<경기 모바일 과학 고등학교|http://gms.hs.kr/>입니다. 사실 방금 가져온 웹페이지의 URL의 정체도 이곳이었습니다.
웹 페이지의 소스를 브라우저에서 직접 확인하려면 브라우저 주소 앞에 C<view-source:>를 붙여서 열어봅니다.
이전의 코드에서 C<get_food> 함수에 전달될 내용의 일부는 아래와 같습니다.

    #!xml
    <tr class="eatlist_contents_out">
      <td  class="eatlist_title" colspan=2 bgcolor=f0f0f0>중식</td>
    </tr>
    <tr class="eatlist_contents_out"  height=50>
      <td  class="eatlist_title" rowspan=2></td>
      <td  style='font-weight:bold'>옥수수밥,브로콜리크림스프,탕수육/소스,감자고추장조림,배추김치</td>
    </tr>
    <tr class="eatlist_contents_out">
      <td></td>
    </tr>
    <tr class="eatlist_contents_out"  >
      <td  class="eatlist_title" colspan=2>석식</td>
    </tr>
    <tr class="eatlist_contents_out"  height=50>
      <td  class="eatlist_title" rowspan=2></td>
      <td  style='font-weight:bold'></td>
    </tr>
    <tr class="eatlist_contents_out">
      <td></td>
    </tr>

여기에서 C<중식>의 C<옥수수밥,브로콜리크림스프,탕수육/소스,감자고추장조림,배추김치>를 가져와야 합니다.
"석식"에는 아무것도 없는 모습이네요.
이 내용만 추출하기 위해 L<Web::Scraper|https://metacpan.org/module/Web::Scraper>나 L<Web::Query|https://metacpan.org/module/Web::Query> 같은 좋은
모듈을 사용할 수 있습니다. 하지만 정규표현식을 사용하는 것도 편리합니다.
다음의 코드처럼 말이죠!

    #!perl
    sub get_food {
        my $contents = shift;
        my @result   = $contents =~ m|<td  style='font-weight:bold'>(.+?)</td>|ig;
    
        return map encode($enc, $_), @result;
    }

정규표현식은 밑줄 긋고 별표 5개를 쳐야할 정도로 중요합니다!
위 코드를 그림으로 표현하자면 아래와 같습니다.

=for html <img src="2011-12-22-2.png" alt="정규표현식 풀이" /><br  />

I<그림 2.> 정규표현식 풀이

즉, 급식은 매일 바뀌지만 앞뒤에 붙어있는 태그는 변함이 없기 때문에,
앞 뒤에는 C<<< <td  style='font-weight:bold'> >>>와 C<<< </td> >>>를 그대로 쓰고
매일 바뀌는 부분은 C<.+?>로 걸러냈습니다.
그리고 걸러진 내용을 가져오기 위해 괄호로 감쌌습니다.
여기서 C<.+?>의 각각의 기호는 의미가 있습니다. 
조합하면 아무 글자나(C<.>) 몇 개든 상관 없지만(C<+>) 개수는
최대한 적게(C<?>) 매치할 수 있는 하나의 패턴을 만듭니다.
C<m|...|ig>에서 C<g>에 해당하는 정규표현식 옵션은 이 정규표현식이
문자열에 대해 매치하는 모든 곳을 찾도록 돕습니다.
가져온 모든 결과는 C<@result> 배열에 넣었습니다.

이번에는 L<이웃집 디미고|http://dimigo.hs.kr/> 사이트에서 시도해봅시다.
이곳의 식단표 페이지는 날짜와 상관없이 항상 동일하네요!
그래서 L<DateTime|https://metacpan.org/module/DateTime> 모듈을 사용할 필요는 없고
단순히 C<$url> 변수의 값만 다룹니다.

    #!perl
    my $url = "http://new.dimigo.hs.kr/dimigo/kimson/home/dimigo/bbs.php?id=food_list";

이번에도 마찬가지로, 웹 페이지의 소스를 열어서 잘 살펴봅니다.
어딘가 반복되어 있는 부분을 찾으셨나요?

    #!xml
    <tr><td colspan="4" bgcolor="eeeeee" height="1"></td></tr>
    <tr bgcolor='#FBFBFB' align="center">
      <td style='font-weight:bold;color:#666666;'>2011.12.19</td>
      <td background="../../_skin/board/_Full/school_food/image/ico_vline03.gif"></td>
      <td style="padding:10px;" align="left">
        <table>
        <tr height="5"><td></td></tr>
        <tr><td style='font-weight:bold;color:#666666;'>[아침] 쌀밥/육개장/해물완자땡/도토리묵무침/깻잎지/포기김치/요구르트</td></tr>
        <tr><td style='font-weight:bold;color:#666666;'>[점심] 잡곡밥/근대국/순대야채볶음/호박야채전/부추겉절이/포기김치/삶은계란</td></tr>
        <tr><td style='font-weight:bold;color:#666666;'>[저녁] 김치유부국수/쌀밥/떡강정/얼갈이겉절이/단무지/깍두기</td></tr>
        <tr><td style='font-weight:bold;color:#666666;'>[간식] 포테이토스킨&황도샐러드&사과쥬스</td></tr>
        <tr height="5"><td></td></tr>
        </table>  
      </td>
      <td>
        </td>
    </tr>
    <tr><td colspan="4" bgcolor="eeeeee" height="1"></td></tr>

네, 달력 형태로 각 항목에 그 날의 급식이 써져있는데,
C<tr>, C<td> 태그로 씌워져 있습니다.
(정확히는 C<<< <tr align="center"> >>>과 C<<< <tr><td colspan="4" bgcolor="eeeeee" height="1"></td></tr> >>>)
그리고 각 시간대 별 식단도 다시 C<tr>과 C<td> 태그로 감싸져 있네요.
게다가 그 중, 오늘의 급식만 스타일 속성이
C<font-weight:bold;color:#666666;>으로 지정되어 있습니다.
다행이네요. 그러면 간단히 작성할 수 있습니다.
C<get_food> 함수를 이렇게 고치면 되죠!

    #!perl
    sub get_food {
        my $contents = shift;
        my @result   = $contents =~ m|<tr><td style='font-weight:bold;color:#666666;'>\[..\] (.+?)</td></tr>|ig;
    
        return map encode($enc, $_), @result;
    }

디미고는 기숙사도 있다보니 아침도 주나봐요.
무려 간식도 있어요! 호화롭네요!


=head2 더 맛있게

이제 L<@gypark|http://twitter.com/gypark>님이 쓰신 작년 달력의 4일 기사 'L<선물 세 가지|http://advent.perl.kr/2010/2010-12-04.html>'에
나온 L<Net::Twitter::Lite|https://metacpan.org/module/Net::Twitter::Lite> 모듈을 응용해서 트위터 봇을 만들어봅시다.


=head3 준비 #1

일단, L<dev.twitter.com/apps/new|http://dev.twitter.com/apps/new>로 접속해 트위터 어플을 하나 만들어줍니다.
하단의 그림문자를 입력하고 I<Create your Twitter Application>을 클릭합니다.
그러면 어플이 등록됩니다. 정말 간단하죠?
(어딘가 잘못 써진 것 같지만 그냥 넘어갑시다.)

=for html <img src="2011-12-22-3.png" alt="그림문자 입력" /><br  />

I<그림 3.> 그림문자 입력

=for html <img src="2011-12-22-4.png" alt="트위터 앱 생성" width="700" /><br  />

I<그림 4.> 트위터 앱 생성 (L<원본|2011-12-22-4.png>)

그런데 읽기 전용입니다. I<Settings> 탭에서 쓰기 권한을 줍시다.
그리고 다시 I<Details> 탭으로 돌아와 하단에 있는
I<Create my Access Token>을 눌러 미리 간단히 접근할 수 있게 토큰을 받아둡니다.
토큰이 생성되면, I<consumer key>, I<consumer secret>,
I<access token>, I<access token secret> 4개를 메모해주세요.
중요한 정보이므로 이 4개는 I<반드시 유출되지 않게 주의>해 주세요.
유출된다면 누군가 장난으로 글을 쓰거나 하는 것이 가능해지겠죠?

=for html <img src="2011-12-22-5.png" alt="권한 변경" /><br  />

I<그림 5.> 권한 변경

=for html <img src="2011-12-22-6.png" alt="토큰이 기록된 앱 상세 페이지" width="700" /><br  />

I<그림 6.> 토큰이 기록된 앱 상세 페이지 (L<원본|2011-12-22-6.png>)


=head3 준비 #2

완성된 급식 스크립트를 트위터 봇으로 개조해봅시다.
트위터 봇으로 작동시키기 위해 L<Net::Twitter::Lite|https://metacpan.org/module/Net::Twitter::Lite>
모듈이 추가로 필요합니다.
이것 역시 L<CPAN|http://www.cpan.org/> 대형 마트에서 구할 수 있습니다.


=head3 봇을 만들어요

다시 코드를 작성해 볼까요!

    #!perl
    #!/usr/bin/env perl
    
    use 5.010;
    use strict;
    use warnings;
    
    use LWP::UserAgent;
    use DateTime;
    use Encode qw(encode decode);
    use Net::Twitter::Lite;
    
    my $dt    = DateTime->now;
    my $year  = $dt->year;
    my $month = $dt->month;
    my $day   = $dt->day;
    my $date  = sprintf "%s년 %s월 %s일", $year, $month, $day;
    my $enc   = $^O eq "MSWin32" ? "CP-949" : "UTF-8";
    
    my ($option) = @ARGV;
    
    my $admin = '@cheese_rulez'; # 봇 주인의 ID를 입력해주세요!
    my $twt   = Net::Twitter::Lite->new(
        consumer_key        => 'consumer key',
        consumer_secret     => 'consumer secret',
        access_token        => 'access token',
        access_token_secret => 'access token secret',
    );
    
    if ( $option && $option =~ /^-[lda]$/ ) {
        bot($option);
    }
    else {
        tweet('오류 : 사용법이 잘못되었습니다! '.$admin);
        tweet('사용법은 다음과 같습니다 : lunch.pl [스위치] / -l : 중식 / -d : 석식 / -a : 둘 다 '.$admin);
        exit -1;
    }
    
    sub bot {
        my $option = shift;
    
        my ($lunch, $dinner);
        my $ua = LWP::UserAgent->new;
        my $response = $ua->get("http://gms.hs.kr/submain.html?tmode=school_eat&eatmode=view&nm=&year=$year&month=$month&date=$day");
        if ($response->is_success) {
            my $contents =  $response->decoded_content;
            my @result   = $contents =~ m|<td  style='font-weight:bold'>(\S+)</td>|ig;
    
            $lunch  = encode($enc, $result[0]);
            $dinner = encode($enc, $result[1]);
            $lunch  = "없음" if !defined $lunch;
            $dinner = "없음" if !defined $dinner;        
        }
        else {
            my $err = $response->status_line;
            tweet("$admin 오류 발생! : $err");
            die "정보를 받아오는 중에 오류가 발생했습니다! : $err";
        }
    
        if ($option eq '-l') {
            tweet("오늘 점심은 $lunch 입니다!");
        }
        elsif ($option eq '-d') {
            tweet("오늘 저녁은 $dinner 입니다!");
        }
        elsif ($option eq '-a') {
            tweet("오늘 점심은 $lunch 이며, 저녁은 $dinner 입니다!");
        }
    }
    
    sub tweet {
        my $msg = shift;
    
        my $text   = decode($enc, $msg);
        my $result = eval { $twt->update($text) };
    
        warn "$@\n" if $@;
    }

먼저 C<@ARGV>입니다. 이 배열은 명령 뒤에 주는 스위치나 옵션 목록을 담고 있습니다.
즉, 도스의 C<dir /p>의 C</p>나 C<ls -l>의 C<-l>에 해당합니다.
이 옵션 목록에서 첫번째의 항목을 C<$option>으로 받습니다.

    #!perl
    my ($option) = @ARGV;

여기서는 C<-l> 옵션을 받으면 점심을, C<-d>이면 저녁을, C<-a>이면 모두 트위터로 올리도록 했습니다.
옵션을 주지 않거나 잘못되면 경고 메시지를 트위터로 올립니다.
이전의 스크립트는 C<bot>이라는 사용자 함수로 묶었습니다.
C<get_food>으로 나눴던 로직은 C<bot>안에 다시 넣었습니다.

    #!perl
    sub bot {
        my $option = shift;
    
        #...생략...
    
        if ($option eq '-l') {
            tweet("오늘 점심은 $lunch 입니다!");
        }
        elsif ($option eq '-d') {
            tweet("오늘 저녁은 $dinner 입니다!");
        }
        elsif ($option eq '-a') {
            tweet("오늘 점심은 $lunch 이며, 저녁은 $dinner 입니다!");
        }
    }

그리고 함수의 인자로 받은 C<$option>의 값에 따라 점심, 저녁, 또는 전부를 트윗합니다.
옵션에 따라 C<tweet> 함수를 호출하고 있습니다.
함수 이름을 보면 알 수 있듯이 말 그대로 트윗을 올리는 함수입니다.

    #!perl
    sub tweet {
        my $msg = shift;
    
        my $text   = decode($enc, $msg);
        my $result = eval { $twt->update($text) };
    
        warn "$@\n" if $@;
    }

올릴 문자열을 미리 디코딩하지 않으면 다음과 같은 오류 메시지가 발생하니 주의하세요!

    #!plain
    Net::OAuth warning: your OAuth message appears to contain some multi-byte characters that need to be decoded via Encode.pm or a PerlIO layer first.  This may result in an incorrect signature. at /home/cheesekun/perl5/perlbrew/perls/perl-5.14.1/lib/site_perl/5.14.1/Net/OAuth/Message.pm line 106.

그래서 디코딩 후, C<update> 메소드로 전달합니다.
그 외 나머지는 앞에서 살펴본 코드와 거의 비슷합니다.


=head2 정리하며

트윗으로 올리는 기능을 만들었지만, 특정 시간에 자동으로 올려주지는 않습니다.
윈도에서는 I<작업 스케쥴러>를 리눅스에서는 C<crontab>을 사용해
특정 시간에 자동으로 스크립트를 실행시키면 됩니다!
처음 쓰는 기사라 내용이 알찰지 모르겠네요.
그래도 많은 학생분들에게 맛있는 급식 생활이 되었으면 합니다.
대불어 글을 작성하는데 많은 도움을 주신 L<@am0c|http://twitter.com/am0c>님,
L<@gypark|http://twitter.com/gypark>님, L<@aer0|http://twitter.com/aer0>님께 감사드립니다!


=head2 참고문서

=over

=item -

L<정규표현식 문서|http://gypark.pe.kr/wiki/Perl/%EC%A0%95%EA%B7%9C%ED%91%9C%ED%98%84%EC%8B%9D> - L<@gypark|http://twitter.com/gypark>


=item -

L<선물 세 가지 :-D - 2010년 Seoul.pm 크리스마스 달력|http://advent.perl.kr/2010/2010-12-04.html> - L<@gypark|http://twitter.com/gypark>


=item -

L<Obtain a switch/case behaviour in Perl 5|http://stackoverflow.com/questions/844616/obtain-a-switch-case-behaviour-in-perl-5>


=item -

L<거침없이 배우는 Perl 비평|https://github.com/aero/perl_docs/blob/master/Learning_Perl_5th_kor_review.md> - L<@aer0|http://twitter.com/aer0>


=back


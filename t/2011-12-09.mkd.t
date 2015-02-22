use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-09.mkd';
is markdown_to_pod($file), get_pod(\*DATA), "converting $file";

__DATA__
=encoding utf8

Title:    Youtube에서 원하는 동영상 내려받기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   eeyees


=head2 저자

L<@eeyees|http://twitter.com/eeyees> - 인쇄기기 업계의 기린아, TAFKA_HoliK라는 닉을 사용하기도 한다.
일본에서 일하다가 올해 한국 후지 제록스로 이직하였다.


=head2 시작하며

우리는 일상에서 많은 문제에 직면하게 됩니다.
이런 문제들을 빠르게 해결할 수 있는 스크립트 언어를 한가지쯤 알고 있다면
그것은 굉장한 행운일 것입니다. 저는 Perl을 통해 자잘한 문제들을 해결하고 있습니다.
지금부터 최근에 제가 겪은 문제를 Perl과 CPAN을 이용해서
어떻게 빠르고 쉽게 해결하는지 보여 드리도록 하겠습니다.


=head2 회상

평소와 비슷한 일상을 보내고 있는 저에게 갑자기 큰 문제가 발생했습니다.
주말에 TV를 보다가 아이유의 노래에 I<feel>이 팍! 꽂힌 것입니다.
그리고 Youtube에 접속해 아이유의 뮤직비디오를 감상하다가 이렇게 생각한 것이죠.

=over 2

'아이유 뮤직비디오를 가지고 싶다!'

=back

Youtube에 있는 동영상을 자동으로 쉽게 다운로드할 수는 없을까요?
곧장 L<metacpan|https://metacpan.org/>에 접속해 Youtube 관련 모듈을 찾아보았습니다.

=for html <img src="2011-12-09-1.png" alt="입력하는 모습" width="700" />

역시 많이 있군요! 그럼 작업을 시작해 볼까요?


=head2 따라하기

Youtube 검색을 위해 다음 모듈을 CPAN으로 부터 설치 합니다.

    #!bash
    $ sudo cpan install WebService::GData::YouTube

검색된 결과를 다운로드 받기 위해 다음 CPAN 모듈을 설치합니다.

    #!bash
    $ sudo cpan install WWW::YouTube::Download

간단하게 다음과 같은 스크립트를 작성합니다.

    #!perl
    use 5.010;
    use strict;
    use warnings;
    use WWW::YouTube::Download;
    use WebService::GData::YouTube;
    
    # 아듀먼트로 검색 값
    my ($search, $limit) = (@ARGV);
    $limit //= 10;
    
    # 검색 값으로 유투브 검색
    my $search_youtube = WebService::GData::YouTube->new;
    
    # 쿼리 값 설정
    $search_youtube->query()->q($search)->limit($limit, 0);
    
    # 검색
    my $results = $search_youtube->search_video();
    
    # 다운로드
    my $client = WWW::YouTube::Download->new;
    foreach my $ret (@$results) {
        say "Starting Download : " . $ret->title;
        $client->download($ret->video_id);
    }

완성입니다!


=head2 실행

만든 스크립트를 실행하여 동영상을 내려받아 보겠습니다.
첫 번째 인자에 검색어를 넣고, 두 번째 인자에 다운로드 받을 개수를 입력합니다.

    #!bash
    $ perl main.pl "아이유" 10

=for html <img src="2011-12-09-2.png" alt="터미널" />

열심히 받아지고 있는 모습입니다. :)

=for html <img src="2011-12-09-3.png" alt="받는중" width="700" />


=head2 정리하며

Perl과 CPAN을 몰랐다면 이렇게 간단하게 문제를 해결할 수는 없었을 겁니다.
문제가 발생하면 현재 무려 I<10여 만개>의 CPAN 모듈이 모여 있는 L<cpan.org|http://www.cpan.org/>에서 
모듈을 쉽게 검색할 수 있습니다.
아름다운 인터페이스를 제공하는 L<metacpan.org|https://metacpan.org/>도 있습니다.
모든 모듈은 문서와 예제 코드를 포함하고 있기 때문에 쉽게 접근할 수 있습니다.

마지막으로 도움을 주신 한국 펄 몽거스 분들과 아이유 양에게 감사드립니다.


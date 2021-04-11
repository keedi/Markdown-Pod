use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-23.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    Perl로 타자연습을!
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   1985xmas


=head2 저자

L<@1985xmas|http://twitter.com/1985xmas> -
올해 9월에 홍콩과기대 컴퓨터공학과 대학원 석사 과정에 갓 입학한 새내기 유학생.
대학원 입학 후 텍스트 처리를 위해 Perl을 공부하다 Perl의 매력에 완전히 빠져버렸다. 
주로 사용하는 아이디는 1985xmas와 specno1이며 
L<블로그|http://specno1.blog.me/>에 Perl 강좌를 올리고 있다. 
블로그에서 사용하는 이름인 “초승달”에는 
미래가 항상 현재보다 더 밝아지기를 바라는 마음이 담겨 있다.


=head2 시작하며

대학원 입학 후 Perl을 처음 접하고 Perl에 완전히 반해
블로그에 Perl 강좌를 올리기 시작했습니다.
아직 부족한 점이 많은 제 블로그에 감사하게도
L<@am0c|http://twitter.com/am0c>님께서 방문해주셨고,
Perl 크리스마스 달력 기사 제의를 해 주셨습니다.
다른 분들에 비해 실력면에서나 경험면에서나 부족한 
제가 과연 제대로 된 기사를 쓸 수 있을까 하는 걱정이 들었지만 용기를 내어 이렇게 기사를 쓰게 되었습니다.

오늘 함께 만들어볼 프로그램은 타자 연습 프로그램입니다.
화면에 타자 연습 문장을 띄워주고 사용자가 그 문장을 따라 입력하면
타자 속도와 정확도, 연습 시간을 계산해 보여주며 어느 위치에서 오타가 났는지도 알려줍니다.
연습하고 싶은 문장 파일은 사용자가 직접 선택할 수 있습니다.
프로그램을 종료하게 되면 평균 속도와 평균 정확도, 총 연습 시간을 출력해줍니다.

영문 타자를 연습하도록 프로그램을 만든 상태지만
멀티바이트 문자 지원을 추가하면 I<수 많은 언어로> 타자연습을 할 수 있을 것입니다.
그러면 이제 본격적인 설명에 들어가도록 하겠습니다!


=head2 프로그램 설계

프로그램 설계를 위해 I<대략 코드>(pseudocode, 수도코드)를 짜보도록 하겠습니다.
사실 pseudocode에 대응되는 표준 용어는 '의사(疑似) 코드'입니다.
하지만 '대략 코드'라는 말이 더 와닿지 않나요?
어쨌든 '대략적인' 코드를 만들어 보도록 하겠습니다.
제가 짜 본 대략 코드는 다음과 같습니다.

=over

=item -

타자 연습 문장 자료를 입력받는다.


=item -

연습 문장을 화면에 출력한다.


=item -

사용자로부터 입력을 받는다.


=item -

사용자가 문장을 입력하는 데 걸린 시간을 측정한다.


=item -

몇 글자를 입력했는지를 계산한다.


=item -

올바로 입력한 글자와 오타를 구분한다.


=item -

오타의 위치, 연습 시간, 정확도, 속도를 출력한다.


=item -

위 작업을 반복한다.


=back


=head2 실제 코드

실제 코드는 다음과 같습니다.
대부분의 작업은 C<oneSentence()>라는 함수를 만들어서 처리했습니다.
나무보다 숲을 먼저 본다는 의미에서 프로그램 전체의 구조를 먼저 알아보고,
C<oneSentence()> 함수를 나중에 보도록 하겠습니다.
C<oneSentence()> 함수의 구현을 제외한 프로그램의 주요 부분을 먼저 보겠습니다.

    #!perl
    #!/usr/bin/env perl
    use 5.012;
    use strict;
    use warnings;
    use Time::HiRes qw(gettimeofday);
    use Term::ReadKey;
    
    open my $data, '<', $ARGV[0] or die "Cannot read the file: $!";
    my $mode;
    my @inputArray;
    my @outputArray;
    my $totalTime    = 0;
    my $totalLength  = 0;
    my $totalTyping  = 0;
    my $totalCorrect = 0;
    my $arrayIndex;

프로그램의 시작 부분입니다.
시간을 정교하게 측정하기 위해 마이크로초 단위까지 시간을 측정해주는
L<Time::HiRes|http://search.cpan.org/perldoc?Time::HiRes> 모듈을 사용했습니다.
사용자가 키를 누른 후에 엔터키를 누르지 않아도
키보드로부터 입력을 받을 수 있도록 L<Term::ReadKey|http://search.cpan.org/perldoc?Term::ReadKey> 모듈을 사용했습니다.
C<$data> 변수는 연습 문장 텍스트 파일을 불러오는 데 쓰입니다.

    #!perl
    say "\n***********************************************************";
    say "*                                                         *";
    say "*   Korea Perl Christmas Calendar - Typing Trainer v1.0   *";
    say "*                                                         *";
    say "*                   Merry Christmas! ^^                   *";
    say "*                -------------------------                *";
    say "*                                    v1.0 - 2011. 12. 22. *";
    say "*                                                         *";
    say "*  Type the sentence on the screen!                       *";
    say "*  If you want to quit, just type 'quit'.                 *";
    say "*                                                         *";
    say "*  What training mode do you want?                        *";
    say "*    1. Story  Mode (sentences appear sequencially)       *";
    say "*    2. Random Mode (sentences appear randomly)           *";
    say "*                                                         *";
    say "***********************************************************\n";
    print " Type a number ---> ";
    
    # 연습 문장 파일을 읽어온다.
    while (<$data>) {
        push @inputArray, $_;
    }
    
    # 연습 모드를 입력받는다.
    while (1) {
        $mode = <STDIN>;
        chomp $mode;
        if (($mode ne "1") && ($mode ne "2") && ($mode ne "quit")) {
            print " Type a number ---> ";
            next;
        } else {
            last;
        }
    }
    
    say "\n/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\".
        "/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\/\\\n";

프로그램을 실행하면 화면에 처음 나타날 부분입니다.
사용자가 C<1>을 입력하면 연습 문장 파일에 있는 문장을 순서대로 출력해주고,
C<2>를 입력하면 문장 순서를 뒤섞어서 출력해줍니다.
1번은 내용이 이어지는 문장들을 연습할 때,
2번은 각각 독립적인 문장들을 연습할 때 쓰입니다.
눈여겨볼 부분은 연습 문장 파일을 읽어오는 while문의 위치입니다.
사용자가 1번과 2번중 무엇을 선택할지 고민하는 동안
프로그램은 연습 문장 파일을 읽어오는 작업을 합니다.
나름 설계를 최적화(-_-!) 한다고 신경쓴 부분이니 너그러운 칭찬 부탁드립니다. ㅠㅠ

    #!perl
    if ($mode eq "1") {
        $arrayIndex = 0;
    } elsif ($mode eq "2") {
        $arrayIndex = int(rand(@inputArray));
    }
    if (($mode eq "1") || ($mode eq "2")) {
        while (1) {
            @outputArray = oneSentence($inputArray[$arrayIndex]);
            if (@outputArray == 4) {
                if ($mode eq "1") {
                    ++$arrayIndex;
                } elsif ($mode eq "2") {
                    $arrayIndex = int(rand(@inputArray));
                }
    
                if ($arrayIndex >= @inputArray) {
                    $arrayIndex = 0;
                }
                $totalTime += $outputArray[0];
                $totalLength += $outputArray[1];
                $totalTyping += $outputArray[2];
                $totalCorrect += $outputArray[3];
            }
            else {
                last;
            }
        }
    }
    
    say "\n\n-----  Your total score  -----";
    say "       Time: " . (int(100 * $totalTime) / 100) . " seconds";
    if ($totalLength != 0) {
        say "Correctness: " . (int(10000 * $totalCorrect / $totalLength) / 100) . "%" . " ($totalCorrect / $totalLength)";
    } else {
        say "Correctness: not applicable ($totalCorrect / $totalLength)";
    }
    if ($totalTime != 0) {
        say "      Speed: " . (int(60 * 100 * $totalTyping / $totalTime) / 100) . " keys / minute (total $totalTyping keys)\n";
    } else {
        say "      Speed: not applicable\n";
    }
    
    close $data;

사용자의 선택에 따라 문장 출력 순서를 결정해준 뒤 타자연습을 시작합니다.
'한 문장어치 타자 연습하기'의 모든 과정을 C<oneSentence()> 함수가 도맡아 
하기 때문에 단순히 무한루프 속에서 함수를 호출하는 것만으로 모든 작업이 끝납니다(함수의 위엄!).
한편 이 함수는 호출될 때마다 사용자의 타자 연습 시간,
문장 길이, 총 타수, 올바르게 입력한 타수를 반환합니다. 
그 정보를 받아들이는 부분이 코드에 구현되어 있습니다.
한편 사용자가 종료 명령을 내렸을 때에 해당하는 부분도 C<else { last; }>로 구현되어 있습니다.

자! 벌써 프로그램 구조 분석이 끝났습니다.
역시 함수를 만들어서 작업을 처리하니 프로그램 전체 구조에
해당되는 코드가 짧아져 보기도 편하고 이해하기도 쉽습니다.
그러면 이제 오늘의 주인공인 C<oneSentence()> 함수의 내부를
순서대로 보도록 하겠습니다.

    #!perl
    sub oneSentence {
        # 인자를 입력받는다.
        my ($original) = @_; 
    
        # 개행 문자를 없애고 출력한다.
        chomp $original;
        say $original;
    
        # 한 글자씩 배열에 넣는다.
        my @arrOriginal = split //, $original;
        
        # ... 중략 ...
    }

함수의 앞부분입니다. 
하나의 연습문장을 입력받아 한 문장의 타자 연습을 수행한 뒤 종료됩니다.
인자(argument)로 입력받은 문장이 C<$original> 변수에 저장되며,
이때 문장의 맨 끝에 있는 개행 문자(C<"\n">)를 없애기 위해 C<chomp> 함수를 사용합니다.
그 후 나중에 사용자가 어느 위치에서 오타를 냈는지를 쉽게 계산하기 위해 
연습 문장을 배열 변수인 C<@arrOriginal>로 옮겨 저장합니다.
C<split> 함수를 통해 원 문장의 한 글자 한 글자가 하나씩 배열의 각 항목에 들어가게 됩니다.

다음은 프로그램을 작성할 때 가장 고생을 많이 한 부분입니다.

    #!perl
    my $firstLetter;
    do {
        ReadMode 'cbreak';
        $firstLetter = ReadKey(0);
        ReadMode 'normal';
    } while ($firstLetter =~ /\s/);
    print $firstLetter;
    
    my $time1 = gettimeofday();
    my $typing = <STDIN>;
    my $time2 = gettimeofday();
    my $timeDif = ($time2 - $time1);

화면에 연습 문장이 출력된 후 사용자가 '첫 키'(첫키스가 아닙니다.)를 누른 후부터
시간을 측정하기 위해 엔터를 누르지 않아도 키의 입력을 인식하는 부분을 만들어야 했습니다.
그 기능을 위해 C<ReadMode 'cbreak';>와 C<ReadKey()> 함수를 사용했습니다. 
C<ReadKey()> 함수는 키보드로부터 한 글자를 입력받는 기능을 하며,
C<ReadMode 'cbreak';>는 C<ReadKey()> 함수로 하여금 엔터가 눌리지 않아도 키를 입력받도록 해줍니다.
그 작업이 끝나면 C<ReadMode 'normal';>을 통해 키 입력 환경을 원상태로 돌려놓아 주어야 합니다.
그런데 이렇게 되면 키를 입력만 받을 뿐 사용자가 누른 키가 화면에 출력되지 않습니다.
그래서 C<print>를 통해 사용자가 누른 키를 화면에 출력해 주었습니다.
한편, 사용자가 글자가 아닌 공백 문자(엔터, 스페이스 등)를
문장의 처음에 입력하면 화면 구성이 헝클어지므로
while문과 정규식을 이용해 이런 경우가 발생하는지 검사했습니다.

그 후에는 시간 측정을 합니다.
C<gettimeofday()> 함수는 현재 시각을 마이크로초(백만분의 1초) 단위까지 출력해줍니다.
사용자가 문장을 입력하기 전과 후의 시각을 입력받아 타자 연습 시간을 계산합니다.

다음은 함수의 마지막 부분이자 모든 프로그램 설명의 마지막 부분입니다.

    #!perl
    chomp $typing;
    $typing = $firstLetter . $typing;
    if ($typing eq "quit") {
        return "quit";
    }
    my @arrTyping = split //, $typing;
    
    my $i = 0;
    my $j = length $typing;
    my $numCorrect = 0;
    foreach (@arrOriginal) {
        if ($j <= $i) {
            last;
        }
        if ($arrOriginal[$i] eq $arrTyping[$i]) {
            print "-"; 
            ++$numCorrect;
        }
        else {
            print "*";
        }
        ++$i;
    }
    print "\n";
    
    say "       Time: " . (int(100 * $timeDif) / 100) . " seconds";
    say "Correctness: " . (int(10000 * $numCorrect / length($original) / 100)) . "%" . " ($numCorrect / " . length($original) . ")";
    say "      Speed: " . (int(60 * 100 * length($typing) / $timeDif) / 100) . " keys / minute\n\n";
    
    return ($timeDif, length($original), length($typing), $numCorrect);

앞서 문장의 시작 부분에 입력받은 '한 글자'와 
그 후의 나머지 글자들을 C<$typing = $firstLetter . $typing;>을 이용해서 합쳐주고,
연습 문장과 마찬가지로 오타 검사를 위해 문장을 배열로 만들어줍니다.
만약 사용자가 'quit'을 입력했으면 프로그램을 종료합니다.
이어지는 foreach문을 통해 오타 검사가 이루어지며,
올바른 입력 자리에는 '-'를, 오타 자리에는 '*'를 출력하여 (나름) 시각적으로 오타가 난 곳을 표시해줍니다.
그 후 연습 시간, 연습 문장 길이, 입력 타수,
올바른 입력 타수를 반환하고 함수가 종료됩니다.
이로써 프로그램에 대한 모든 설명이 끝났습니다!


=head2 실행 화면

=for html <img src="2011-12-23-1.png" alt="첫 실행 화면" /><br />

I<그림 1.> 첫 실행 화면

첫 실행 화면입니다. 
실행 방법은 다음과 같습니다.

    #!plain
    C:\> perl typing.pl [연습 문장 파일 이름]
    (예: c:\>perl typing.pl data.txt)
    (기사 끝에 예제 파일이 첨부되어 있습니다.)

참고로 윈도7에서 L<Strawberry Perl|http://strawberryperl.com/>을 사용했습니다.
연습 문장 파일 형식은 단순합니다.
각각의 연습 문장이 엔터로 구분되어 있기만 하면 됩니다.
단, 인터넷에서 문장을 긁어오다보면
문장의 맨 끝에 공백 문자로 인한 공백이 있는 경우가 있는데, 
이 경우에는 공백을 미리 제거해주시는 편이 좋습니다.
그렇지 않으면 타자 연습을 할 때 공백까지 입력해야 합니다.

프로그램이 실행되면 프로그램의 정보, 인사말과 함께 안내가 나옵니다.
1번을 선택하면 연습 문장 파일에 있는 문장이 순서대로 출력되고,
2번을 선택하면 문장 순서가 무작위로 바뀌어 출력됩니다.
프로그램을 종료하고 싶을 때에는 'quit'을 입력합니다.

=for html <img src="2011-12-23-2.png" alt="이어지는 문장 타자 연습" /><br />

I<그림 2.> 이어지는 문장 타자 연습 (이야기 모드)

1번을 선택해 내용이 이어지는 문장으로 타자 연습을 하는 화면입니다.
예제 문장은 크리스마스를 기념해 아기 예수님의 탄생 장면으로 골랐습니다.
화면을 보면 오타가 발생한 부분이 표시되어 있고,
타자를 연습한 시간과 정확도, 속도가 표시되는 것을 알 수 있습니다.

=for html <img src="2011-12-23-3.png" alt="영어 속담 연습" /><br />

I<그림 3.> 속담 타자 연습 (문장 모드)

이번에는 영어 속담을 연습 문장 파일로 주었습니다.
원본 파일에는 속담이 알파벳 순으로 정렬되어 있지만,
메뉴에서 2번을 선택하면 무작위로 속담들이 출력됩니다.

=for html <img src="2011-12-23-4.png" alt="종료" /><br />

I<그림 4.> 종료 화면

'quit'을 입력해 프로그램을 종료합니다.
프로그램은 종료되기 전에 최종 연습 시간, 총 정확도, 평균 속도를 출력해줍니다.
제 영타 속도가 그리 빠르지 않군요...-_-;


=head2 정리하며

이렇게 Perl로 타자연습 프로그램을 만들어 보았습니다.
재미있게 보셨는지 모르겠네요.
Perl은 I<재미있고> 쉬우면서 강력한 언어입니다. 
대학원에 입학한 지 4개월 밖에 되지 않았지만,
입학 후 지금까지 제가 학업 면에 있어 가장 잘한 일을 꼽으라면
Perl을 공부한 일을 꼽을 것입니다.
Perl은 제 연구 작업을 30배는 편하게 만들어 주었습니다. 절대로 과장이 아닙니다.

사실 크리스마스는 예수님 생신이면서 동시에 제 생일입니다.(아이디를 보시면 아실 수 있듯이... 아악, 나이가 공개되어 버리는군요 -_-)
이렇게 크리스마스를 맞아 Perl 크리스마스 달력에 기사를 쓰게 된 것이 저에겐 잊을 수 없는 생일선물이 될 것 같습니다.

이 글을 여기까지 읽어주신 여러분께 진심으로 감사를 드립니다.
또한 다시 한번 이 자리를 빌어 저에게 기사 제의를 해 주신 L<@am0c|http://twitter.com/am0c>님께 감사를 드립니다.
그리고 제가 Perl을 처음 공부할 때에 큰 도움이 된 책
L<Modern Perl|http://www.onyxneon.com/books/modern_perl/index.html>의 저자 L<chromatic|http://en.wikipedia.org/wiki/Chromatic_(programmer)>과
Perl을 만든 L<Larry Wall|http://en.wikipedia.org/wiki/Larry_Wall>에게 역시 감사의 말씀을 드립니다. 
그럼, 여러분, 즐거운 성탄절 되세요! 메리 크리스마스!


=head2 참고문서

=over

=item -

L<이야기 모드 연습 예제 파일|2011-12-23-data.txt>


=item -

L<문장 모드 연습 예제 파일|2011-12-23-proverbs.txt>


=item -

L<타자 연습 프로그램|2011-12-23-typing.pl>


=item -

L<Modern Perl|http://www.onyxneon.com/books/modern_perl/index.html> (책 소개, 구입 링크 및 무료 PDF/ePub 공개)


=back

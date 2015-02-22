use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-04.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    Thrift 이리저리 둘러보기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   dalinaum


=head2 저자

L<@dalinaum|http://twitter.com/dalinaum> -
안드로이드 가이. 커피를 좋아하는 지나친 감성주의자.
Lindyhop dancer, Hacker, Perl, LISP, emacs 마니아.
최근에는 안드로이드의 3D 그래픽(렌더스크립트, OpenGL ES)에 심취해 있다.
L<Art of Dalinaum|http://dalinaum-kr.tumblr.com/>을 운영하고 있다.


=head2 시작하며

많은 애플리케이션은 프레젠테이션 레이어와 핵심 로직의 언어를 분리하고 있습니다. 트위터의 경우에는 핵심 로직을 스칼라로 처리하며 프레젠테이션 부분을 루비 언어로 처리합니다. 안드로이드 플랫폼은 프레젠테이션 레이어를 자바와 XML 파일로 구성하며 성능이 중요한 부분은 C와 C++ 언어를 사용하고 있습니다. 앞으로 소프트웨어 개발에 더 다양한 언어의 조합이 등장할 것을 어렵지 않게 예상할 수 있습니다. 펄 언어 만으로 되어 있는 단일한 환경에서는 모듈과 함수 호출로 대부분의 일을 해결할 수 있습니다. 하지만 기존의 방법으로 다양한 언어를 사용한 다채로운 개발 환경을 구성하는 것은 쉽지 않습니다.

L<Thrift|http://thrift.apache.org/>는 페이스북이 개발한 규모 가변적인(scalable) 이종 언어 서비스 개발을 위한 소프트웨어 프레임워크입니다. 이 프레임워크는 2007년에 페이스북에 의해 개발되기 시작하여 2008년 이후 아파치 재단이 유지 보수를 맡고 있습니다. Thrift는 C++, Java, Python, PHP, Ruby, Erlang, Perl, Haskell, C#, Cocoa, Javascript, Node.js, Smalltalk, OCalm 언어 등 다양한 환경을 지원하고 있습니다. 우리가 사용하는 Perl 언어를 비롯해 학계나 산업계가 주목하는 언어들의 대부분을 지원하고 있는 셈입니다. 이렇게 Thrift를 이용하면 다양한 환경의 소프트웨어를 쉽게 결합할 수 있습니다.


=head2 설치하기

Thrift 기술을 활용하기 위해 먼저 서버에 Thrift 구현이 설치되어야 합니다. L<윈도 버전 구현|http://thrift.apache.org/download/>의 빌드 버전은 공식 사이트에서 받을 수 있습니다. 윈도 환경의 사용자는 여기에서 내려받아 설치할 수 있습니다.

=over

=item *

L<Thrift 윈도 바이너리|http://thrift.apache.org/download/>


=back

리눅스 환경과 Mac OS X 환경에서는 빌드하여 구축할 수 있습니다.

=over

=item *

L<Thrift 다운로드 페이지|http://thrift.apache.org/download/>


=item *

L<우분투 환경을 위한 요구 사항|http://wiki.apache.org/thrift/GettingUbuntuPackages>


=back

우분투 환경에서는 아래와 같은 명령어를 입력하여 빌드할 수 있습니다.

    #!bash
    $ ./configure
    $ make
    $ make install

일반적인 빌드 과정과 비슷합니다.

맥에서는 명령행을 통해 직접 빌드하기 보다 L<Homebrew|http://mxcl.github.com/homebrew/>를 이용하여 설치하는 편이 훨씬 더 편리합니다.

=over

=item *

L<Homebrew 공식 페이지|http://mxcl.github.com/homebrew/>


=item *

L<잘가 macports. 반갑습니다. homebrew|http://dalinaum-kr.tumblr.com/post/2986196227/hello-homebrew> .


=back

homebrew가 설치된 환경에서는 아래의 명령으로 진행합니다.

    #!bash
    $ brew install thrift

설치가 끝나면 thrift 명령을 사용할 수 있게 됩니다.


=head2 언어지원 라이브러리 만들기

Thrift가 준비가 되면 개별 언어용 라이브러리를 만들어야 합니다. 여기서는 Java 언어와 Perl 언어를 위한 라이브러리를 빌드해 보겠습니다. Thrift를 C<~/thrift-0.7.0>에 설치했다면 아래와 같이 Java 언어용 라이브러리 코드를 빌드합니다.

    #!bash
    $ cd ~/thrift-0.7.0/lib/java
    $ ant

아래와 같이 Perl 언어용 라이브러리 코드도 만듭시다.

    #!bash
    $ cd ~/thrift-0.7.0/lib/perl
    $ perl Makefile.PL
    $ make
    $ make install


=head2 튜토리얼 코드를 읽어봅시다

먼저 Thrift가 제대로 동작하는지 튜토리얼 버전을 통해 확인해봅시다. C<~/thrift-0.7.0>에 Thrift를 설치했다면 C<~/thrift-0.7.0/tutorial>에 튜토리얼 코드가 있습니다.

    #!bash
    $ cd ~/thrift-0.7.0/tutorial
    $ thrift -r --gen perl tutorial.thrift
    $ cd perl
    $ perl PerlServer.pl &
    $ perl PerlClient.pl 

제대로 동작하면 C<fg> 명령어를 이용해서 서버로 이동한 다음 C<Control + C>(또는 C<Command + C>) 키를 눌러 빠져나옵니다.

생소한 명령어들이 많기 때문에 낯설어 보일 것입니다. 하나씩 짚어보겠습니다. 두번째 줄의 C<thrift -r --gen perl tutorial.thrift>는 C<tutorial.thrift> 파일을 이용해 재귀적으로(C<-r>) 펄 언어용 코드를(C<--gen perl>) 생성하는 것을 의미합니다. Thrift에서 사용하는 언어는 C<.thrift> 확장자를 사용합니다. 지금의 경우 C<tutorial.thrift>가 여기에 해당합니다. C<thrift --gen>으로 코드를 생성할 때 Thrift 파일이 이동되고 서버용 뼈대 코드와 클라이언트용 라이브러리 코드가 만들어져 편리하게 이용할 수 있습니다. 노력을 줄여 클라이언트를 구현할 수 있고 서버측 코드도 뼈대 코드에 살을 붙이는 식으로 구현할 수 있습니다. C<--gen> 옵션에 다른 언어를 지정해 다른 언어를 위한 코드가 생성할 수 있습니다. C<--gen java>를 입력하면 자바용 코드가 만들어질 것입니다.

이제 C<tutorial.thrift> 파일을 살펴보겠습니다. 전체적으로 주석이 많이 달려있어 꼼꼼이 읽으면 대부분의 내용을 이해할 수 있을 것입니다.

    #!plain
    include "shared.thrift"

C<shared.thrift> 파일을 포함하고 있습니다. 따라서 C<shared.thrift>를 먼저 보겠습니다.

    #!plain
    namespace cpp shared
    namespace java shared
    namespace perl shared
    namespace php shared
    
    struct SharedStruct {
      1: i32 key
      2: string value
    }
    
    service SharedService {
      SharedStruct getStruct(1: i32 key)
    }

첫 줄부터 네 번째 줄은 Thrift에서 생성할 언어 별 네임스페이스를 지정합니다. 여기서는 C<cpp>, C<java>, C<perl>, C<php> 언어에서 같은 네임스페이스로 서버 루틴을 사용합니다.

C<struct SharedStruct>는 구조체를 만든 것입니다. 항목이 C<1:>, C<2:>와 같이 콜론이 뒤에 붙은 숫자와 함께 나열되어 점에 유의하세요. 그 뒤에 타입과 이름이 붙습니다. 자료형이 C<i32>와 C<string>인데 해당 자료형은 그 언어에 맞게 자동으로 변환됩니다. 아래는 사용할 수 있는 자료형입니다.

=over

=item *

bool -        Boolean, one byte


=item *

byte -        Signed byte


=item *

i16 -         Signed 16-bit integer


=item *

i32 -         Signed 32-bit integer


=item *

i64 -         Signed 64-bit integer


=item *

double -      64-bit floating point value


=item *

string -      String


=item *

map -  Map from one type to another


=item *

list -    Ordered list of one type


=item *

set -     Set of unique elements of one type


=back

많은 언어에서 기본적으로 제공할만한 자료형이 제공되고 있습니다. 복잡한 자료형은 직렬화하거나 구조체를 만들어 사용해야 합니다.

그 다음으로 C<service>가 위치하는데 C<service> 안에 우리가 사용할 수 있는 함수들이 위치합니다. C<service>는 객체 정도로 볼 수 있습니다. C<SharedStruct getStruct(1: i32 key)>를 보면 매개변수에도 C<1:>과 같이 순서대로 번호를 붙인 것을 볼 수 있습니다.

다시 C<tutorial.thrift>로 돌아와 아직 모르는 부분들을 찾아봅시다.

    #!plain
    php_namespace tutorial

PHP의 경우 별도의 C<namespace>인 C<php_namespace>를 사용하는 것을 볼 수 있습니다. (구체적인 차이점은 모르겠습니다. php에 대해 잘 아시는 분이 설명해주셨으면 좋겠네요 :)

    #!plain
    typedef i32 MyInteger

C 언어에서 익숙하게 볼 수 있는 C<typedef> 구문입니다.

    #!plain
    const i32 INT32CONSTANT = 9853
    const map<string,string> MAPCONSTANT = {'hello':'world', 'goodnight':'moon'}

상수 리터럴은 위와 같이 사용합니다.

    #!plain
    enum Operation {
      ADD = 1,
      SUBTRACT = 2,
      MULTIPLY = 3,
      DIVIDE = 4
    }

열거형입니다.

    #!plain
    exception InvalidOperation {
      1: i32 what,
      2: string why
    }

아래와 같이 예외를 정의할 수도 있습니다.

    #!plain
    i32 calculate(1:i32 logid, 2:Work w) throws (1:InvalidOperation ouch),

뒤에 throws를 붙여서 예외를 던질 수 있게 되어 있습니다. 마지막에 C<,>가 붙어있는 점을 주의하세요. C<service> 내에 여러 함수들이 위치하고 C<,>로 구분됩니다. 펄에서와는 달리 마지막 항목인 경우에는 뒤에는 C<,>를 붙이지 않습니다.

    #!plain
    oneway void zip(),

C<oneway>는 호출을 수행하되 클라이언트가 응답을 기다리지 않겠다는 의미입니다. I/O가 많은 작업들에서 더 효과적인 처리를 기대할 수 있습니다.

이 명세를 한번 보는 것만으로는 이해하기 쉽지 않습니다. 다른 Thrift 명세들도 참고하는 것이 도움이 됩니다.

=over

=item *

L<Hbase.thrift|http://svn.apache.org/viewvc/hbase/trunk/src/main/resources/org/apache/hadoop/hbase/thrift/Hbase.thrift?view=markup>


=back


=head2 이제 서버측 펄 구현을 봅시다!

아래와 같이 서버를 구축할 수 있습니다. C<PerlServer.pl>의 일부를 차용했습니다.

    #!perl
    use strict;
    use lib '../gen-perl';
    use Thrift::Socket;
    use Thrift::Server;
    use tutorial::Calculator;
    
    package CalculatorHandler;
    use base qw(tutorial::CalculatorIf);
    
    sub new {
        my $classname = shift;
        my $self      = {};
    
        return bless($self,$classname);
    }
    
    sub ping {
        print "ping()\n";
    }

위에 정의한 C<tutorial> 네임스페이스의 C<Calculator> 서비스를 구현한 것입니다. C<use base qw(tutorial::CalculatorIf);>로 시작하는 것이 보입니다.

뼈대 클래스가 C<If>가 붙은 형태로 되어 있습니다. 이런 관례는 Thrift가 언어 구현에 따라 다르게 만들어줍니다. 각 언어 구현에 따라 예제를 참고하면 쉽게 파악할 수 있습니다. 나머지 필요한 기능들은 C<sub new>, C<sub ping>과 같이 사용자 함수로 구현합니다.

C<service>의 함수의 작성이 끝나면 이 클래스를 확장하여 서버를 구현합니다.

    #!perl
    eval {
        my $handler       = new CalculatorHandler;
        my $processor     = new tutorial::CalculatorProcessor($handler);
        my $serversocket  = new Thrift::ServerSocket(9090);
        my $forkingserver = new Thrift::ForkingServer($processor, $serversocket);
        print "Starting the server...\n";
        $forkingserver->serve();
        print "done.\n";
    };
    if ($@) {
        if ($@ =~ m/TException/ and exists $@->{message}) {
            my $message = $@->{message};
            my $code    = $@->{code};
            my $out     = $code . ':' . $message;
            die $out;
        } else {
            die $@;
        }
    }

C<CalculatorHandler>는 방금 상속받아 구현한 클래스입니다. 여기에서 C<$processor>에 사용된 C<tutorialProcessor>는 Thrift가 생성한 코드입니다. C<Thrift::ServerSocket>과 C<Thrift::ForkingServer>는 이미 Thrift내에 포함된 클래스입니다.

C<Thrift::ServerSocket>에 포트를 지정하는데 서버와 클라이언트 사이에 약속한 포트 번호를 입력합니다. 서버 내에 Thrift 구현이 여럿일 경우에는 여러 번호가 필요할 것입니다. 예를 들어 서버에서 C<Hbase>나 C<Casandra> 서버가 같이 돌고 있다면 이미 하나의 Thrift 포트를 사용하고 있을 것입니다. 이 때 다른 Thrift 서버는 새 포트 번호가 필요합니다.

아래는 클라이언트 코드의 일부입니다.

    #!perl
    my $socket    = new Thrift::Socket('localhost',9090);
    my $transport = new Thrift::BufferedTransport($socket,1024,1024);
    my $protocol  = new Thrift::BinaryProtocol($transport);
    my $client    = new tutorial::CalculatorClient($protocol);
    
    eval{
        $transport->open();
    
        $client->ping();
        print "ping()\n";
    
        my $sum = $client->add(1,1);
        print "1+1=$sum\n";
    
        my $work = new tutorial::Work();
    
        $work->op(tutorial::Operation::DIVIDE);
        $work->num1(1);
        $work->num2(0);
    
        eval {
            $client->calculate(1, $work);
            print "Whoa! We can divide by zero?\n";
        };
        if ($@) {
            warn "InvalidOperation: ".Dumper($@);
        }
    }


=head2 정리하며

Thrift를 어떻게 설치하고 어떻게 사용할 수 있는지 알아보고, 튜토리얼 코드를 따라가며 기본적인 Thrift의 명세, 서버의 구현, 클라이언트 사용법을 훑어보았습니다. 

서버의 이종 언어의 백엔드/프론트엔드간의 통신, Thrift를 지원하는 다른 서버(Hbase와 Casandra가 대표적입니다.)와의 통신, 서버와의 연결이 필요한 모바일 애플리케이션 등에서 (구글은 이 경우에 자사의 프로토콜버퍼를 사용합니다.) 유용하게 쓰일 수 있을 것입니다.

서버의 이종 언어의 백엔드/프론트엔드간의 통신, Thrift를 지원하는 서버끼리 통신하거나, 서버와의 연결이 필요한 모바일 애플리케이션에 유용하게 쓰일 수 있을 것입니다. 전자의 경우, Hbase와 Casandra가 대표적입니다. 구글은 후자의 경우에 자사의 프로토콜 버퍼를 사용합니다.

Hbase나 Casandra에서 Thrift가 어떻게 사용되시는지 참고하면 도움이 됩니다.

=over

=item *

L<CasandraWiki - ThriftExamples|http://wiki.apache.org/cassandra/ThriftExamples>


=item *

L<HadoopWiki - Hbase/ThriftApi|http://wiki.apache.org/hadoop/Hbase/ThriftApi>


=back

조금 더 재밌고 자세한 내용은 추후에 다루어 보겠습니다.
감사합니다.


=head2 생각해볼 거리

Thrift의 튜토리얼은 현대적이지 못한 펄 코드로 되어 있습니다.
이를 어떻게 개선하면 좋을지에 대한 것은 여러분에게 남겨두겠습니다.

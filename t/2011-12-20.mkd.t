use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-20.mkd';
is markdown_to_pod($file), get_pod(\*DATA), "converting $file";

__DATA__
=encoding utf8

Title:    Mojolicious, HTML5, WebSocket을 이용한 비동기 채팅
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   eeyees


=head2 저자

L<@eeyees|http://twitter.com/eeyees> -
인쇄기기 업계의 기린아, TAFKA_HoliK라는 닉을 사용하기도 한다. 일본에서 일하다가 올해 한국 후지 제록스로 이직하였다.


=head2 시작하며

우리는 지난 기사에서 카탈리스트, 댄서와 같은 웹 프레임워크를 볼 수 있었습니다.
제가 소개시켜 드릴 것은 L<Mojolicious|http://mojolicio.us/>라는 웹 프레임워크입니다.

Mojolicious는 실시간 웹 프레임워크를 표방하고 있습니다.
그 외에도 멋진 특징들이 많이 있습니다. 공식 사이트에서는 아래와 같이 소개하고 있습니다.

=over

=item -

실시간 웹 프레임워크로서 Mojolicious::Lite를 통해 단일 파일로 간소화한 버전도 제공


=item -

REST 라우트, 플러그인, 펄에 적합한 탬플렛, 세션 관리, 서명된 쿠키, 테스팅 프레임워크, 정적 파일 서버, I18N, 최고의 유니코드 지원 등 강력하고 격이 다른 구성


=item -

아주 깔끔하고 이식성 높으며, 비밀스런 작동은 않으며, 펄 5.10.1 외에 의존하는 것이 없다. 순수한 펄 객체지향 API로 제공된다.


=item -

HTTP 1.1 스택을 완전히 지원하고, IPv6, TLS, Bonjour, IDNA, Comet(long polling), chunking과 멀티파트 지원 및 웹소켓 클라이언트/서버 구현 제공


=item -

기본적으로 non-blocking I/O 웹 서버로서, libev와 hot deployment 지원, 임베딩에 최적


=item -

CGI 및 PSGI 자동 인식


=item -

JSON, HTML5/XML 파서 및 CSS3 선택자 지원


=item -

몇 년 간의 Catalyst 개발 경험을 기반으로 깔끔하게 개발됨.


=back

오늘은 가볍게 Mojolicious를 이용해 Websocket으로 비동기 채팅하는 소스 코드를 살펴봅시다.


=head2 뼈대 만들기

리눅스라면 다음과 같은 명령으로 간단하게 설치할 수 있습니다.

    #!bash
    $ sudo sh -c "curl -L cpanmin.us | perl - Mojolicious"

cpan이 설정되어 있다면 아래와 같이 설치합니다.

    #!bash
    $ cpan Mojolicious

Mojolicious가 설치되면 mojo라는 명령행 도구가 생성됩니다.
Mojolicious::Lite를 기반으로 한 간단한 웹 어플리케이션 뼈대를 만들기 위해서는
아래와 같이 입력할 것입니다.

    #!bash
    $ mojo generate lite_app

오늘은 간소화 버전이 아닌 정식 웹 어플리케이션을 만들어 봅시다.
따라서 C<lite_app> 대신 C<app> 타입으로 지정합니다.
어플리케이션의 이름은 Chat로 지어주었습니다.

    #!bash
    $ mojo generate app Chat
      [mkdir] /home/holik/tmp/chat/script
      [write] /home/holik/tmp/chat/script/chat
      [chmod] chat/script/chat 744
      [mkdir] /home/holik/tmp/chat/lib
      [write] /home/holik/tmp/chat/lib/Chat.pm
      [mkdir] /home/holik/tmp/chat/lib/Chat
      [write] /home/holik/tmp/chat/lib/Chat/Example.pm
      [mkdir] /home/holik/tmp/chat/t
      [write] /home/holik/tmp/chat/t/basic.t
      [mkdir] /home/holik/tmp/chat/log
      [mkdir] /home/holik/tmp/chat/public
      [write] /home/holik/tmp/chat/public/index.html
      [mkdir] /home/holik/tmp/chat/templates/layouts
      [write] /home/holik/tmp/chat/templates/layouts/default.html.ep
      [mkdir] /home/holik/tmp/chat/templates/example
      [write] /home/holik/tmp/chat/templates/example/welcome.html.ep

생성된 chat 디렉터리에 들어가 내부 구성을 살펴봅시다.

    #!bash
    ~/tmp$ cd chat
    ~/tmp/chat$ tree
    .
    ├── lib
    │   ├── Chat
    │   │   └── Example.pm
    │   └── Chat.pm
    ├── log
    ├── public
    │   └── index.html
    ├── script
    │   └── chat
    ├── t
    │   └── basic.t
    └── templates
        ├── example
        │   └── welcome.html.ep
        └── layouts
            └── default.html.ep
    
    9 directories, 7 files

C<lib> 아래에 있는 부분이 서버의 컨트롤러 부분이겠군요.
C<log> 디렉터리에는 로그를 남길 것입니다.
C<public>에는 공통적으로 쓰이는 정적 파일이 올라갈 것입니다. 여기서는 html 페이지를 보관하고 있네요.
C<script>에는 구동 스크립트가 들어 있습니다.
C<t> 디렉터리에는 테스트 묶음이 들어갈 것입니다.
C<templates> 부분은 서버의 뷰 부분을 담당하고 있는 친구들인가 보군요.

간단하게 웹 서비스를 한번 실행해 봅시다.
아래와 같이 C<script> 디렉터리에 들어있는 C<chat> 스크립트를 C<morbo> 명령을 통해 실행합니다.

    #!bash
    ~/tmp/chat$ morbo script/chat 
    Server available at http://127.0.0.1:3000.

이제 웹 브라우저에서 L<http://127.0.0.1:3000/welcome|>에 접근해 봅시다.

=for html <img src="2011-12-20-1.png" alt="생성된 뼈대를 구동해 열어본 웹 페이지" /><br  />

I<그림 1.> 생성된 뼈대를 구동해 열어본 웹 페이지

잘 나오네요.
그럼 이제부터 채팅 프로그램을 만들어 봅시다. :)


=head2 비동기 채팅 만들기

C<lib/Chat.pm> 파일에 chat라는 라우트를 추가해 봅시다.
파일을 열면 아까 열어본 C</welcome>도 여기에 정의되어 있습니다.

    #!perl
    package Chat;
    use Mojo::Base 'Mojolicious';
    
    # This method will run once at server start
    sub startup {
      my $self = shift;
    
      # Routes
      my $r = $self->routes;
    
      # Normal route to controller
      $r->route('/welcome')->to('example#welcome');
    }
    
    1;

C</welcome> 라우트를 등록하는 줄 하단에 C</chat>도 같은 형태로 추가합니다.

    #!perl
    $r->route('/chat')->to('ChatControl#chatAction');

C<to>에 전달하는 C<ChatControl#chatAction>은 "C<ChatControl>이라는
컨트롤러에 C<chatAction>이라는 액션을 수행해 주세요."라고 말하는 것과 같습니다.
같은 방식으로 웹소켓을 위한 라우트도 추가합니다.

    #!perl
    $r->websocket('/chatWS')->to('ChatControl#wsAction');


=head3 컨트롤러 작성하기

C<Chat.pm>에 등록해 준 컨트롤러 부분을 구현해봅시다.
C<lib/Chat/ChatControl.pm> 파일을 만들고 chatAction 함수와 wsAction 함수를 만듭니다.

    #!perl
    package Chat::ChatControl;
    use Mojo::Base 'Mojolicious::Controller';
    
    our $clients = {};
    
    sub chatAction {
        my $self = shift;
        $self->render(
            message => 'Chatting Example'
        );
    }
    
    sub wsAction {
        my $self   = shift;
        my $clntID = sprintf "%s" , $self->tx;
    
        $clients->{$clntID} = $self->tx;
    
        for my $id (keys %$clients) {
            $clients->{$id}->send_message("Client Connected!");
        }
    
        say "Client Connected!";
    
        $self->on(
            finish => sub {
                my $self = shift;
                my $id = sprintf "%s" , $self->tx;
            
                delete $clients->{$id};
                say "Client is Disconnected!";
            }
        );
    
        $self->on( 
            message => sub {
                my ($self, $message) = @_;
                for my $id (keys %$clients) {
                    $clients->{$id}->send_message($message);
                }
            }
        );
    }
    
    1;

C<chatAction>은 채팅 웹페이지 위에 표기할 메시지를 전달해 
단순히 템플렛을 랜더링합니다.

C<wsAction>은 웹 소켓으로 통신하는 로직을 작성했습니다.
먼저, C<<< $self->tx >>>를 통해 현재 요청에 대한 트랙잭션 객체(Mojo::Transaction)를 얻습니다.
이 경우 웹 소켓 트랙잭션 객체(Mojo::Transaction::WebSocket)가 될 것입니다.
요청받은 모든 트랜잭션은 단순히 패키지 해시에 보관합니다.

C<<< $self->on >>>을 통해 현재 요청에 대한 트랜잭션에 이벤트 콜백을 등록합니다.
특히 웹 소켓을 통해 메시지가 도착하면 C<message> 이벤트가 수행됩니다.
그러면 보관했던 모든 트랜잭션, 즉 요청했던 모든 클라이언트에게 메시지를 전달합니다.
C<wsAction>의 행동을 위의 두 줄로 요약하면 아래와 같습니다.

=over

=item -

접속되거나 메시지를 받으면 모든 클라이언트에게 메시지 통지(send_message)


=item -

접속이 끊어지면 경우 모든 클라이언트에게 메시지 통지


=back


=head3 뷰 작성하기

이제 뷰 부분을 만들어 보겠습니다.
C<templeates> 디렉터리로 이동한 후 C<ChatControl> 디렉터리를
만들고 그 안에 C<chatAction.html.ep> 파일을 만듭니다.

    #!bash
    $ mkdir ChatControl
    $ cd ChatControl
    $ vim chatAction.html.ep

그리고 다음과 같이 작성해 봅시다.

    #!xml
    %layout 'chatLayout';
    %title 'Chatting';
    <h1>
        <%= $message %>
    </h1>
    <div id="chatWindow">
    </div>
    <form>
        <input type="text" id="sendMes">
        <input type="submit" id="sendBtn" value="Send">
    </form>

채팅을 보일 창 한 개와 채팅을 입력할 부분과 보낼 버튼을 추가 했습니다.
이제 레이아웃을 작성해 볼까요? 이번에는 C<templates/layouts> 디렉터리에
C<chatAction.html.ep>에서 사용한 레이아웃 파일을 만듭니다.

    #!bash
    $ cd ..
    $ cd ..
    $ cd templates/layouts
    $ vim chatLayout.html.ep

이번에는 아래와 같이 작성합니다.

    #!xml
    <!DOCTYPE html>
    <html>
    <head>
      <title><%= title %></title>
      <style type"text/css">
        #chatWindow {
        width : 500px;
        height : 400px;
        overFlow : auto;
        border : 1px solid #000;
        }
      </style>
      <script type="text/javascript"
              src="http://code.jquery.com/jquery-1.7.min.js">
      </script>
      <script type="text/javascript">
      var ws;
      $(document).ready(function() {
      
          $('#sendBtn').click(sendMessage); 
          $('#sendBtn').keyup(function(ev) {
              if( ev.keycode == 13) {
                  sendMessage();
              }
          });
          $('#disconnBtn').click(disconn);
          $('form').submit(function(ev) {
              ev.preventDefault();
          });
          
          if (!("WebSocket" in window)) {
              alert("do not Supprot WebSocket!!");
          } else {
              ws = new WebSocket('ws://localhost:3000/chatWS');
              ws.onopen = function() {
              }
              ws.onmessage = function(ev) {
                  appendChat(ev.data);  
              }
              ws.onclose = function() {
                  appendChat("Connection Closed!");
              }
          }
          
          function sendMessage() {
              ws.send($('#sendMes').val());
              $('#sendMes').val("");
          }
          
          function appendChat(mes) {
              $('#chatWindow').append(mes+"<br>");
          }
          
          function disconn() {
              ws.close();
          }
      });
      </script>
    </head>
    <body>
      <%= content %>
    </body>
    </html>

간단한 자바스크립트 코드를 이용해 웹 소켓의 메시지를 송수신합니다.
브라우저가 웹 소켓을 지원하지 않는지 검사한 뒤, 서버와 접속을 수행합니다.
웹 소켓을 통해 메시지를 받으면 C<onmessage>에 등록한 함수가 호출되어 메시지를 출력합니다.
메시지를 보낼 때에는 C<ws.send(...)>와 같이 웹 소켓을 통해 전달하고 있습니다.
클라이언트에서 메시지를 보낸 이후 페이지를 다시 불러들이는 것을 막기 위해 
C<preventDefault()>를 걸었습니다.

그럼 작성한 소스 코드를 실행해봅시다.

    #!bash
    $ morbo script/chat

=for html <img src="2011-12-20-2.png" alt="완성된 서비스" /><br  />

I<그림 2.> 완성된 서비스

잘 되네요 :)


=head2 정리하며

간단하게 Mojolicious를 웹 프레임워크를 사용해서
HTML5에 포함되는 WebSocket을 이용한 비동기 채팅 웹 서비스를 만들어 보았습니다.
한국에는 아직도 펄하면 단순히 문자열 처리만을 위한 언어라거나 시스템 엔지니어만 다루는 언어로만 알려져 있는 것 같습니다.
이번 펄 크리스마스 달력을 통해 펄의 다양한 활용에 대해서 조금이나마 공유할 수 있는 시간이 되어 다행인 것 같습니다.

2011년 마무리 잘 하시고, 새해 복 많이 받으세요!


use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-19.mkd';
is markdown_to_pod($file), get_pod(\*DATA), "converting $file";

__DATA__
=encoding utf8

Title:    Perl Tatsumaki로 비동기 웹 서비스 구축하기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   luzluna


=head2 저자

L<@luzluna|http://twitter.com/luzluna> -
Seoul.pm과 #perl-kr의 육아 전문 컨설턴트, 사회적 기업을 꿈꾸는 커피 매니아이자 백수.


=head2 시작하며

비동기 웹서버의 유행들을 따라
펄에도 비동기 웹서비스를 제공할만한 좋은 방법들이 몇 가지 생겼습니다.
그 중 L<Tatsumaki|http://search.cpan.org/perldoc?Tatsumaki>는 L<Tatsuhiko Miyagawa|http://search.cpan.org/~miyagawa/>씨께서
L<Tornado|http://www.tornadoweb.org/>를 펄 버전으로 새로 구현한 프레임워크입니다.

비동기 웹서버에 대해 부정적으로 생각하지만(L<Larry Wall|http://en.wikipedia.org/wiki/Larry_Wall>의 표현을 빌어 표현하자면 I<"Not For Human">),
웹 상에서 채팅이나 메신저같은 Long Polling 서비스를 구현하려면 마땅한 다른 방법도 없으니...
필요하면 배워야겠죠. ㅜ.ㅠ


=head2 예제를 봅시다

Tatsumaki 소스를 다운받으면 C<eg> 디렉터리 아래에 L<간단한 채팅 서버 예제|http://search.cpan.org/perldoc?Tatsumaki>가 있습니다.

    #!bash
    $ tree eg/chat
    eg/chat
    |-- app.psgi
    |-- static
    |   |-- DUI.js
    |   |-- jquery-1.3.2.min.js
    |   |-- jquery.cookie.js
    |   |-- jquery.ev.js
    |   |-- jquery.md5.js
    |   |-- jquery.oembed.js
    |   |-- pretty.js
    |   |-- screen.css
    |   `-- Stream.js
    `-- templates
        `-- chat.html

PSGI 어플리케이션으로 되어 있으며 모든 펄 코드는 C<app.psgi>에 집적되어 있습니다.
이 중, 먼저 C<main> 패키지의 코드를 봅시다.

    #!perl
    package main;
    use File::Basename;
    
    my $chat_re = '[\w\.\-]+';
    my $app = Tatsumaki::Application->new([
        "/chat/($chat_re)/poll" => 'ChatPollHandler',
        "/chat/($chat_re)/mxhrpoll" => 'ChatMultipartPollHandler',
        "/chat/($chat_re)/post" => 'ChatPostHandler',
        "/chat/($chat_re)" => 'ChatRoomHandler',
    ]);
    
    $app->template_path(dirname(__FILE__) . "/templates");
    $app->static_path(dirname(__FILE__) . "/static");
    
    return $app->psgi_app;

Tatsumaki::Application를 생성하면서 처리할 URL 패턴과 각 패턴에 대한 핸들러를 추가해줍니다.
그런 다음 템플릿 경로(C<template_path>) 설정도 해주고 정적 파일(C<static_file>)을 처리하기 위한 설정도 추가해줍니다.
여기까지는 간단하죠?

처리할 URL 패턴 중, 먼저 C</chat/($chat_re)>에 접근한다고 가정해 봅시다.
따라서 이번에는 C<ChatRoomHandler>를 보겠습니다.

    #!perl
    package ChatRoomHandler;
    use base qw(Tatsumaki::Handler);
    
    sub get {
        my($self, $channel) = @_;
        $self->render('chat.html');
    }

그냥 C<chat.html> 템플릿을 랜더링하고 있습니다.
C<ChatRoomHandler> 핸들러에 제공된 URL 패턴은 정규표현식이었습니다.
이 정규표현식에 매치가 성공하면 해당 핸들러에 디스패치되고
매치를 통해 일치 변수(C<$1>, C<$2>, C<$3> 등)로 기억된 결과가
핸들러의 변수로 넘어갑니다. 이 경우에는 C<$channel>에
C<$chat_re>에 매치된 문자열이 넘어가겠네요.

핸들러에 HTTP 메소드명의 사용자 함수를 작성하면,
해당 메소드 요청에 대해 연결됩니다.
이 경우에는 C<get> 함수를 정의하여 GET 메소드에 대해 템플릿을 랜더링하도록
하고 있습니다.

이번엔 C<ChatPostHandler>입니다.

    #!perl
    package ChatPostHandler;
    use base qw(Tatsumaki::Handler);
    use HTML::Entities;
    use Encode;
    
    sub post {
        my($self, $channel) = @_;
    
        my $v = $self->request->parameters;
        my $html = $self->format_message($v->{text});
        my $mq = Tatsumaki::MessageQueue->instance($channel);
        $mq->publish({
            type => "message", html => $html, ident => $v->{ident},
            avatar => $v->{avatar}, name => $v->{name},
            address => $self->request->address,
            time => scalar Time::HiRes::gettimeofday,
        });
        $self->write({ success => 1 });
    }
    
    sub format_message {
        my($self, $text) = @_;
        $text =~ s{ (https?://\S+) | ([&<>"']+) }
                  { $1 ? do { my $url = HTML::Entities::encode($1); qq(<a target="_blank" href="$url">$url</a>) } :
                    $2 ? HTML::Entities::encode($2) : '' }egx;
        $text;
    }

핵심적인 코드는 아래와 같이 채널 이름에 맞는 Tatsumaki::MessageQueue를 만드는 코드와

    #!perl
    $mq = Tatsumaki::MessageQueue->instance($channel);

아래와 같이 메시지를 Queue에 쏘는 두 줄이 끝입니다.

    #!perl
    $mq->publish({
        type => "message", html => $html, ident => $v->{ident},
        avatar => $v->{avatar}, name => $v->{name},
        address => $self->request->address,
        time => scalar Time::HiRes::gettimeofday,
    });

채널명에 해당하는 메시지 큐에 채팅을 통해 전달받은 채팅 메시지를 전달하고 있습니다.
메시지 C<"message">로 분류하고, 사용자명, 아바타, 시간, HTML로 랜더링된 메시지 등을 담았습니다.
이번에는 C<ChatPollHander>를 봅시다.

    #!perl
    package ChatPollHandler;
    use base qw(Tatsumaki::Handler);
    __PACKAGE__->asynchronous(1);
    
    use Tatsumaki::MessageQueue;
    
    sub get {
        my($self, $channel) = @_;
        my $mq = Tatsumaki::MessageQueue->instance($channel);
        my $client_id = $self->request->param('client_id')
            or Tatsumaki::Error::HTTP->throw(500, "'client_id' needed");
        $client_id = rand(1) if $client_id eq 'dummy'; # for benchmarking stuff
        $mq->poll_once($client_id, sub { $self->on_new_event(@_) });
    }
    
    sub on_new_event {
        my($self, @events) = @_;
        $self->write(\@events);
        $self->finish;
    }

방금 본 C<post> 함수와 비슷합니다.
먼저 해당 핸들러는 C<<< __PACKAGE__->asynchronous(1); >>>을 통해 비동기 모드로 설정했습니다.
Tatsumaki::MessageQueue 인스턴스를 하나 만들고 C<<< $mq->poll_once >>>로 모든 메시지를 한꺼번에 대기합니다.
핸들러를 비동기 모드로 설정했기 때문에 핸들러 객체에 등록된 Writer 객체를 사용하는
C<write>과 C<finish> 함수로 도착한 이벤트를 출력합니다. 해시 레퍼런스였던 메시지는 JSON으로 변환되어 전달됩니다.
C<ChatMultipartPollHandler>는 어떨까요?

    #!perl
    package ChatMultipartPollHandler;
    use base qw(Tatsumaki::Handler);
    __PACKAGE__->asynchronous(1);
    
    sub get {
        my($self, $channel) = @_;
    
        my $client_id = $self->request->param('client_id') || rand(1);
    
        $self->multipart_xhr_push(1);
    
        my $mq = Tatsumaki::MessageQueue->instance($channel);
        $mq->poll($client_id, sub {
            my @events = @_;
            for my $event (@events) {
                $self->stream_write($event);
            }
        });
    }

이전과 거의 비슷합니다.
대신 멀티파트 C<multipart_xhr_push>를 한 줄 넣어 멀티파트 헤더를 추가해주고
연결을 끊지 않고 계속 poll 하기 위해 C<stream_write>로 이벤트를 전송합니다.

마지막으로 L<plackup|http://search.cpan.org/perldoc?plackup>을 통해서 L<Twiggy|http://search.cpan.org/perldoc?Twiggy>로 띄우면... 채팅 잘 되네요~

    #!bash
    $ plackup -s Twiggy app.psgi


=head2 보너스!

채팅만 하려니까 뭔가 심심해서 재미있는걸 해볼 수 있게 canvas를 추가해봅시다.
C<chat.html>에 아래와 같이 캔버스 한 줄을 추가합니다.

    #!xml
    <canvas id="c" width="200" height="100" style="border:1px solid"></canvas>

그런 다음 아래와 같이 스크립트를 좀 추가해 줍시다.

    #!javascript
    function draw_dot(x,y) {
        var canvas = document.getElementById('c');
        var ctx = canvas.getContext('2d');
        ctx.beginPath();
        ctx.arc(x,y,5,0,Math.PI*2,true);
        ctx.fillStyle = '#5555AA';
        ctx.fill();
        ctx.stroke();
    }
    
    $(function(){
        $('#c').mouseup(function(e) {
            var canoffset = $('#c').offset();
            var x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft - Math.floor(canoffset.left);
            var y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop - Math.floor(canoffset.top) + 1;
            
            draw_dot(x,y);
            
            $.ajax({
                url: "/chat/<%= $channel %>/post",
                data: { type: 'game', x: x, y: y, text:'g' },
                type: 'post',
                dataType: 'json',
                success: function(r) { }
            });
    
        });
    
        var onGameEvent = function(e) {
            draw_dot(e.x, e.y);
        }
        $.ev.handlers.game = onGameEvent;
    });

마지막으로, game 타입의 메시지를 다루기 위해 서버 코드를 조금 수정합니다.

    #!perl
    package ChatPostHandler;
    use base qw(Tatsumaki::Handler);
    use HTML::Entities;
    use Encode;
    
    sub post {
        my($self, $channel) = @_;
    
        for ( keys %{$self->request->parameters} ) {
            $self->request->parameters->{$_} = decode('utf8', $self->request->parameters->{$_});
        }
        my $v = $self->request->parameters;
        my $html = $self->format_message($v->{text});
        my $mq = TatsumakiZeroMQ->instance($channel);
        if (defined $v->{type} && $v->{type} eq 'game' ) {
            $mq->publish({
                type => "game", html => $html,
                x => $v->{x}, y => $v->{y},
                ident => $v->{ident},
                avatar => $v->{avatar}, name => $v->{name},
                address => $self->request->address,
                time => scalar Time::HiRes::gettimeofday,
            });
        }
        else {
            $mq->publish({
                type => "message", html => $html, ident => $v->{ident},
                avatar => $v->{avatar}, name => $v->{name},
                address => $self->request->address,
                time => scalar Time::HiRes::gettimeofday,
            });
        }
        $self->write({ success => 1 });
    }

이제 캔버스에 클릭으로 점을 찍으면 상대편에게도 점이 찍히는게 보이죠?
로직을 좀 구현해넣으면 간단한 게임도 만들 수 있을 것 같고 그림을 공유하는 것도 될 것 같습니다.

=for html <img src="2011-12-19-1.png" alt="완성된 채팅 서비스" />

I<그림 1.> 완성된 채팅 서비스 (L<원본|2011-12-19-1.png>)


=head2 참고 문서

=over

=item -

L<Tatsumaki SlideShare|http://www.slideshare.net/miyagawa/tatsumaki>


=item -

L<Github for Tatsumaki|https://github.com/miyagawa/Tatsumaki>


=item -

L<PSGI/Plack|http://plackperl.org/>


=item -

L<Twiggy|http://search.cpan.org/perldoc?Twiggy>


=back

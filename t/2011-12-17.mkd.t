use lib 't/lib';
use strict;
use warnings;
use Test::More tests => 1;
use Markdown::Pod::Test qw( get_pod markdown_to_pod );

my $file = 't/mkd/2011-12-17.mkd';
is markdown_to_pod($file), get_pod( \*DATA ), "converting $file";

__DATA__
=encoding utf8

Title:    DBIx::Class로 스키마 관리하기
Package:  Seoul.pm
Category: perl
Category: Seoul.pm
Author:   JEEN_LEE


=head2 저자

L<@JEEN_LEE|http://www.twitter.com/JEEN_LEE> - 자칭 0x1c살, 하니아빠, 키보드워리어, 영농후계자, 곶감판매업, 뿌나홀릭, silex 막내


=head2 시작하며

저는 회사 업무에서 펄의 대표적인 프레임워크인 L<Catalyst|http://www.catalystframework.org/>를
사용하고 있습니다. 그 중에서 여느 튜토리얼 문서에서의 기본 구성이라고도 할 수 있는 
L<Catalyst|http://www.catalystframework.org/> + L<Template Toolkit|http://template-toolkit.org/> + L<DBIx::Class|http://search.cpan.org/perldoc?DBIx::Class> 구성으로 사용합니다.
언제나 개발의 시작은 어떤 데이터를 '어떤 구조로 유지'하며 '어떻게 사용하게끔 하느냐'하는
틀을 만드는 것이려나요? 제 생각에는 그렇지 않을까 합니다.
하지만 처음에 생각해서 마련한 틀은 I<시간이 흐름에 따라>, I<개발자 본인의 욕심에 따라>,
I<갑이나 경영진의 변덕스러운 요구사항에 따라> 바뀌기 마련일 겁니다.
이런 과정에 있어서 L<DBIx::Class|http://search.cpan.org/perldoc?DBIx::Class>의 이용에 몇 가지 룰을 정하고 그걸 유지하면
스트레스 덜 받는 행복한 스키마 관리가 이뤄지지 않을까 생각합니다.


=head2 스키마 클래스 생성

여느 Catalyst 튜토리얼의 첫단락이 일단 C<Hello World>를 찍는 것이라면,
아마 그 다음이나 다음다음 작업은 모델을 생성하는 것입니다.
대충 아래와 같은 커맨드에 길고 긴 옵션을 주면 스키마 클래스를 만들 수 있습니다.

    #!bash
    $ ./script/myapp_web_create.pl model MyDB DBIC::Schema MyApp::Schema \
      create=static [options] dbi:mysql:test_db test_user test_password

이렇게 해서 C<test_db>라는 데이터베이스에 속한 테이블이 각각의 결과클래스가 생성됩니다.
그 중 하나의 예를 들면 다음과 같습니다.

    #!perl
    package MyApp::Schema::Result::Access;
    
    # Created by DBIx::Class::Schema::Loader
    # DO NOT MODIFY THE FIRST PART OF THIS FILE
    
    =head1 NAME
    
    MyApp::Schema::Result::Access
    
    =cut
    
    use strict;
    use warnings;
    
    use Moose;
    use MooseX::NonMoose;
    use namespace::autoclean;
    
    extends 'DBIx::Class::Core';
    
    __PACKAGE__->table("access");
    __PACKAGE__->load_components("InflateColumn::DateTime");
    __PACKAGE__->add_columns(
        "id",
        { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
        "address",
        { data_type => "text", is_nullable => 0 },
        "comment",
        { data_type => "text", is_nullable => 1 },
        "created_on",
        {
          data_type => "datetime",
          datetime_undef_if_invalid => 1,
          default_value => "0000-00-00 00:00:00",
          is_nullable => 0,
        },
    );
    
    __PACKAGE__->set_primary_key("id");
    
    # Created by DBIx::Class::Schema::Loader v0.07014 @ 2011-12-09 18:27:52
    # DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8E8XDlgZJWsPmqTw/xP34A
    
    # You can replace this text with custom code or comments, and it will be preserved on regeneration
    __PACKAGE__->meta->make_immutable;
    
    1;


=head2 하지말라고 하면 하지 말자

처음에 언급한 몇가지 룰이라는 것이 있습니다. 가장 중요한 것이 바로 I<'하지말라고 하면 하지 않는다.'>입니다. 
위의 코드 중 주석 부분에는 다음과 같은 글귀가 있습니다.

    #!perl
    # DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8E8XDlgZJWsPmqTw/xP34A

여기의 C<md5sum:8E8XDlgZJWsPmqTw/xP34A>는 해당 결과 클래스의 코드를
MD5 체크섬 값으로서 코드의 변경 유무를 검사하고 있습니다.
어떤 코드를 추가하거나 테이블 관계 설정을 추가로 해야 할 때는
I<반드시 이 문구 아래에서부터 코드를 적어나가도록> 합니다.
이런식으로 말이죠.

    #!perl
    ....
    # DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8E8XDlgZJWsPmqTw/xP34A
    
    __PACKAGE__->belongs_to( xxx => "MyApp::Schema::Result::XXX", { 'foreign.id' => 'self.id' });
    
    sub mission_accessible { ... }
    ....

예전에는 I<저 문구>를 무시하고 그냥 매번 데이터베이스의 변경이 있을 때마다
손으로 하나씩 맞춰주고는 했습니다. 메소드 추가나 관계 설정도 마찬가지였구요.
하지만 나중을 위해서는 반드시 시키는 대로 하는 것이 좋습니다.
특정 테이블에 컬럼이 추가되었다거나, 여러가지 테이블이 추가되었다거나,
그럴 때에는 다시 한번 더 위에서 입력한 스키마 클래스 생성 커맨드를 그대로 다시 실행합니다.
혹여나 이 때 말을 안듣고, I<저 문구> 위에 스페이스 하나라도 잘못 썼다가는
스키마 클래스 자동 완성의 꿈은 깨는 것이 좋습니다.

    #!bash
    $ ./script/myapp_web_create.pl model MyDB DBIC::Schema MyApp::Schema \
      create=static [options] dbi:mysql:test_db test_user test_password
    exists "/*/../lib/MyApp/Web/Model"
    exists "/*/../t"
    Dumping manual schema for MyApp::Schema to directory /*/../lib ...
    DBIx::Class::Schema::Loader::make_schema_at(): Checksum mismatch in '/*/../lib/MyApp/Schema/Result/Access.pm', the auto-generated part of the file has been modified outside of this loader.  Aborting.
    If you want to overwrite these modifications, set the 'overwrite_modifications' loader option. 

그렇지 않을 경우에는 변경되거나 추가된 테이블은 무사히 특정 결과클래스로 덤프됩니다.


=head2 하지만 이건 아니잖아!!

일단 시키는 대로 추가할 관계 설정이나 메소드들은 각각 I<그 문구> 아래에 넣었습니다.
자, 그럼 이 기본적인 틀 안에서 특정 컬럼을 다양한 컴포넌트 모듈을 사용해
확장해가고 싶은 생각도 들기 시작하겠죠?

    #!perl
    __PACKAGE__->load_components("InflateColumn::DateTime");
    ....
    __PACKAGE__->add_columns(
    ....
        "created_on",
        {
          data_type => "datetime",
          datetime_undef_if_invalid => 1,
          default_value => "0000-00-00 00:00:00",
          is_nullable => 0,
        },
    ....
    #DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8E8XDlgZJWsPmqTw/xP34A
    __PACKAGE__->load_components("TimeStamp");
    __PACKAGE__->add_columns(
        "created_on",
        {
          data_type => "datetime",
          datetime_undef_if_invalid => 1,
          default_value => "0000-00-00 00:00:00",
          is_nullable => 0,
          set_on_create => 1,
        }, 
    );
    ....

그래서 일단 I<그 문구> 위에 쓰지 말라고 했으니까, 밑에 추가하고 싶은
컴포넌트(TimeStamp)를 넣고, C<created_on> 컬럼에 해당 컴포넌트의 동작을 발생시키는 
속성 값 C<set_on_create>를 추가합니다.
이렇게 추가한 코드는 SQL C<INSERT>문에 해당하는 액션이 발생했을 때 자동으로
C<created_on> 값을 지정해주도록 합니다.
위에서 아무리 I<그 문구> 위에 쓰지말라고 했어도 중복되는 코드를 매번 이렇게 
적어야 된다니... 맙소사! 거기에 C<created_on> 같은 경우에는 거의 대부분의 테이블에
다 들어가 있다고 생각한다면... 아아.. 끔찍합니다.


=head2 이건 더더욱 아니잖아

C<Access> 이외에 C<Deny>, C<User>, C<Group> 등의 많은 결과클래스가 있다고 합시다.
그리고 이 결과클래스들에 토씨하나 안틀리고 똑같은 메소드가 정의된다고 생각해봅니다.
정말로 피가 DRY합니다.
이 경우에는 대개의 결과 클래스가 상속하고 있는 C<DBIx::Class::Core>를 손을 봐야
되겠죠. 그럼 C<ResultBase>라는 클래스를 만들고 이것이 C<DBIx::Class::Core>를 상속하도록 하고,
그 외 여타 결과클래스들이 C<ResultBase>를 상속받도록 합니다.
C<ResultBase>의 경우는 아래와 같습니다.

    #!perl
    package MyApp::Schema::ResultBase;
    use Moose;
    use MooseX::NonMoose;
    use namespace::autoclean;
    extends 'DBIx::Class::Core';
    
    sub my_method {};
    
    __PACKAGE__->meta->make_immutable;
    
    1;

그리고 결과 클래스에서 이 C<ResultBase>를 상속합니다.

    #!perl
    package MyApp::Schema::Result::Access;
    ....
    - extends 'DBIx::Class::Core';
    + extends 'MyApp::Schema::ResultBase';
    ....

어, 그런데 뭔가 걸립니다.

    #!perl
    # DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8E8XDlgZJWsPmqTw/xP34A

맙소사! C<ResultBase>를 상속하는 것조차도 이 문구위에 놓이게 되니 맘편히 고칠수도 없네요!


=head2 스키마 클래스 덤프에 설정파일을 사용

위에서 스키마 클래스를 덤프할 때 기나긴 옵션이 붙은 커맨드가 있었습니다.
데이터베이스 구성이 바뀌어질 때마다 그 긴 커맨드를
일일이 붙여넣기 식으로 넣어야하니, 좋은 방법 같지는 않습니다.
우선 I<기존 명령>의 사용을 그만두도록 합니다.
컴포넌트 등록이나, C<ResultBase> 클래스 설정이나 컬럼의 속성 추가 등등
매번 스키마 클래스 덤프할 때마다 자신의 상황에 맞게
이것저것 개조(customize)할 필요가 있습니다.

아쉽게도 I<기존 명령>으로 호출되는 L<Catalyst::Model::DBIC::Schema|http://search.cpan.org/perldoc?Catalyst::Model::DBIC::Schema> 모듈에 속해있는
L<Catalyst::Helper::Model::DBIC::Schema|http://search.cpan.org/perldoc?Catalyst::Helper::Model::DBIC::Schema>로는 현재 상황을 헤쳐 나가기 힘듭니다.
그래서 위 모듈 안에서 본질적으로 스키마 클래스 덤프에 사용되는 모듈인
L<DBIx::Class::Schema::Loader|http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader>를 사용합니다.
L<DBIx::Class::Schema::Loader|http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader>가 설치되어 있으면
C<dbicdump>라는 명령이 존재할 것입니다.
이 C<dbicdump> 커맨드에 이제부터 이 상황을 타개할 설정 파일을 담겠습니다.
설정 파일은 L<Config::Any|http://search.cpan.org/perldoc?Config::Any> 모듈로 처리되므로
펄에서 쓰이는 어떤 형식이라도 다룰 수 있습니다.
심지어는 I<펄 코드> 자신도 설정으로 사용할 수 있습니다.
아래는 C<dbicdump> 설정 파일의  예제입니다.

    #!perl
    {
        schema_class => "MyApp::Schema",
        connect_info => {
            dsn  => $ENV{DB_DSN}      || "dbi:mysql:test_db:127.0.0.1",
            user => $ENV{DB_USER}     || "test_user",
            pass => $ENV{DB_PASSWORD} || "test_password",
            mysql_enable_utf8  => 1,
        },
        loader_options => {
            dump_directory     => 'lib',
            naming             => { ALL => 'v8' },
            skip_load_external => 1,
            relationships      => 1,
    
            use_moose          => 1,
            only_autoclean     => 1,
    
            col_collision_map  => 'column_%s',
            result_base_class => 'MyApp::Schema::ResultBase',
            overwrite_modifications => 1,
            datetime_undef_if_invalid => 1,
        
            custom_column_info => sub {
                my ($table, $col_name, $col_info) = @_;
    
                if ($col_name eq 'created_on') {
                    return { %{ $col_info }, set_on_create => 1 };
                }
            },
        },
    }

항목들이 많으므로 전부 설명하는 대신, 위에서 봉착했던 문제에 대해 추려볼까요?
우선 C<ResultBase> 클래스 문제입니다. C<result_base_class> 값을 지정해 줌으로써
모든 결과클래스들은 C<DBIx::Class::Core>가 아니라 C<MyApp::Schema::ResultBase>를
상속받게 됩니다. 물론 C<MyApp::Schema::ResultBase>는 스스로 정의해줘야 합니다.
다음은 컬럼의 컴포넌트를 이용한 확장 문제입니다.
MD5 체크섬 값 아래에 중복되는 코드를 매번 적어주어야 했습니다.
이렇게 사용할 컴포넌트들을 결과클래스 별로 지정하는 대신 C<ResultBase> 클래스를 읽어들입니다.
사실 이처럼 C<ResultBase>를 놓고 여기에 컴포넌트를 일괄해서 읽어들이는 방식은
Cookbook 문서에서도 L<스타트업 속도 향상을 위해 권장|http://search.cpan.org/~arodland/DBIx-Class-0.08196/lib/DBIx/Class/Manual/Cookbook.pod#STARTUP_SPEED>하고 있습니다.

    #!perl
    package MyApp::Schema::ResultBase;
    use Moose;
    use MooseX::NonMoose;
    use namespace::autoclean;
    extends 'DBIx::Class::Core';
    
    __PACKAGE__->load_components(qw/
      InflateColumn::DateTime
      TimeStamp
      ...
    /);
    
    __PACKAGE__->meta->make_immutable;
    
    1;

그리고 컴포넌트의 사용을 위한 컬럼의 속성은
C<custom_column_info> 속성에 코드를 등록해 지정할 수 있습니다.
위의 코드처럼 등록하면 C<created_on>에 C<TimeStamp> 컴포넌트를 사용하기 위한
속성 값인 C<set_on_create>이 모든 결과클래스에 추가됩니다.


=head2 설정파일을 이용한 스키마 덤프

앞에서 정의한 설정파일을 C<schema-loader-config.pl>이라는 파일로 지정하고
다음 명령을 실행하면 좀 더 유연하게 스키마 클래스를 덤프할 수 있습니다.

    #!bash
    $ dbicdump schema-loader-config.pl


=head2 정리하며

=over

=item -

L<DBIx::Class::Schema::Loader|http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader>로 스키마 클래스를 덤프합니다.


=item -

결과 클래스 안의 MD5 체크섬 값에 유의하여 특정 부분 위의 코드는 건드리지 않습니다.


=item -

C<ResultBase> 같은 기본 클래스를 두고 결과클래스 내의 공용 메소드, 컴포넌트들을 일괄로 정의하고 관리하도록 합니다.


=item -

설정 파일을 이용해 추가 속성이 필요한 컬럼 등을 지정할 수 있습니다.


=item -

C<DBIx::Class>는 나쁘지 않습니다.


=item -

여타 설정 항목들에 대해서는 L<DBIx::Class::Schema::Loader::Base|http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader::Base> 모듈 문서를 참고합니다.


=item -

이 모든 작업에 논의와 영감을 준 L<@aanoaa|http://www.twitter.com/aanoaa>(a.k.a. 홍선생)님에게 경의를 표합니다.


=back

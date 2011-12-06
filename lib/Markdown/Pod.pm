package Markdown::Pod;
# ABSTRACT: ...

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use namespace::autoclean;
use autodie;

has 'foo' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub bar {
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__


=head1 SYNOPSIS

...


=head1 DESCRIPTION

...


=attr foo

=attr ...

=method bar

=method ...


=head1 SEE ALSO


=cut

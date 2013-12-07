use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Branches::Branch;
BEGIN {
  $Dist::Zilla::Util::Git::Branches::Branch::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::Git::Branches::Branch::VERSION = '0.001000';
}

# ABSTRACT: A Branch object

use Moose;
our @CARP_NOT;

has git  => ( isa => Object =>, is => ro =>, required => 1 );
has name => ( isa => Str    =>, is => ro =>, required => 1 );


sub sha1 {
  my ($self)  = @_;
  my (@sha1s) = $self->git->rev_parse( $self->name );
  if ( scalar @sha1s > 1 ) {
    require Carp;
    return Carp::confess(q[Fatal: rev-parse branchname returned multiple values]);
  }
  return shift @sha1s;
}


sub delete {
  my ( $self, $params ) = @_;
  if ( $params->{force} ) {
    return $self->git->branch( '-D', $self->name );
  }
  return $self->git->branch( '-d', $self->name );

}


sub move {
  my ( $self, $new_name, $params ) = @_;
  if ( not defined $new_name or not length $new_name ) {
    require Carp;
    local @CARP_NOT = __PACKAGE__;
    Carp::croak(q[Move requires a defined argument to move to, with length >= 1 ]);
  }
  if ( $params->{force} ) {
    return $self->git->branch( '-M', $self->name, $new_name );
  }
  return $self->git->branch( '-m', $self->name, $new_name );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Util::Git::Branches::Branch - A Branch object

=head1 VERSION

version 0.001000

=head1 METHODS

=head2 C<sha1>

Returns the SHA1 of the branch tip.

=head2 C<delete>

    $branch->delete(); # git branch -d $branch->name

    $branch->delete({ force => 1 }); # git branch -D $branch->name

Note: C<$branch> will of course still exist after this step.

=head2 C<delete>

    $branch->move($new_name); # git branch -m $branch->name, $new_name

    $branch->move($new_name, { force => 1 }); # git branch -M $branch->name $new_name

Note: C<$branch> will of course, still exist after this step

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

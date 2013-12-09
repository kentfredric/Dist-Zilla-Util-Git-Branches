use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Branches::Branch;

# ABSTRACT: A Branch object

use Moose;
our @CARP_NOT;

has git  => ( isa => Object =>, is => ro =>, required => 1 );
has name => ( isa => Str    =>, is => ro =>, required => 1 );

=method C<sha1>

Returns the C<SHA1> of the branch tip.

=cut

sub sha1 {
  my ($self)  = @_;
  my (@sha1s) = $self->git->rev_parse( $self->name );
  if ( scalar @sha1s > 1 ) {
    require Carp;
    return Carp::confess(q[Fatal: rev-parse branchname returned multiple values]);
  }
  return shift @sha1s;
}

=method C<delete>

    $branch->delete(); # git branch -d $branch->name

    $branch->delete({ force => 1 }); # git branch -D $branch->name

Note: C<$branch> will of course still exist after this step.

=cut

## no critic (ProhibitBuiltinHomonyms)

sub delete {
  my ( $self, $params ) = @_;
  if ( $params->{force} ) {
    return $self->git->branch( '-D', $self->name );
  }
  return $self->git->branch( '-d', $self->name );

}

=method C<delete>

    $branch->move($new_name); # git branch -m $branch->name, $new_name

    $branch->move($new_name, { force => 1 }); # git branch -M $branch->name $new_name

Note: C<$branch> will of course, still exist after this step

=cut

sub move {
  my ( $self, $new_name, $params ) = @_;
  if ( not defined $new_name or not length $new_name ) {
    require Carp;
    ## no critic (ProhibitLocalVars)
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


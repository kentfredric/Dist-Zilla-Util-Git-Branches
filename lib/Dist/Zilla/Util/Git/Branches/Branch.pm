use strict;
use warnings;
use utf8;

package Dist::Zilla::Util::Git::Branches::Branch;

# ABSTRACT: A Branch object

use Moose;
extends 'Dist::Zilla::Util::Git::Refs::Ref';

our @CARP_NOT;

=method C<new_from_Ref>

Convert a Git::Refs::Ref to a Git::Branches::Branch

    my $branch = $class->new_from_Ref( $ref );

=cut

sub new_from_Ref {
  my ( $class, $object ) = @_;
  if ( not $object->can('name') ) {
    require Carp;
    return Carp::croak("Object $object does not respond to ->name, cannot Ref -> Branch");
  }
  my $name = $object->name;
  if ( $name =~ qr{\Arefs/heads/(.+\z)}msx ) {
    return $class->new(
      git  => $object->git,
      name => $1,
    );
  }
  require Carp;
  Carp::croak("Path $name is not in refs/heads/*, cannot convert to Branch object");
}

sub refname {
    my ( $self ) = @_;
    return 'refs/heads/' . $self->name;
}

=method C<sha1>

Returns the C<SHA1> of the branch tip.

=cut

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

=method C<move>

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


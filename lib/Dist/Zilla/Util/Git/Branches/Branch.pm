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

has git => ( isa => Object =>, is => ro =>, required => 1 );
has name => ( isa => Object =>, is => ro =>, required => 1 );

sub sha1 { 
    my ( $self ) = @_;
    my (@sha1s) = $self->git->rev_parse( $self->name );
    if ( scalar @sha1s > 1 ) {
        require Carp;
        return Carp::confess(q[Fatal: rev-parse branchname returned multiple values]);
   }
    return shift @sha1s;
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

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

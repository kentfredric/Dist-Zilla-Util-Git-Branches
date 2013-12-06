use strict;
use warnings;

package Dist::Zilla::Util::Git::Branches;
BEGIN {
  $Dist::Zilla::Util::Git::Branches::AUTHORITY = 'cpan:KENTNL';
}
{
  $Dist::Zilla::Util::Git::Branches::VERSION = '0.001000';
}

# ABSTRACT: Extract branches from Git


use Moose;
use MooseX::LazyRequire;

has 'zilla' => ( is => ro =>, isa => Object =>, lazy_required => 1 );
has 'git'   => ( is => ro =>, isa => Object =>, lazy_build    => 1 );

sub _build_git {
  my ($self) = @_;
  require Dist::Zilla::Util::Git::Wrapper;
  return Dist::Zilla::Util::Git::Wrapper->new( zilla => $self->zilla );
}

sub _mk_branch {
    my ( $self, $branchname ) = @_;
    require Dist::Zilla::Util::Git::Branches::Branch;
    return Dist::Zilla::Util::Git::Branches::Branch->new(
        git => $self->git,
        name => $branchname,
    );
}
sub _mk_branches {
    my ( $self, @branches ) = @_;
    return map { $self->_mk_branch($_) } @branches;
}

sub branches {
    my ( $self, ) = @_;
    my @out;
    for my $commdata ( $self->git->for_each_ref('refs/heads/*', '--format=%(objectname) %(refname)') ) {
        if ( $commdata =~ qr{ \A (^[ ]+) [ ] refs/heads/ ( .+ ) \z }msx  ) {
            my ( $sha, $branch ) = ( $1, $2 );
            push @out, $self->_mk_branch( $branch );
        }
    }
    return @out;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Util::Git::Branches - Extract branches from Git

=head1 VERSION

version 0.001000

=head1 SYNOPSIS

This module aims to do what you want when you think you want to parse the output of

    git branch

Except it works the right way, and uses

    git for-each-ref

So

    use Dist::Zilla::Util::Git::Branches;

    my $branches = Dist::Zilla::Util::Git::Branches->new(
        zilla => $self->zilla
    );
    for my $branch ( $branches->branches ) {
        printf "%s %s", $branch->name, $branch->sha1;
    }

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

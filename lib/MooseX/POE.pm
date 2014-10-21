package MooseX::POE;

our $VERSION = 0.200;

use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => [qw(event)],
    also        => 'Moose',
);

sub init_meta {
    my ($class, %args) = @_;

    my $for = $args{for_class};
    eval qq{package $for; use POE; };
   
    Moose->init_meta(
      for_class => $for
    );

    Moose::Util::MetaRole::apply_metaclass_roles(
      for_class => $for,
      metaclass_roles => [ 'MooseX::POE::Meta::Trait::Class' ],
      constructor_class_roles => [ 'MooseX::POE::Meta::Trait::Constructor' ],
      instance_metaclass_roles => [ 'MooseX::POE::Meta::Trait::Instance' ],
    );

    Moose::Util::MetaRole::apply_base_class_roles(
      for_class => $for,
      roles => ['MooseX::POE::Meta::Trait::Object']
    );
}

sub event {
    my ( $caller, $name, $method ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_state_method( $name => $method );
}

1;
__END__

=head1 NAME

MooseX::POE - The Illicit Love Child of Moose and POE

=head1 VERSION

This document describes MooseX::POE version 0.200

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE;

    has name => (
        isa     => 'Str',
        is      => 'rw',
        default => sub { 'Foo ' },
    );

    has count => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        default => sub { 0 },
    );

    sub START {
        my ($self) = @_;
        $self->yield('increment');
    }

    event increment => sub {
        my ($self) = @_;
        print "Count is now " . $self->count . "\n";
        $self->count( $self->count + 1 );
        $self->yield('increment') unless $self->count > 3;
    };

    no MooseX::POE;
    
    Counter->new();
    POE::Kernel->run();
  
=head1 DESCRIPTION

MooseX::POE::Object is a Moose wrapper around a POE::Session.

=head1 KEYWORDS

=over

=item event $name $subref

Create an event handler named $name. 

=back

=head1 METHODS

Default POE-related methods are provided by L<MooseX::POE::Meta::Trait::Object>
which is applied to your base class (which is usually L<Moose::Object>) when
you use this module. See that module for the documentation for. Below is a list
of methods on that class so you know what to look for:

=over

=item get_session_id

=item yield

=item call

=item STARTALL

=item STOPALL

=back


=head1 DEPENDENCIES

L<Moose>, L<POE>


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to C<bug-moosex-poe@rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org>.

=head1 AUTHOR

Chris Prather  C<< <perigrin@cpan.org> >>

Ash Berlin C<< <ash@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007-2009, Chris Prather C<< <perigrin@cpan.org> >>, Ash Berlin
C<< <ash@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

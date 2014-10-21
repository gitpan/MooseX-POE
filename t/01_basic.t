use strict;
use Test::More no_plan => 1;

{

    package Counter;
    use MooseX::POE;

    has count => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        default => sub { 1 },
    );

    sub START {
        my ($self, $kernel, $session) = @_[OBJECT, KERNEL, SESSION];
        ::pass('Starting ');
        ::isa_ok($kernel, "POE::Kernel", "kernel in START");
        ::isa_ok($session, "POE::Session", "session in START");
        $self->yield('dec');
    }

    event inc => sub {
        my ($self) = $_[OBJECT];
        ::pass( $self . ':' . $self->count );
        $self->count( $self->count + 1 );
        return if 3 < $self->count;
        $self->yield('inc');
    };

    sub on_dec {
        my ($self) = $_[OBJECT];
        ::pass('decrement');
		$self->count($self->count - 1 );
		$self->yield('inc');
    }

    sub STOP {
        ::pass('Stopping');
    }

    no MooseX::POE;
}

my @objs = map { Counter->new } ( 1 .. 10 );
POE::Kernel->run();

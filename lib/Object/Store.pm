=head1 NAME

Object::Store - abstract class to store, modify, delete and search Perl objects


=head1 METHODS


=head2 $store = Object::Store->new (backend => $store_backend).

Instantiates a new Object::Store object using backend $store_backend.

$store_backend must implement the set(), get(), del() and list() methods.
It can also optionally implement the find() method, otherwise the default
find() is used.


=head2 $store->set ($object_id => $object);

Inserts or update an object.


=head2 $store->get ($class, $object_id);

Returns an object.


=head2 $storage->del ($class, $object_id);

Removes an object.


=head2 $storage->list ($class);

Returns a list of object IDs.


=head2 $storage->find (%args);

Generic 'search for stuff' method.

If $store_backend->find() exists, calls $store_backend->find(%args)

Otherwise, it creates a list of objects using list() and get() and performs
the search on the object list, assuming objects are hash references. The
default syntax for %args is

  foo => "<operand><value>",
  bar => "<operand><value>",
  etc.

Where <operand> is eq:, ne:, le:, lt:, gt:, ge:, gt:, ==:, >=:, >:, <=:, <:
same behavior as Perl equivalent comparators.

You can also use like:, which behaves like SQL LIKE statements where % matches
any substring and _ matches any character.

You can also use regexp: and use a Perl regexp.

If no valid operand is used, it assumes eq:.

Returns a list of matching objects.

=cut
package Object::Store;
use warnings;
use strict;


our $VERSION = '0.01';


sub new
{
    my $class = shift;
    my $self  = bless { @_ }, $class;
    return $self;
}


sub set
{
    my $self   = shift;
    my $id     = shift;
    my $object = shift;
    $self->{backend}->set ($id, $object);
}
    

sub get
{
    my $self   = shift;
    my $id     = shift;
    my $object = shift;
    $self->{backend}->get ($id, $object);
}


sub del
{
    my $self   = shift;
    my $id     = shift;
    my $object = shift;
    $self->{backend}->del ($id, $object);
}


sub list
{
    my $self   = shift;
    my $object = shift;
    $self->{backend}->list();
}


sub find
{
    my $self = shift;
    if ($self->{backend}->can ('find'))
    {
        $self->{backend}->find (@_);
    }
    else
    {
        my %args = @_;
        my @res  = ();
        
        ITEM:
        foreach my $item ( map { $self->get ($_ ) } $self->list() )
        {
            foreach my $attribute (keys %args)
            {
                my $value = $args{$attribute};
                
                if ($value =~ s/^eq://) {
                    $item->{$attribute} eq $value or next ITEM;
                }
                
                elsif ($value =~ s/^ne://) {
                    $item->{$attribute} ne $value or next ITEM;
                }
                
                elsif ($value =~ s/^lt://) {
                    $item->{$attribute} lt $value or next ITEM;
                }
                
                elsif ($value =~ s/^le://) {
                    $item->{$attribute} lt $value or next ITEM;
                }
                
                elsif ($value =~ s/^gt://) {
                    $item->{$attribute} gt $value or next ITEM;
                }
                
                elsif ($value =~ s/^ge://) {
                    $item->{$attribute} ge $value or next ITEM;
                }
                
                elsif ($value =~ s/^==://) {
                    $item->{$attribute} == $value or next ITEM;
                }
                
                elsif ($value =~ s/^>=://) {
                    $item->{$attribute} >= $value or next ITEM;
                }
                
                elsif ($value =~ s/^>://) {
                    $item->{$attribute} > $value or next ITEM;
                }
                
                elsif ($value =~ s/^<=://) {
                    $item->{$attribute} <= $value or next ITEM;
                }
                
                elsif ($value =~ s/^<://) {
                    $item->{$attribute} < $value or next ITEM;
                }
                
                elsif ($value =~ s/^like://) {
                    $value =~ s/\%/\.\*/g;
                    $value =~ s/\_/\./g;
                    $item->{$attribute} =~ /^$value$/ or next ITEM;
                }

                elsif ($value =~ s/^regexp://) {
                    $item->{$attribute} =~ /^$value$/ or next ITEM;
                }
                
                else {
                    $item->{$attribute} eq $value or next ITEM;
                }
                
                push @res, $item;
            }
        }
        return @res;
    }
}


1;


__END__
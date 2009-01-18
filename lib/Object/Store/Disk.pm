=head1 NAME

Object::Store::Disk - backend to disk storage


=head1 API


=head2 $self->new ("/path/to/dir");

Creates a new Object::Store::Disk backend. "path/to/dir" must be a valid
directory and Object::Store::Disk must have permissions. To avoid exploits,
Object::Store::Disk dies if you attempt to use anything else than [A-Za-z_-]
in an object id.


=head2 $self->set ($id => $object);

Saves object $object under id $id.


=head2 $self->get ($id);

Returns object $object with id $id.


=head2 $self->del ($id);

Removes object with id $id.


=head2 $self->list();

Returns a list of objects saved under this backend.

=cut
package Object::Store::Disk;
use Data::Dumper;
use warnings;
use strict;


sub new
{
    my $class = shift;
    my $path  = shift;
    return bless \$path, $class;
}


sub set
{
    my $self   = shift;
    my $id     = $self->_check_id (shift);
    my $object = shift;
    $self->_write ($id, $object);
}


sub get
{
    my $self   = shift;
    my $id     = $self->_check_id (shift);    
    my $path   = $$self;
    
    open FP, "$path/$id.obj" or return;
    my $string = join '', <FP>;
    close FP;
    
    my $VAR1;
    eval $string;
    return $VAR1;
}


sub del
{
    my $self  = shift;
    my $id     = $self->_check_id (shift);    
    my $path   = $$self;
    unlink ("$path/$id.obj");
}


sub list
{
    my $self  = shift;
    my $path  = $$self;
    
    my @res = ();
    -e $path or return @res;
    -d $path or return @res;
    
    opendir DD, $path;
    my @files = map { /\.obj$/ ? $_ : () } readdir (DD);
    closedir DD;
    
    for (@files)
    {
        s/\.obj$// or next;
        push @res, $_;
    }
    
    return @res;
}



# ============================================================================
# semi private / utility methods
# ============================================================================


sub _check_id
{
    my $self = shift;
    my $id   = shift;
    $id =~ /^[A-Za-z0-9_-]+$/ or die "not a valid file id";
    return $id;
}


sub _write
{
    my $self   = shift;
    my $id     = shift;
    my $object = shift;
    
    my $path   = $$self;
    
    open FP, ">$path/$id.obj";
    print FP Dumper ($object);
    close FP;
}


1;


__END__

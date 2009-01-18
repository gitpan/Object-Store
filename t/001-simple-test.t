#!/usr/bin/perl
use Test::More 'no_plan';
use lib ("./lib", "../lib");
use Object::Store;
use Object::Store::Disk;
use Data::Dumper;


package Foo;

sub new {
    my $class = shift;
    return bless { @_ }, $class;
}

package main;

mkdir "./test";

my $store = Object::Store->new ( backend => Object::Store::Disk->new ("./test") );
$store->set ('foo1' => Foo->new ('attr' => 'foo1', 'num' => 1));
$store->set ('foo2' => Foo->new ('attr' => 'foo2', 'num' => 2));
$store->set ('foo3' => Foo->new ('attr' => 'foo3', 'num' => 3));

ok (-e "./test/foo1.obj");
ok (-e "./test/foo2.obj");
ok (-e "./test/foo3.obj");

my @list = $store->list();
ok (@list == 3);

@list = $store->find (attr => 'eq:foo1', num => '==:1');
ok ($list[0]->{attr} eq 'foo1');
ok ($list[0]->{num} == 1);

$store->del ('foo1');
@list = $store->find (attr => 'eq:foo1', num => '==:1');
ok (@list == 0);

map { $store->del ($_) } $store->list();
@list = $store->list();
ok (@list == 0);

rmdir "./test";

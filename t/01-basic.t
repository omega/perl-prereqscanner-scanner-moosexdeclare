use strict;
use warnings;
use Test::More;
use PPI;
use Try::Tiny;



use aliased 'Perl::PrereqScanner' => 'PS';

sub is_prereqs {
    my ($code, $reqs) = @_;

    my $scanner = PS->new({ extra_scanners => [qw/MooseXDeclare/] });

    my $ppi_document  = PPI::Document->new(\$code);
    try {
        my $res = $scanner->scan_ppi_document( $ppi_document );
        is_deeply( $res->as_string_hash, $reqs );
    } catch {
        fail("Scanner died");
        diag($_);
    };
}


is_prereqs('class A extends KiokuX::Model { }', { 'KiokuX::Model' => 0 });
is_prereqs('namespace A; class ::B extends ::Model { }', { 'A::Model' => 0 });
is_prereqs('with qw(A::Role);', { 'A::Role' => 0 });
is_prereqs('namespace A; with qw(::Role);', { 'A::Role' => 0 });


done_testing();




__DATA__



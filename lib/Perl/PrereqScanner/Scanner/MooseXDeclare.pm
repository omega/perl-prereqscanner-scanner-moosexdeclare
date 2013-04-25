use strict;
use warnings;
package Perl::PrereqScanner::Scanner::MooseXDeclare;
use Moose;
with 'Perl::PrereqScanner::Scanner';
# ABSTRACT: Scan for MooseX::Declare sugar deps

sub scan_for_prereqs {
    my ($self, $ppi_doc, $req) = @_;
    my @candidates =
    map { $_->snext_sibling }
    grep { $_->literal =~ m/\A(?:with|extends)\z/ }
    @{ $ppi_doc->find('PPI::Token::Word') || [] };

    for (@candidates) {
        $req->add_minimum($_ => 0);
    }
}

1;

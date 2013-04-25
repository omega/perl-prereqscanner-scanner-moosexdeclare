use strict;
use warnings;
package Perl::PrereqScanner::Scanner::MooseXDeclare;
use Moose;
with 'Perl::PrereqScanner::Scanner';
# ABSTRACT: Scan for MooseX::Declare sugar deps

sub scan_for_prereqs {
    my ($self, $ppi_doc, $req) = @_;

    #use Data::Dump;
    #warn Data::Dump::dump $ppi_doc;
    my $namespace_node = $ppi_doc->find_first(sub {
            my ($root, $node) = @_;
            $node->isa('PPI::Token::Word') and $node->content eq 'namespace';
        });
    my $namespace = $namespace_node ? $namespace_node->snext_sibling->content : '';
    my @candidates =
    map {
    if ($_->isa('PPI::Token::Quote') || $_->isa('PPI::Token::QuoteLike')) {
    ( $self->_q_contents( $_ ) )
    } else {
    $_;
    }
    }
    map { $_->snext_sibling }
    grep { $_->literal =~ m/\A(?:with|extends)\z/ }
    @{ $ppi_doc->find('PPI::Token::Word') || [] };

    for (@candidates) {
        my $pkg = $_;
        if ($pkg =~ m/^::/) {
            die "No namespace found, but $pkg indicates namespace need" unless $namespace;;
            $pkg = $namespace . $pkg;
        }
        $req->add_minimum($pkg => 0);
    }
}

1;

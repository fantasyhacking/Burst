package CPEPF;

use strict;
use warnings;

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
    return $self;
}

sub handleEPFGetField {
	my $self = shift;
}

sub handleEPFSetField {
	my $self = shift;
}

sub handleEPFGetComMessages {
	my $self = shift;	
}

sub handleEPFGetAgent {
	my $self = shift;	
}

sub handleEPFSetAgent {
	my $self = shift;
}

sub handleEPFGetRevisions {
	my $self = shift;
}

sub handleEPFAddItem {
	my $self = shift;
}

1;
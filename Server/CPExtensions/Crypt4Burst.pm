package Crypt4Burst;

use strict;
use warnings;

use Bytes::Random::Secure qw(random_string_from);
use Math::Round qw(round);

sub new {
	my $self = bless {}, shift;
    return $self;
}

sub generateKey {
	my $self = shift;
	my $_length = shift;
	my $_key = random_string_from(join( '', ('a' .. 'z'), ('A' .. 'Z'), ('0' .. '9'), ('_')), $_length);
	return $_key;
}

sub generateRandomNumber {
	my $self = shift;
	my $_start = shift;
	my $_end = shift;
	my $_rand = rand($_end - $_start);
	my $_integer = int($_start + $_rand);
	return $_integer;
}

sub getTimeDifference {
	my $self = shift;
	my $_past = shift;
	my $_present = shift;
	my $_format = shift;
	my $_difference = round(($_past - $_present) / $_format);
	return $_difference; 
}

1;
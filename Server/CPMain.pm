package CPMain;

use strict;
use warnings;

use XML::Simple;

use sigtrap 'handler' => \&handleSignals, 'normal-signals';
use sigtrap 'handler' => \&handleSignals, 'error-signals';

sub handleSignals {}

sub new {
	my $self = bless {}, shift;
	$self->{logger} = Log4Burst->new;
	$self->initiateBurst;
    return $self;
}

sub initiateBurst {
	my $self = shift;
	$self->displayAscii;
	$self->loadConfiguration;
	$self->initiateExtensions;
	$self->loadCrumbs;
	$self->{mysql}->connectMySQL;
}

sub loadConfiguration {
	my $self = shift;
	my $_config = $self->parseXML('Config.xml');
	if (!$_config) {
		$self->{logger}->displayMessage('Failed to configuration', 'err', 1, 0);
	} else {
		$self->{config} = $_config;
		$self->{logger}->displayMessage('Successfully loaded configuration', 'inf', 0, 0);
	}
}

sub initiateExtensions {
	my $self = shift;
	$self->{crypt} = Crypt4Burst->new;
	$self->{parser} = Parser4Burst->new($self);
	$self->{socket} = CPServer->new($self);
	$self->{mysql} = MySQL4Burst->new($self);
	$self->{loginsys} = CPLogin->new($self);
	$self->{gamesys} = CPGame->new($self);
}

sub loadCrumbs {
	my $self = shift;
	$self->{item_crumbs} = \%CPItems::_items;
	$self->{epf_crumbs} = \%CPEPFItems::_epf_items;
	$self->{igloo_crumbs} = \%CPIgloos::_igloos;
	$self->{furniture_crumbs} = \%CPFurnitures::_furnitures;
	$self->{floor_crumbs} = \%CPFloors::_floors;
	$self->{room_crumbs} = \%CPRooms::_rooms;
	$self->{game_room_crumbs} = \%CPGameRooms::_game_rooms;
	$self->{stamp_crumbs} = \%CPStamps::_stamps;
	$self->{postcard_crumbs} = \%CPPostcards::_postcards;
	$self->{logger}->displayMessage('Successfully loaded server crumbs', 'inf', 0, 0);
}

sub parseXML {
	my $self = shift;
	my $_data = shift;
	my $_xml;
	eval {
	   $_xml = XML::Simple->new->XMLin($_data);
	};
	if ($@) {
		$self->{logger}->displayMessage("Invalid xml: $@", 'wrn', 1, 0);
		return 0;
	}
	return $_xml;
}

sub displayAscii {
	my $self = shift;	
	print "\n\r";
	print "+-+-+-+-+-+\n";
	print "|B|u|r|s|t|\n";
	print "+-+-+-+-+-+++++++++++++++++++++++++++\n\r";
	print "+ Club Penguin Server Emulator      +\n";
	print "+ Protocol: Actionscript 2.0        +\n";
	print "+ Author: Lynx                      +\n";
	print "+ License: MIT                      +\n";
	print "+++++++++++++++++++++++++++++++++++++\n\n";
}

1;
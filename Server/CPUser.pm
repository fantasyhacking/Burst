package CPUser;

use strict;
use warnings;

use Switch;
use Math::Round qw(round);
use HTTP::Date qw(str2time);

sub _signal_handler {
  exit(0);
}

sub new {
	my $self = bless {}, shift;
    $self->{parent} = shift;
	$self->{sock} = shift;
	$self->{ID} = undef;
	$self->{username} = undef;
	$self->{nickname} = undef;
	$self->{coins} = undef;
	$self->{lkey} = undef;
	$self->{doj} = undef;
	$self->{is_banned} = undef;
	$self->{invalid_logins} = undef;
	$self->{color} = undef;
	$self->{head} = undef;
	$self->{face} = undef;
	$self->{neck} = undef;
	$self->{body} = undef;
	$self->{hands} = undef;
	$self->{feet} = undef;
	$self->{pin} = undef;
	$self->{photo} = undef;
	$self->{rank} = undef;
	$self->{is_staff} = undef;
	$self->{igloo} = undef;
	$self->{music} = undef;
	$self->{floor} = undef;
	$self->{furniture} = undef;
	$self->{is_agent} = undef;
	$self->{agent_status} = undef;
	$self->{epf_current_points} = undef;
	$self->{epf_total_points} = undef;
	$self->{stamps} = [];
	$self->{restamps} = [];
	$self->{inventory} = [];
	$self->{owned_igloos} = [];
	$self->{owned_furnitures} = {};
	$self->{buddies} = {};
	$self->{ignored} = {};
	$self->{room} = 0;
	$self->{xpos} = 0;
	$self->{ypos} = 0;
	$self->{frame} = 0;
    return $self;
}

sub sendData {
	my $self = shift;
	my $_data = shift;
	$_data .= chr(0);
	$self->{sock}->{client}->put($_data);
	$self->{parent}->{logger}->displayMessage('Outgoing data: ' . $_data, 'dbg', 1, 0);
}

sub sendRoom {
	my $self = shift;
	my $_data = shift;
	foreach my $_client (values %{$self->{parent}->{socket}->{clients}}) {
		if ($_client->{room} == $self->{room}) {
			$_client->sendData($_data);
		}
	}
}

sub sendError {
	my $self = shift;
	my $_err = shift;
	$self->sendData('%xt%e%-1%' . $_err . '%');
}

sub loadInformation {
	my $self = shift;
	my $_userID = $self->{ID};
	my $_penguin_info = $self->{parent}->{mysql}->getPenguinInfo($_userID);
	my $_igloo_info = $self->{parent}->{mysql}->getIglooInfo($_userID);
	my $_epf_info = $self->{parent}->{mysql}->getEPFInfo($_userID);
	my $_stamps_info = $self->{parent}->{mysql}->getStampsInfo($_userID);
	$self->handleLoadPenguinInfo($_penguin_info);
	$self->handleLoadIglooInfo($_igloo_info);
	$self->handleLoadEPFInfo($_epf_info);
	$self->handleLoadStampsInfo($_stamps_info);
}

sub handleLoadPenguinInfo {
	my $self = shift;
	my $_info = shift;
	while (my ($_key, $_value) = each(%{$_info})) {
		switch ($_key) {
			case ('doj') {
				$self->{doj} = round((time - str2time($_value)) / 86400);
			}		
			case ('inventory') {
				my @_items = split('%', $_value);
				foreach my $_item (@_items) {
					push(@{$self->{inventory}}, $_item);
				}
			}
			case ('buddies') {
				my @_buddies = split(',', $_value);
				foreach my $_buddy (@_buddies) {
					my ($_userID, $_username) = split('\\|', $_buddy);
					$self->{buddies}->{$_userID} = $_username;
				}
			}
			case ('ignored') {
				my @_ignores = split(',', $_value);
				foreach my $_ignored (@_ignores) {
					my ($_userID, $_username) = split('\\|', $_ignored);
					$self->{ignored}->{$_userID} = $_username;
				}
			} else {
				$self->{$_key} = $_value;
			}
		}
	}
}

sub handleLoadIglooInfo {
	my $self = shift;
	my $_info = shift;
	while (my ($_key, $_value) = each(%{$_info})) {
		switch ($_key) {
			case ('owned_igloos') {
				my @_igloos = split('\\|', $_value);
				foreach my $_igloo (@_igloos) {
					push(@{$self->{owned_igloos}}, $_igloo);
				}
			}
			case ('owned_furnitures') {
				my @_furnitures = split(',', $_value);
				foreach my $_furniture (@_furnitures) {
					my ($_userID, $_quantity) = split('\\|', $_furniture);
					$self->{owned_furnitures}->{$_userID} = $_quantity;
				}
			} else {
				$self->{$_key} = $_value;
			}			
		}
	}	
}

sub handleLoadEPFInfo {
	my $self = shift;
	my $_info = shift;
	while (my ($_key, $_value) = each(%{$_info})) {
		$self->{$_key} = $_value;
	}
}

sub handleLoadStampsInfo {
	my $self = shift;
	my $_info = shift;
	while (my ($_key, $_value) = each(%{$_info})) {
		switch ($_key) {
			case ('stamps') {
				my @_stamps = split('\\|', $_value);
				foreach my $_stamp (@_stamps) {
					push(@{$self->{stamps}}, $_stamp);
				}
			}
			case ('restamps') {
				my @_restamps = split('\\|', $_value);
				foreach my $_restamp (@_restamps) {
					push(@{$self->{restamps}}, $_restamp);
				}
			} else {
				$self->{$_key} = $_value;
			}
		}
	}
}

sub buildClientString {
	my $self = shift;
	my @_info = (
		$self->{ID},
		$self->{nickname}, 1,
		$self->{color},
		$self->{head},
		$self->{face},
		$self->{neck},
		$self->{body},
		$self->{hands},
		$self->{feet},
		$self->{pin},
		$self->{photo},
		$self->{xpos},
		$self->{ypos},
		$self->{frame}, 1,
		($self->{rank} * 146)
	);
	my $_details = join('|', @_info);
	return $_details;	
}

sub joinRoom {
	my $self = shift;
	my ($_room, $_xpos, $_ypos) = @_;
	$self->removePlayer;
	$self->{frame} = 0;
	if ($_room == 999) {
		$self->{room} = $_room;
		$self->{xpos} = $_xpos;
		$self->{ypos} = $_ypos;
		return $self->sendData('%xt%jx%-1%' . $_room . '%');
	}
	if (exists($self->{parent}->{game_room_crumbs}->{$_room})) {  
		$self->{room} = $_room;
		$self->sendRoom('%xt%ap%-1%' . $self->buildClientString . '%');
		return $self->sendData('%xt%jg%-1%' . $_room . '%');
	} elsif (exists($self->{parent}->{room_crumbs}->{$_room}) || $_room > 1000) {
		$self->{room} = $_room;
		$self->{xpos} = $_xpos;
		$self->{ypos} = $_ypos;
		if ($_room <= 899 && $self->getRoomPopulation >= $self->{parent}->{room_crumbs}->{$_room}->{limit}) {
			return $self->sendError(210);
		}	  
		$self->sendData('%xt%jr%-1%'  . $_room . '%' . $self->buildRoomString);
		$self->sendRoom('%xt%ap%-1%' . $self->buildClientString . '%');	
	}
}

sub getRoomPopulation {
	my $self = shift;
	my $_count = 0;
	foreach my $_client (values %{$self->{parent}->{socket}->{clients}}) {
		if ($_client->{room} == $self->{room}) {
			$_count += 1
		}
	}
	return $_count;
}

sub buildRoomString {
	my $self = shift;
	my $_room_string = $self->buildClientString . '%';
	foreach my $_client (values %{$self->{parent}->{socket}->{clients}}) {
		if ($_client->{room} == $self->{room} && $_client->{ID} != $self->{ID}) {
			$_room_string .= $_client->buildClientString . '%';
		}
	}
	return $_room_string;
}

sub removePlayer {
	my $self = shift;
	$self->sendRoom('%xt%rp%-1%' . ($self->{ID} ? $self->{ID} : 0)  . '%');
}

1;
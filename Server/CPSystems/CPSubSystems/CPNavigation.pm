package CPNavigation;

use strict;
use warnings;

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
    return $self;
}

sub handleJoinServer {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_peng_id = $_args->{penguin_id};
	my $_lkey = $_args->{login_key};
	my $_language = $_args->{language};
	if (length($_lkey) < 64) {
		$_client->sendError(101);
		return $self->{parent}->{socket}->handleRemoveClientBySock($_client->{sock});
	}
	my $_is_login = $self->{parent}->{mysql}->verifyLoginKey($_lkey, $_peng_id);
	if (!$_is_login) {
		$_client->sendError(101);
		my $_attempts = $self->{parent}->{mysql}->getInvalidLogins($_client->{username});
		return $self->{parent}->{mysql}->updateInvalidLogins(($_attempts + 1), $_client->{username});
	}
	$_client->sendData('%xt%js%-1%0%1%' . $_client->{is_staff} . '%0%');
	$_client->sendData('%xt%lp%-1%' . $_client->buildClientString . '%' . $_client->{coins} . '%0%1440%100%' . $_client->{doj} . '%4%' . $_client->{doj} . '%%7%');
	$_client->joinRoom(100, 0, 0);
	$self->{parent}->{mysql}->updateLoginKey('', $_client->{username});
	$self->{parent}->{mysql}->updateInvalidLogins(0, $_client->{username});
}

sub handleJoinRoom {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_room = $_args->{room};
	my $_xpos = $_args->{xpos};
	my $_ypos = $_args->{ypos};
	$_client->joinRoom($_room, $_xpos, $_ypos);
}

sub handleJoinPlayer {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_room = $_args->{room};
	if ($_room < 1000) {
		$_room += 1000;
	}
	$_client->sendData('%xt%jp%-1%' . $_room . '%');
	$_client->joinRoom($_room, 0, 0);
}

sub handleGetRoomRefreshed {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	$_client->sendData('%xt%grs%-1%' . $_client->{room} . '%' . $_client->buildClientString . '%');
}

1;
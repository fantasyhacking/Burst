package CPBasic;

use strict;
use warnings;

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
    return $self;
}

sub handleSendFrame {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_frame = $_args->{frame};	
	$_client->sendRoom('%xt%sf%-1%' . $_client->{ID} . '%' . $_frame . '%');
	$_client->{frame} = $_frame;
}

sub handleSendEmote {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_emote = $_args->{emote};	
	$_client->sendRoom('%xt%se%-1%' . $_client->{ID} . '%' . $_emote . '%');
}

sub handleSendQuickMessage {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_message = $_args->{message_id};
	$_client->sendRoom('%xt%sq%-1%' . $_client->{ID} . '%' . $_message . '%');	
}

sub handleSendAction {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_action = $_args->{action};
	$_client->sendRoom('%xt%sa%-1%' . $_client->{ID} . '%' . $_action . '%');	
}

sub handleSendSafeMessage {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_message = $_args->{message_id};
	$_client->sendRoom('%xt%ss%-1%' . $_client->{ID} . '%' . $_message . '%');	
}

sub handleSendGuideMessage {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_message = $_args->{message_id};
	$_client->sendRoom('%xt%sg%-1%' . $_client->{ID} . '%' . $_message . '%');		
}

sub handleSendJoke {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_joke = $_args->{joke};
	$_client->sendRoom('%xt%sj%-1%' . $_client->{ID} . '%' . $_joke . '%');		
}

sub handleSendMascotMessage {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_message = $_args->{message_id};
	$_client->sendRoom('%xt%sma%-1%' . $_client->{ID} . '%' . $_message . '%');	
}

sub handleSendPosition {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_xpos = $_args->{xpos};
	my $_ypos = $_args->{xpos};
	$_client->sendRoom('%xt%sp%-1%' . $_client->{ID} . '%' . $_xpos . '%' . $_ypos . '%');
	$_client->{xpos} = $_xpos;
	$_client->{ypos} = $_ypos;
}

sub handleSendSnowball {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_xaxis = $_args->{xaxis};
	my $_yaxis = $_args->{yaxis};
	$_client->sendRoom('%xt%sb%-1%' . $_client->{ID} . '%' . $_xaxis . '%' . $_yaxis . '%');
}

sub handleGetLatestRevision {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	$_client->sendData('%xt%glr%-1%3555%');
}

sub handleGetPlayerDetails {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_peng_id = $_args->{penguin_id};
	my $_details = $self->{parent}->{mysql}->getPenguinInfo($_peng_id);
	my $_peng_info = join('|', (
			$_details->{ID}, 
			$_details->{username}, 1, 
			$_details->{color}, 
			$_details->{head}, 
			$_details->{face},
			$_details->{neck},
			$_details->{body},
			$_details->{hands},
			$_details->{feet},
			$_details->{pin},
			$_details->{photo}, 0, 0, 0,
			$_details->{rank} * 146
		)
	);
	$_client->sendData('%xt%gp%-1%' . ($_peng_info ? $_peng_info : '') . '%');
}

sub handleSendHeartbeat {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	$_client->sendData('%xt%h%-1%');
}

1;
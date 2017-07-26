package Parser4Burst;

use strict;
use warnings;

use Data::Types qw(:all);
use List::MoreUtils qw(any); 

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
	$self->{handlers} = {
		'z' => {
			
		},
		's' => {
			'j#js' => {
				'handler' => 'handleJoinServer',
				'args' => ['penguin_id', 'login_key', 'language'],
				'add_args' => [],
				'inject_free' => 0
			},
			'j#jr' => {
				'handler' => 'handleJoinRoom',
				'args' => ['room', 'xpos', 'ypos'],	
				'add_args' => [],
				'inject_free' => 0			
			},
			'j#jp' => {
				'handler' => 'handleJoinPlayer',
				'args' => ['room'],
				'add_args' => [],
				'inject_free' => 0			
			},
			'j#jg' => {
				'handler' => 'handleJoinGame',
				'args' => ['room'],
				'add_args' => [],
				'inject_free' => 0			
			},
			'j#grs' => {
				'handler' => 'handleGetRoomRefreshed',
				'args' => [],
				'add_args' => [],
				'inject_free' => 0
			},
			'f#epfgf' => {
				'handler' => 'handleEPFGetField',
				'args' => [],
				'add_args' => [],
				'inject_free' => 0			
			},
			's#upc' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0
			},
			's#uph' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0	
			},
			's#upf' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0					
			},
			's#upn' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0	
			},
			's#upb' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0			
			},
			's#upa' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0				
			},
			's#upe' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0				
			},
			's#upp' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0	
			},
			's#upl' => {
				'handler' => 'handleUpdatePlayerSettings',
				'args' => ['item'],
				'add_args' => [],
				'inject_free' => 0		
			},
			'u#sf' => {
				'handler' => 'handleSendFrame',
				'args' => ['frame'],
				'add_args' => [],
				'inject_free' => 0	
			},
			'u#se' => {
				'handler' => 'handleSendEmote',
				'args' => ['emote'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sq' => {
				'handler' => 'handleSendQuickMessage',
				'args' => ['message_id'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sa' => {
				'handler' => 'handleSendAction',
				'args' => ['action'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#ss' => {
				'handler' => 'handleSendSafeMessage',
				'args' => ['message_id'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sg' => {
				'handler' => 'handleSendGuideMessage',
				'args' => ['message_id'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sj' => {
				'handler' => 'handleSendJoke',
				'args' => ['joke'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sma' => {
				'handler' => 'handleSendMascotMessage',
				'args' => ['message_id'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sp' => {
				'handler' => 'handleSendPosition',
				'args' => ['xpos', 'ypos'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#sb' => {
				'handler' => 'handleSendSnowball',
				'args' => ['xaxis', 'yaxis'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#glr' => {
				'handler' => 'handleGetLatestRevision',
				'args' => [],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#gp' => {
				'handler' => 'handleGetPlayerDetails',
				'args' => ['penguin_id'],
				'add_args' => [],
				'inject_free' => 0					
			},
			'u#h' => {
				'handler' => 'handleSendHeartbeat',
				'args' => [],
				'add_args' => [],
				'inject_free' => 0					
			}		
		}
	};
    return $self;
}

sub parseXT {
	my $self = shift;
	my $_data = shift;
	if (is_string($_data)) {
		my @_parts = split('%', $_data);
		if (scalar(@_parts) < 3) {
			$self->{parent}->{logger}->displayMessage('Malformed packet is being sent', 'wrn', 1, 0);
			return 0;
		}
		if (!exists($self->{handlers}->{$_parts[2]})) {
			$self->{parent}->{logger}->displayMessage('Non-existent packet type is being sent', 'wrn', 1, 0);
			return 0;
		}
		my $_inner_hash = $self->{handlers}->{$_parts[2]};
		if (!exists($_inner_hash->{$_parts[3]})) {
			$self->{parent}->{logger}->displayMessage('Invalid packet is being sent', 'wrn', 1, 0);
			return 0;		
		}
		if (any {$_ eq '|'} @_parts && !$self->{handlers}->{$_parts[2]}->{$_parts[3]}->{inject_free}) {
			$self->{parent}->{logger}->displayMessage('Packet injection has been detected', 'wrn', 1, 0);
			return 0;			
		}
		my @_pack_args = @_parts[5..$#_parts];
		my $_count = scalar(keys @{$self->{handlers}->{$_parts[2]}->{$_parts[3]}->{args}});
		if (scalar(@_pack_args) < $_count) {
			$self->{parent}->{logger}->displayMessage('Invalid number of arguments in packet', 'wrn', 1, 0);
			return 0;	
		}
		my %_fixed_parts;
		foreach my $_value (@_pack_args) {
			if (index($_value, '|') != -1) {
				my @_parted = split('|', $_value);
				foreach my $_part_val (keys @_parted) {
					my $_key_name = $self->{handlers}->{$_parts[2]}->{$_parts[3]}->{add_args}->[$_part_val];
					my $_real_key_type = $self->checkReturnDataType($_parted[$_part_val]);
					$_fixed_parts{$_key_name} = $_real_key_type;
				}
			}
		}
		my %_real_parts;
		foreach my $_part_val (keys @_pack_args) {
			my $_key_name = $self->{handlers}->{$_parts[2]}->{$_parts[3]}->{args}->[$_part_val];
			my $_real_key_type = $self->checkReturnDataType($_pack_args[$_part_val]);
			$_real_parts{$_key_name} = $_real_key_type;
		}
		my $_handling_info = {'handler' => $self->{handlers}->{$_parts[2]}->{$_parts[3]}->{handler}, 'data' => \%_real_parts, 'add_data' => \%_fixed_parts};
		return $_handling_info;
	}
}

sub checkReturnDataType {
	my $self = shift;
	my $_data = shift;
	my $_real_data = '';
	if (is_string($_data)) {
		$_real_data = to_string($_data);
	} elsif (is_int($_data)) {
		$_real_data = to_int($_data);
	} else {
		$self->{parent}->{logger}->displayMessage('Invalid packet argument type is being sent', 'wrn', 1, 0);
		return 0;
	}
	return $_real_data;
}

1;
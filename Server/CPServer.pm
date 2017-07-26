package CPServer;

use strict;
use warnings;

use POE qw(Component::Server::TCP);

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
	$self->{clients} = {};
    return $self;
}

sub runServer {
	my $self = shift;
    POE::Component::Server::TCP->new(
		Port => $self->{parent}->{config}->{server}->{port},
        Started => sub {
            $self->{parent}->{logger}->displayMessage('Successfully connected to the game server', 'inf', 0, 0);
        },
        ClientConnected => sub {
			my ($_sock, $_data, $kernel) = @_[HEAP, ARG0, KERNEL]; 
			my $_sock_id = $_[SESSION]->ID;
			our $_client = CPUser->new($self->{parent}, $_sock);
			$self->{clients}->{$_sock_id} = $_client;
			$self->{parent}->{logger}->displayMessage('Incoming client connection: ' . $_sock->{remote_ip}, 'ntc', 1, 0);
        },
        ClientDisconnected => sub {
			my ($_sock, $_data, $kernel) = @_[HEAP, ARG0, KERNEL];
			$self->handleRemoveClientBySock($_sock);
        },
        ClientInput => sub {
			my ($_sock, $_data, $_sock_id) = @_[HEAP, ARG0, ARG1];
			my $_client = $self->handleGetClientBySockID($_sock_id);
			eval {
				$self->handleIncomingData($_data, $_client);
			};
			if ($@) {
				$self->{parent}->{logger}->displayMessage("Caught fatal error: $@", 'err', 1, 0);
			}
		},
		ClientFilter => "POE::Filter::Stream",
		ClientError => sub {
			$self->{parent}->{logger}->displayMessage('Client has probably disconnected from the server', 'err', 1, 0);
		},
		Stopped => sub {
            $self->{parent}->{logger}->displayMessage('Game server has gone offline', 'inf', 0, 0);
        }
    );
    POE::Kernel->run();
}

sub handleIncomingData {
	my $self = shift;
	my ($_data, $_client) = @_;
	my @_packets = split(chr(0), $_data);
	foreach my $_packet (@_packets) { 
		$self->{parent}->{logger}->displayMessage('Incoming data: ' . $_packet, 'dbg', 1, 0);
		my $_pack_type = substr($_packet, 0, 1);
		my $_possible_xml = $_pack_type eq '<' ? 1 : 0;
		my $_possible_xt = $_pack_type eq '%' ? 1 : 0;
		if (!$_possible_xml && !$_possible_xt) {
			return $self->{parent}->{logger}->displayMessage('Malformed data is being sent', 'wrn', 1, 0);
		}
		$_possible_xml ? $self->{parent}->{loginsys}->handleXMLData($_packet, $_client) : $self->{parent}->{gamesys}->handleXTData($_packet, $_client);
	}
}

sub handleGetClientBySockID {
	my $self = shift;
	my $_sock_id = shift;
	my $_client = $self->{clients}->{$_sock_id};
	return $_client;
}

sub handleRemoveClientBySock {
	my $self = shift;
	my $_socket = shift;
	while (my ($_sock_id, $_client) = each(%{$self->{clients}})) {
		if ($_client->{sock} == $_socket) {
			delete($self->{clients}->{$_sock_id});
			$self->{parent}->{logger}->displayMessage('Client has been disconnected from the server', 'ntc', 1, 0);
		}
	}
}

1;
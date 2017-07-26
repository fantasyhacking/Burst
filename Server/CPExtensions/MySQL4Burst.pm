package MySQL4Burst;

use strict;
use warnings;

use Mojo::mysql;
use DBI;
use Passwords;

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
    return $self;
}

sub connectMySQL {
	my $self = shift;
	my $_dbhost = $self->{parent}->{config}->{mysql}->{host};
	my $_dbuser = $self->{parent}->{config}->{mysql}->{username};
	my $_dbpass = $self->{parent}->{config}->{mysql}->{password};
	my $_db = $self->{parent}->{config}->{mysql}->{database};
	my $dbh = DBI->connect("DBI:mysql:database=$_db:host=$_dbhost", $_dbuser, $_dbpass);
	if (!$dbh) {
		$self->{parent}->{logger}->displayMessage('Failed to connect to the MySQL server', 'err', 1, 1);
		exit;
	} else {
		my $connection = Mojo::mysql->new('mysql://' . $_dbuser . ':' . $_dbpass . '@' . $_dbhost . '/' . $_db);
		$self->{connection} = $connection;
		$self->{parent}->{logger}->displayMessage('Successfully connected to the MySQL server', 'inf', 0, 0);
	}
}

sub verifyUsername {
	my $self = shift;
	my $_username = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	if ($_username !~ /^\w+$/){
		return 0;
	}
	my $_results = $self->{connection}->db->query("select `username` from $_table where username = ?", $_username);
	while (my $_data = $_results->hash) {
		if (uc($_username) eq uc($_data->{username})) {
			return 1;
		} else {
			return 0;
		} 
	}
}

sub getPenguinPassword {
	my $self = shift;
	my $_username = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select `password` from $_table where username = ?", $_username);
	while (my $_data = $_results->hash) {
		return $_data->{password};
	}
}

sub getPenguinLoginKey {
	my $self = shift;
	my $_username = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select `lkey` from $_table where username = ?", $_username);
	while (my $_data = $_results->hash) {
		return $_data->{lkey};
	}
}

sub getPenguinID {
	my $self = shift;
	my $_username = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select `ID` from $_table where username = ?", $_username);
	while (my $_data = $_results->hash) {
		return $_data->{ID};
	}
}

sub updateLoginKey {
	my $self = shift;
	my ($_key, $_username) = @_;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	$self->{connection}->db->query("update $_table set lkey = ? where username = ?", $_key, $_username);
}

sub updatePlayerSettings {
	my $self = shift;
	my ($_type, $_item, $_username) = @_;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	$self->{connection}->db->query("update $_table set $_type = ? where username = ?", $_item, $_username);
}

sub getInvalidLogins {
	my $self = shift;
	my $_username = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select `invalid_logins` from $_table where username = ?", $_username);
	while (my $_data = $_results->hash) {
		my $_attempts = $_data->{invalid_logins};
		return $_attempts;
	}
}

sub updateInvalidLogins {
	my $self = shift;
	my ($_count, $_username) = @_;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	$self->{connection}->db->query("update $_table set invalid_logins = ? where username = ?", $_count, $_username);
}

sub getBannedStatus {
	my $self = shift;
	my $_username = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select `is_banned` from $_table where username = ?", $_username);
	while (my $_data = $_results->hash) {
		my $_status = $_data->{is_banned};
		return $_status;
	}
}

sub getPenguinInfo {
	my $self = shift;
	my $_userID = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select * from $_table where ID = ?", $_userID);
	while (my $_info = $_results->hash) {
		return $_info;
	}
}

sub getIglooInfo {
	my $self = shift;
	my $_userID = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{home};
	my $_results = $self->{connection}->db->query("select * from $_table where ID = ?", $_userID);
	while (my $_info = $_results->hash) {
		return $_info;
	}
}

sub getEPFInfo {
	my $self = shift;
	my $_userID = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{epf};
	my $_results = $self->{connection}->db->query("select * from $_table where ID = ?", $_userID);
	while (my $_info = $_results->hash) {
		return $_info;
	}	
}

sub getStampsInfo {
	my $self = shift;
	my $_userID = shift;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{stamps};
	my $_results = $self->{connection}->db->query("select * from $_table where ID = ?", $_userID);
	while (my $_info = $_results->hash) {
		return $_info;
	}	
}

sub verifyLoginKey {
	my $self = shift;
	my ($_lkey, $_peng_id) = @_;
	my $_table = $self->{parent}->{config}->{mysql}->{tables}->{users};
	my $_results = $self->{connection}->db->query("select `lkey` from $_table where ID = ?", $_peng_id);
	while (my $_data = $_results->hash) {
		my $_db_lkey = $_data->{lkey};
		return password_verify($_lkey, $_db_lkey) ? 1 : 0;
	}
}

1;
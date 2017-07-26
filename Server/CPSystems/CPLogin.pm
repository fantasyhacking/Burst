package CPLogin;

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use Passwords;
use Digest::SHA qw(sha256_hex);

sub new {
	my $self = bless {}, shift;
	$self->{child} = shift;
	$self->{xml_handlers} = {
		verChk => 'handleVersionCheck',                      			                    
		login => 'handleGameLogin'
	};
    return $self;
}

sub handleXMLData {
	my $self = shift;
	my $_data = shift;
	my $_client = shift;
	if ($_data eq '<policy-file-request/>') {
		return $_client->sendData("<cross-domain-policy><allow-access-from domain='*' to-ports='" . $self->{child}->{config}->{server}->{port} . "'/></cross-domain-policy>");
	}
	my $_xml = $self->{child}->parseXML($_data);
	if (!$_xml) {
		return $self->{child}->{socket}->handleRemoveClientBySock($_client->{sock});
	}
	if ($_xml->{t} eq 'sys') {
		my $_action = $_xml->{body}->{action};
		return if (!exists($self->{xml_handlers}->{$_action}));
		my $strHandler = $self->{xml_handlers}->{$_action};
		if ($self->can($strHandler)) {
			$self->$strHandler($_xml, $_client);
		}
	}
}

sub handleVersionCheck {
	my $self = shift;
	my $_data = shift;
	my $_client = shift;
	return $_data->{body}->{ver}->{v} == 153 ? $_client->sendData("<msg t='sys'><body action='apiOK' r='0'></body></msg>") : $_client->sendData("<msg t='sys'><body action='apiKO' r='0'></body></msg>");
}

sub handleGameLogin {
	my $self = shift;
	my $_data = shift;
	my $_client = shift;
	my $_username = $_data->{body}->{login}->{nick};
	my $_password = $_data->{body}->{login}->{pword};
	if ($_username !~ /^\w+$/) {
		return $_client->sendError(100);
	}
	if (length($_password) < 64) {
		$_client->sendError(101);
		return $self->{child}->{sock}->handleRemoveClient($_client);
	}
	my $_username_exist = $self->{child}->{mysql}->verifyUsername($_username);
	if (!$_username_exist) {
		return $_client->sendError(100);
	}
	my $_password_correct = $self->verifyPassword($_username, $_password);
	if (!$_password_correct) {
		$_client->sendError(101);
		my $_attempts = $self->{child}->{mysql}->getInvalidLogins($_username);
		return $self->{child}->{mysql}->updateInvalidLogins(($_attempts + 1), $_username);
	}
	my $_attempts = $self->{child}->{mysql}->getInvalidLogins($_username);
	if ($_attempts >= 5) {
		return $_client->sendError(150);
	}
	my $_banned_status = $self->{child}->{mysql}->getBannedStatus($_username);
	if ($_banned_status eq 'PERMANENT') {
		return $_client->sendError(603);	              
	} elsif (looks_like_number($_banned_status)) {
		if ($_banned_status > time) {
			my $_time = $self->{child}->{crypt}->getTimeDifference($_banned_status, time, 3600);
			return $_client->sendError(601 . '%' . $_time);	
		}              
	}
	my $_rand_key = sha256_hex($self->{child}->{crypt}->generateKey(12));
	my $_encrypted_key = password_hash($_rand_key, PASSWORD_DEFAULT, ('cost' => 12, 'salt' => $self->{child}->{crypt}->generateKey(16)));
	$self->{child}->{mysql}->updateLoginKey($_encrypted_key, $_username);
	$_client->sendData('%xt%l%-1%' . $self->{child}->{mysql}->getPenguinID($_username) . '%' . $_rand_key . '%');
	$_client->{ID} = $self->{child}->{mysql}->getPenguinID($_username);
	$_client->loadInformation;
}

sub verifyPassword {
	my $self = shift;
	my $_username = shift;
	my $_password = shift;
	my $_dbpass = $self->{child}->{mysql}->getPenguinPassword($_username);  
	my $verify = password_verify(uc($_password), $_dbpass);
	return $verify == 1 ? 1 : 0;
}

1;
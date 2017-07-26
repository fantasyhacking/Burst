package Log4Burst;

use strict;
use warnings;

use feature qw(say);
use POSIX qw(strftime);
use Term::ANSIColor;
use if $^O eq 'MSWin32', "Win32::Console::ANSI";

sub new {
	my $self = bless {}, shift;
	$self->{types} = {
		err => 'error',
		inf => 'info',
		wrn => 'warn',
		dbg => 'debug',
		ntc => 'notice'
	};
	$self->{colors} = {
		err => 'bold yellow',
		inf => 'bold cyan',
		wrn => 'bold red',
		dbg => 'bold green',
		ntc => 'bold blue'
	};
    return $self;
}

sub logToFile {
	my $self = shift;
	my $_text = shift;
	my $_file = 'logs.log';
	open my $_filehandle, '>>', $_file;
	say $_filehandle $_text;
	close $_filehandle;
}

sub displayMessage {
	my $self = shift;
	my ($_message, $_type, $_write, $_kill) = @_;
	my $_time = strftime('%I:%M:%S[%p]', localtime());
	if ($_message ne '') {
		my $_log = '[' . $_time . '][' . uc($self->{types}->{$_type}) . ']: ' . $_message;
		say colored($_log, $self->{colors}->{$_type});
		if ($_write) {
			$self->logToFile($_log);
		}
		if ($_kill) {
			exit;
		}
	}
}

1;
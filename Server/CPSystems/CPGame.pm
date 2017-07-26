package CPGame;

use strict;
use warnings;

sub new {
	my $self = bless {}, shift;
	$self->{child} = shift;
	$self->{sub_sys} = {
		navigation => CPNavigation->new($self->{child}),
		epf => CPEPF->new($self->{child}),
		settings => CPSettings->new($self->{child}),
		basic => CPBasic->new($self->{child})
	};
    return $self;
}

sub handleXTData {
	my $self = shift;
	my ($_data, $_client) = @_;
	my $_info = $self->{child}->{parser}->parseXT($_data);
	return if (!$_info);
	my $_handler = $_info->{handler};
	my $_parsed_data = $_info->{data};
	my $_parsed_add_data = $_info->{add_data};
	foreach my $_sys (values %{$self->{sub_sys}}) {
		if ($_sys->can($_handler)) {
			$_sys->$_handler($_client, $_parsed_data, $_parsed_add_data);
		} 
	}
}

1;
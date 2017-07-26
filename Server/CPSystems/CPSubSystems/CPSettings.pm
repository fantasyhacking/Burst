package CPSettings;

use strict;
use warnings;

use List::MoreUtils qw(any);

sub new {
	my $self = bless {}, shift;
	$self->{parent} = shift;
	$self->{pack_types} = {
		color => 'upc',
		head => 'uph',
		neck => 'upn',
		body => 'upb',
		hand => 'upa',
		feet => 'upe',
		photo => 'upp',
		pin => 'upl',
		award => 'upl'
	};
    return $self;
}

sub handleUpdatePlayerSettings {
	my $self = shift;
	my ($_client, $_args, $_add_args) = @_;
	my $_item = $_args->{item};
	if (!exists($self->{parent}->{item_crumbs}->{$_item})) {
		return $_client->sendError(402);
	} elsif (!any {$_ == $_item} @{$_client->{inventory}}) {
		return $_client->sendError(402);
	}
	my $_item_type = lc($self->{parent}->{item_crumbs}->{$_item}->{type});
	my $_pack_type = $self->{pack_types}->{$_item_type};
	$_client->sendRoom('%xt%' . $_pack_type . '%-1%' . $_client->{ID} . '%' . $_item . '%');
	$self->{parent}->{mysql}->updatePlayerSettings($_item_type, $_item, $_client->{username});
	$_client->{$_item_type} = $_item;
}

1;
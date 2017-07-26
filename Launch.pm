use Module::Find;

use Server::CPExtensions::Log4Burst;
use Server::CPExtensions::Parser4Burst;
use Server::CPExtensions::Crypt4Burst;
use Server::CPExtensions::MySQL4Burst;

usesub Server::CPCrumbs;
usesub Server::CPSystems::CPSubSystems;

use Server::CPSystems::CPLogin;
use Server::CPSystems::CPGame;

use Server::CPServer;

use Server::CPMain;
use Server::CPUser;

my $_server = CPMain->new;

$_server->{socket}->runServer;

1;
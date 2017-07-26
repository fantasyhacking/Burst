-- Adminer 4.3.1 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP DATABASE IF EXISTS `burst`;
CREATE DATABASE `burst` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `burst`;

DROP TABLE IF EXISTS `agents`;
CREATE TABLE `agents` (
  `ID` int(11) NOT NULL,
  `is_agent` tinyint(1) NOT NULL DEFAULT '1',
  `agent_status` mediumtext NOT NULL,
  `epf_current_points` int(10) NOT NULL DEFAULT '20',
  `epf_total_points` int(10) NOT NULL DEFAULT '100',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `igloos`;
CREATE TABLE `igloos` (
  `ID` int(11) NOT NULL,
  `username` mediumtext NOT NULL,
  `igloo` mediumint(3) NOT NULL,
  `music` mediumint(3) NOT NULL,
  `floor` mediumint(3) NOT NULL,
  `furniture` longtext NOT NULL,
  `owned_igloos` longtext NOT NULL,
  `owned_furnitures` longtext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `penguins`;
CREATE TABLE `penguins` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `username` mediumtext NOT NULL,
  `nickname` mediumtext NOT NULL,
  `password` varchar(255) NOT NULL,
  `color` smallint(2) NOT NULL DEFAULT '1',
  `head` mediumint(6) NOT NULL DEFAULT '0',
  `face` mediumint(6) NOT NULL DEFAULT '0',
  `neck` mediumint(6) NOT NULL DEFAULT '0',
  `body` mediumint(6) NOT NULL DEFAULT '0',
  `hands` mediumint(6) NOT NULL DEFAULT '0',
  `feet` mediumint(6) NOT NULL DEFAULT '0',
  `pin` mediumint(6) NOT NULL DEFAULT '0',
  `photo` mediumint(6) NOT NULL DEFAULT '0',
  `doj` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `coins` int(11) NOT NULL DEFAULT '500',
  `rank` mediumint(2) NOT NULL DEFAULT '1',
  `is_staff` tinyint(1) NOT NULL DEFAULT '0',
  `lkey` varchar(255) NOT NULL,
  `is_banned` varchar(100) NOT NULL,
  `invalid_logins` smallint(2) NOT NULL DEFAULT '0',
  `buddies` longtext NOT NULL,
  `ignored` longtext NOT NULL,
  `inventory` longtext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

INSERT INTO `penguins` (`ID`, `username`, `nickname`, `password`, `color`, `head`, `face`, `neck`, `body`, `hands`, `feet`, `pin`, `photo`, `doj`, `coins`, `rank`, `is_staff`, `lkey`, `is_banned`, `invalid_logins`, `buddies`, `ignored`, `inventory`) VALUES
(1,	'Lynx',	'Lynx',	'$2y$12$X0v2WRHKUiPdRynHbC6yau9zHMYtIkLjlsrA.h.NwNs13Zko0GreC',	4,	0,	0,	0,	0,	0,	0,	0,	0,	'2017-07-01 08:29:42',	5000,	6,	1,	'',	'0',	0,	'',	'',	'');

DROP TABLE IF EXISTS `postcards`;
CREATE TABLE `postcards` (
  `postcard_id` int(11) NOT NULL AUTO_INCREMENT,
  `recepient` int(11) NOT NULL,
  `mailer_name` mediumtext NOT NULL,
  `mailer_id` int(11) NOT NULL,
  `notes` mediumtext NOT NULL,
  `timestamp` int(8) NOT NULL,
  `postcard_type` mediumint(5) NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`postcard_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `puffles`;
CREATE TABLE `puffles` (
  `puffle_id` int(11) NOT NULL AUTO_INCREMENT,
  `owner_id` int(11) NOT NULL,
  `puffle_name` mediumtext NOT NULL,
  `puffle_type` tinyint(2) NOT NULL,
  `puffle_energy` mediumint(3) NOT NULL DEFAULT '100',
  `puffle_health` mediumint(3) NOT NULL DEFAULT '100',
  `puffle_rest` mediumint(3) NOT NULL DEFAULT '100',
  `puffle_walking` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`puffle_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `stickers`;
CREATE TABLE `stickers` (
  `ID` int(11) NOT NULL,
  `stamps` longtext NOT NULL,
  `cover` longtext NOT NULL,
  `restamps` longtext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- 2017-07-26 01:35:38

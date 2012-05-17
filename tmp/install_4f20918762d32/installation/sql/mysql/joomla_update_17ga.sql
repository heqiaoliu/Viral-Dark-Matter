# $Id: joomla_update_17ga.sql 22040 2011-09-07 16:06:39Z dextercowley $

#
# Database updates for 1.6.5 to 1.7 GA
#

CREATE TABLE IF NOT EXISTS `#__associations` (
  `id` VARCHAR(50) NOT NULL COMMENT 'A reference to the associated item.',
  `context` VARCHAR(50) NOT NULL COMMENT 'The context of the associated item.',
  `key` CHAR(32) NOT NULL COMMENT 'The key for the association computed from an md5 on associated ids.',
  PRIMARY KEY `idx_context_id` (`context`, `id`),
  INDEX `idx_key` (`key`)
) DEFAULT CHARSET=utf8;

ALTER TABLE `#__languages` ADD COLUMN `ordering` int(11) NOT NULL default 0 AFTER `published`;
ALTER TABLE `#__languages` ADD INDEX `idx_ordering` (`ordering`);



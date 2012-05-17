	CREATE TABLE IF NOT EXISTS `#__jdownloads_config` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `setting_name` varchar(64) NOT NULL default '',
	  `setting_value` text NOT NULL,
	  PRIMARY KEY  (`id`)
	) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
     
	CREATE TABLE IF NOT EXISTS `#__jdownloads_cats` (
		`cat_id` int(11) NOT NULL AUTO_INCREMENT,
		`cat_dir` text NOT NULL,
		`parent_id` int(11) NOT NULL ,
		`cat_title` VARCHAR( 255 ) NOT NULL,
		`cat_alias` VARCHAR( 255 ) NOT NULL,
		`cat_description` TEXT NOT NULL,
	  	`cat_pic` VARCHAR( 255 ) NOT NULL,
	  	`cat_access` VARCHAR( 3 ) NOT NULL default '00',
		`cat_group_access` int(11) NOT NULL default '0',
        `metakey` TEXT NOT NULL default '',
		`metadesc` TEXT NOT NULL default '',
		`jaccess` tinyint(3) NOT NULL default '0',
		`jlanguage` VARCHAR( 7 ) NOT NULL default '',
	  	`ordering` int(11) NOT NULL default '0',
	  	`published` tinyint(1) NOT NULL default '0',
	  	`checked_out` int(11) NOT NULL default '0',
	  	`checked_out_time` datetime NOT NULL default '0000-00-00 00:00:00',
       PRIMARY KEY  (`cat_id`)
    ) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
    
	CREATE TABLE IF NOT EXISTS `#__jdownloads_files` (
		  `file_id` int(11) NOT NULL AUTO_INCREMENT,
		  `file_title` varchar(255) NOT NULL default '',
		  `file_alias` varchar(255) NOT NULL default '',
		  `description` longtext NOT NULL default '',
		  `description_long` longtext NOT NULL default '',
          `file_pic` varchar(255) NOT NULL default '',
    	  `thumbnail` varchar(255) NOT NULL default '',
    	  `thumbnail2` varchar(255) NOT NULL default '',
    	  `thumbnail3` varchar(255) NOT NULL default '',		  
          `price` varchar(20) NOT NULL default '',
          `release` varchar(255) NOT NULL default '',
    	  `language` tinyint(2) NOT NULL default '0',
    	  `system` tinyint(2) NOT NULL default '0',
		  `license` varchar(255) NOT NULL default '',
		  `url_license` varchar(255) NOT NULL default '',
		  `license_agree` tinyint(1) NOT NULL default '0',
		  `size` varchar(255) NOT NULL default '',
		  `date_added` datetime NOT NULL default '0000-00-00 00:00:00',
		  `file_date` datetime NOT NULL default '0000-00-00 00:00:00',
		  `publish_from` datetime NOT NULL default '0000-00-00 00:00:00',
		  `publish_to` datetime NOT NULL default '0000-00-00 00:00:00',
          `use_timeframe` tinyint(1) NOT NULL default '0',
		  `url_download` varchar(255) NOT NULL default '',
          `extern_file` varchar(255) NOT NULL default '',
          `extern_site` tinyint(1) NOT NULL default '0',
          `mirror_1` varchar(255) NOT NULL default '',
          `mirror_2` varchar(255) NOT NULL default '',
	      `extern_site_mirror_1` tinyint(1) NOT NULL default '0',
          `extern_site_mirror_2` tinyint(1) NOT NULL default '0',
          `url_home` varchar(255) NOT NULL default '',
		  `author` varchar(255) NOT NULL default '',
		  `url_author` varchar(255) NOT NULL default '',
		  `created_by` varchar(255) NOT NULL default '',
		  `created_id` int(11) NOT NULL default '0',
		  `created_mail` varchar(255) NOT NULL default '',
		  `modified_by` varchar(255) NOT NULL default '',
		  `modified_id` int(11) NOT NULL default '0',
		  `modified_date` datetime NOT NULL default '0000-00-00 00:00:00',
		  `submitted_by` int(11) NOT NULL default '0',
		  `set_aup_points` tinyint(1) NOT NULL default '0',
		  `downloads` int(11) NOT NULL default '0',
		  `cat_id` int(11) NOT NULL default '0',
          `metakey` TEXT NOT NULL default '',
          `metadesc` TEXT NOT NULL default '',
          `update_active` tinyint(1) NOT NULL default '0',
		  `custom_field_1` tinyint(2) NOT NULL default '0',
		  `custom_field_2` tinyint(2) NOT NULL default '0',
		  `custom_field_3` tinyint(2) NOT NULL default '0',
		  `custom_field_4` tinyint(2) NOT NULL default '0',
		  `custom_field_5` tinyint(2) NOT NULL default '0',
		  `custom_field_6` varchar(255) NOT NULL default '',
		  `custom_field_7` varchar(255) NOT NULL default '',
		  `custom_field_8` varchar(255) NOT NULL default '',
		  `custom_field_9` varchar(255) NOT NULL default '',
		  `custom_field_10` varchar(255) NOT NULL default '',
		  `custom_field_11` date NOT NULL default '0000-00-00',
		  `custom_field_12` date NOT NULL default '0000-00-00',
		  `custom_field_13` TEXT NOT NULL default '',
		  `custom_field_14` TEXT NOT NULL default '',
    	  `jaccess` tinyint(3) NOT NULL default '0',
		  `jlanguage` VARCHAR( 7 ) NOT NULL default '',
		  `ordering` int(11) NOT NULL default '0',
		  `published` tinyint(1) NOT NULL default '0',
		  `checked_out` int(11) NOT NULL default '0',
		  `checked_out_time` datetime NOT NULL default '0000-00-00 00:00:00',
		  PRIMARY KEY  (`file_id`)
	) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
    
	CREATE TABLE IF NOT EXISTS `#__jdownloads_license` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `license_title` varchar(64) NOT NULL default '',
	  `license_text` longtext NOT NULL,
      `license_url` varchar(255) NOT NULL default '',
	  `jlanguage` VARCHAR( 7 ) NOT NULL default '',
      `checked_out` int(11) NOT NULL default '0',
	  `checked_out_time` datetime NOT NULL default '0000-00-00 00:00:00',
	  PRIMARY KEY  (`id`)
	) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
    
	CREATE TABLE IF NOT EXISTS `#__jdownloads_templates` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `template_name` varchar(64) NOT NULL default '',
	  `template_typ` tinyint(2) NOT NULL default '0',
	  `template_header_text` longtext NOT NULL,
	  `template_subheader_text` longtext NOT NULL,
	  `template_footer_text` longtext NOT NULL,
      `template_text` longtext NOT NULL,
	  `template_active` tinyint(1) NOT NULL default '0',
	  `locked` tinyint(1) NOT NULL default '0',
      `note` tinytext NOT NULL,
	  `cols` tinyint(1) NOT NULL default '1',
      `checkbox_off` tinyint(1) NOT NULL default '0',
      `symbol_off` tinyint(1) NOT NULL default '0',
	  `jlanguage` VARCHAR( 7 ) NOT NULL default '',
      `checked_out` int(11) NOT NULL default '0',
	  `checked_out_time` datetime NOT NULL default '0000-00-00 00:00:00',
	  PRIMARY KEY  (`id`)
	) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
	
	CREATE TABLE IF NOT EXISTS `#__jdownloads_groups` (
		`id` int(11) NOT NULL auto_increment,
		`groups_name` text NOT NULL,
		`groups_description` longtext,
		`groups_access` tinyint(4) NOT NULL default '1',
		`groups_members` text,
		`jlanguage` VARCHAR( 7 ) NOT NULL default '',
		PRIMARY KEY  (`id`)
	) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
	
	CREATE TABLE IF NOT EXISTS `#__jdownloads_log` (
		`id` int(11) NOT NULL auto_increment,
		`type` tinyint(1) NOT NULL default '1',
		`log_file_id` int(11) NOT NULL,
		`log_ip` varchar(25) NOT NULL default '',
		`log_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
		`log_user` int(11) NOT NULL default '0',
		`log_browser` varchar(255) NOT NULL default '',
		`jlanguage` VARCHAR( 7 ) NOT NULL default '',
		PRIMARY KEY  (`id`)
        ) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;

    CREATE TABLE IF NOT EXISTS `#__jdownloads_rating` (
        `file_id` int(11) NOT NULL default '0',
        `rating_sum` int(11) unsigned NOT NULL default '0',
        `rating_count` int(11) unsigned NOT NULL default '0',
        `lastip` varchar(50) NOT NULL default '',
		`jlanguage` VARCHAR( 7 ) NOT NULL default '',
        PRIMARY KEY  (`file_id`)
        ) ENGINE=MyISAM CHARACTER SET `utf8` COLLATE `utf8_general_ci`;
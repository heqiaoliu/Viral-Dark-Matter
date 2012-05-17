<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager Client Library
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license - PHP files are GNU/GPL V2. CSS / JS are Copyrighted Commercial,
# bound by Proprietary License of JoomlArt. For details on licensing, 
# Please Read Terms of Use at http://www.joomlart.com/terms_of_use.html.
# Author: JoomlArt.com
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# Redistribution, Modification or Re-licensing of this file in part of full, 
# is bound by the License applied. 
# ------------------------------------------------------------------------
*/ 

defined("DS") or define("DS", DIRECTORY_SEPARATOR);
define("_JAUPDATER_ROOT", realpath(dirname(__FILE__)));

// disable all notice and warning for product release
//error_reporting(E_ALL & ~E_STRICT & ~E_NOTICE);

// debug
//ini_set("xdebug.var_display_max_children", 500);
//ini_set("xdebug.var_display_max_depth", 100);
// -/-

require_once("core".DS."XmlParser.php");
require_once("core".DS."helper".DS."VPackageHelper.php");

VPackageHelper::importRecursive(_JAUPDATER_ROOT.DS."..".DS."xlib");

VPackageHelper::importAll(_JAUPDATER_ROOT.DS."core");
VPackageHelper::importAll(_JAUPDATER_ROOT.DS."core".DS."php5");
VPackageHelper::import("core.bean.InfoObject");
VPackageHelper::import("core.bean.Message");
VPackageHelper::import("core.bean.Products");//2010-01-20
VPackageHelper::importAll(_JAUPDATER_ROOT.DS."core".DS."checksum");
VPackageHelper::importAll(_JAUPDATER_ROOT.DS."core".DS."helper");

<?php
/**
 * ------------------------------------------------------------------------
 * JA Typo plugin
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */
defined('_JEXEC') or die('Restricted access');

	$base_url = JURI::base();
	global $mainframe;		
	if($mainframe->isAdmin()) {
		$base_url = dirname ($base_url);
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="<?php echo $base_url;?>/plugins/system/jatypo/assets/style.css" type="text/css" />
<link rel="stylesheet" href="<?php echo $base_url;?>/plugins/system/jatypo/typo/typo.css" type="text/css" />
<script type="text/javascript" src="<?php echo $base_url;?>/media/system/js/mootools.js"></script>
<script type="text/javascript" src="<?php echo $base_url;?>/plugins/system/jatypo/assets/script.js"></script>

<title>Untitled Document</title>
</head>
<body>
<?php
	$file = dirname(dirname (__FILE__)).DS.'typo'.DS.'index.html';
	$html = file_get_contents ($file);
	if (preg_match ('/<body[^>]*>(.*)<\/body>/s', $html, $matches)) $html = $matches[1];
	//add typo css
	$typocss = $base_url.'/plugins/system/jatypo/typo/typo.css';
	
?>

<div id="jatypo-wrap">
<?php echo $html?>
</div>	
<script type="text/javascript">
window.addEvent ('load', function () {
	new JATypo();
});
window.parent.LoadJSEditor();
</script>
</body>
</html>

<?php
/*
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */
class T3AjaxSite {
	function gzip () {
		$file = JRequest::getVar ('jat3file');
		//clean filepath
		$file = preg_replace ('#[?\#]+.*$#', '', $file);
		//check exists
		$filepath = T3Path::path (dirname($file)).DS.basename($file);
		if (!is_file ($filepath)) {echo "File $file $filepath not exist";return;}
		$type = strtolower(JRequest::getCmd ('jat3type', 'css'));
		//$type must be in css or js
		if (!in_array($type, array('css', 'js'))) {echo "Type $type not support";return;}
		//make sure the type of $file is the same with $type
		if (!preg_match('#\.'.$type.'$#', $filepath)) {echo "Type $type not match";return;}
		
		jimport ('joomla.filesystem.file');
		$data = @JFile::read ($filepath);
		if (!$data) {echo "File $filepath empty";return;}
		
		if ($type == 'js') $type = 'javascript';
		JResponse::setHeader( 'Content-Type', "text/$type;", true );
		//set cache time
		JResponse::setHeader( 'Cache-Control', "private", true );
   		$offset = 365 * 24 * 60 * 60; //whenever the content is changed, the file name is changed also. Therefore we could set the cache time long.
   		JResponse::setHeader( 'Expires', gmdate ("D, d M Y H:i:s", time() + $offset) . " GMT", true );
		JResponse::allowCache(true);
		JResponse::setBody ($data);
		echo JResponse::toString(1);
	}
}
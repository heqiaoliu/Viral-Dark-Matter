<?php
/**
 * ------------------------------------------------------------------------
 * JA Extensions Manager
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */
// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' );
 
/**
 * Message Object use for communication between service and client
 *
 */
class Message
{
	
	var $from = null;
	var $to = null;
	var $content = null;


	/**
	 * @param $content
	 * @param $from
	 * @param $to
	 */
	function Message($content, $from, $to)
	{
		if (is_array($content)) {
			$this->content = $content;
		} else {
			$this->content[] = $content;
		}
		$this->from = $from;
		$this->to = $to;
	}
}
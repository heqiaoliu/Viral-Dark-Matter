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
 * The class implement CheckSums Interface provide MD5 method to checksums
 *
 */
class CheckSumsMD5 extends CheckSums
{


	/**
	 * @seealso CheckSums::getCheckSum
	 */
	function getCheckSum($file)
	{
		return md5_file($file);
	}
}
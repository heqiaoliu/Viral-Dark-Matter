<?php
/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

//no direct access
defined( '_JEXEC' ) or die( 'Retricted Access' );

?>
<div id="jacom-mainwrap">
<div id="jacom-mainnav">
  <div class="inner">
    <div class="ja-showhide"> <a class="openall opened" title="Open all" onclick="JATreeMenu.openall();" href="javascript:;" id="menu_open"><?php echo JText::_("OPEN_ALL");?></a> <a class="closeall" title="Close all" onclick="JATreeMenu.closeall();" href="javascript:;" id="menu_close"><?php echo JText::_("CLOSE_ALL");?></a> </div>
    <?php JAMenu::_menu();?>
    <script type="text/javascript">
		JATreeMenu.initmenu();
	</script>
  </div>
</div>
<div id="jacom-maincontent">

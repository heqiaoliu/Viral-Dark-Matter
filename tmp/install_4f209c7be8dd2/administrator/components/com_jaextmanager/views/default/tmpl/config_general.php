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

//no direct access
defined( '_JEXEC' ) or die( 'Retricted Access' );
?>
<fieldset>
  <legend><?php echo JText::_("GENERAL_CONFIG");?></legend>
  
  <?php defined('_JEXEC') or die('Restricted access'); ?>
<script type="text/javascript" language="javascript">
//<![CDATA[
function submitbutton(pressbutton) {
	var form = document.adminForm;

	if (pressbutton == 'cancel') {
		submitform( pressbutton );
		return;
	}
	if ( pressbutton == 'save' || pressbutton == 'apply' ){
		submitform( pressbutton );
	}					
	else {
		submitform( pressbutton );
	}
}

//]]>
</script>
<form action="index.php" method="post" name="adminForm" id="adminForm">
<div class="col100">
		<table class="admintable">
		<tr>
			<td width="100" align="right" class="key">
				<label for="title">
					<?php echo JText::_('AUTO_CHECK_UPDATE' ); ?><font color="Red">*</font>:
				</label>
			</td>
			<td>
				<input type="radio" name="params[autocheck]" value="1" id="autocheck1" <?php if( $this->params->get("autocheck") == "1" ) echo 'checked="checked"'; ?>  /> <label for="autocheck1">Yes</label> 
				<input type="radio" name="params[autocheck]" value="0" id="autocheck0" <?php if( $this->params->get("autocheck") == "0" ) echo 'checked="checked"'; ?> /> <label for="autocheck0">No</label>
			</td>
		</tr>
	</table>
</div>
<div class="clr"></div>

<input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
<input type="hidden" name="task" value="" />
<input type="hidden" name="layout" value="config_general" />
<input type="hidden" name="view" value="default" />
</form>
  
</fieldset>
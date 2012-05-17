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
<script type="text/javascript" language="javascript">
//<![CDATA[
Joomla.submitbutton = function(pressbutton) {
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

<fieldset>
<legend><?php echo JText::_("GENERAL_SETTINGS");?></legend>
<form action="index.php" method="post" name="adminForm" id="adminForm">
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="task" value="" />
  <input type="hidden" name="layout" value="config_service" />
  <input type="hidden" name="view" value="default" />
    <table class="admintable">
      <tr>
        <td class="key" align="right"><label for="title"> <?php echo JText::_('LOCAL_REPOSITORY_PATH' ); ?>: </label>
        </td>
        <td><input type="text" value="<?php echo $this->params->get("DATA_FOLDER", "jaextmanager_data");?>" size="80" name="params[DATA_FOLDER]" />
        </td>
      </tr>
      <tr>
        <td class="key" align="right"><label for="title"> <?php echo JText::_('MYSQL_PATH' ); ?>: </label>
        </td>
        <td><input type="text" value="<?php echo $this->params->get("MYSQL_PATH", "mysql");?>" size="80" name="params[MYSQL_PATH]" />
        </td>
      </tr>
      <tr>
        <td class="key" align="right"><label for="title"> <?php echo JText::_('MYSQL_DUMP_PATH' ); ?>: </label>
        </td>
        <td><input type="text" value="<?php echo $this->params->get("MYSQLDUMP_PATH", "mysqldump");?>" size="80" name="params[MYSQLDUMP_PATH]" />
        </td>
      </tr>
    </table>
</form>
</fieldset>

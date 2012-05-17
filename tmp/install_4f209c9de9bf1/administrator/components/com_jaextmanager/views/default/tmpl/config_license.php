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
<legend><?php echo JText::_("LICENSE_INFORMATION");?></legend>
<form action="index.php" method="post" name="adminForm" id="adminForm">
  <div class="col100">
    <table class="admintable">
      <tr>
        <td class="key" align="right"><label for="title"> <?php echo JText::_('USERNAME' ); ?>: </label>
        </td>
        <td><input type="text" value="<?php echo $this->params->get("WS_USER", "");?>" size="80" name="params[WS_USER]" />
        </td>
      </tr>
      <tr>
        <td class="key" align="right"><label for="title"> <?php echo JText::_('PASSWORD' ); ?>: </label>
        </td>
        <td><input type="password" value="<?php echo $this->params->get("WS_PASS", "");?>" size="80" name="params[WS_PASS]" />
        </td>
      </tr>
    </table>
  </div>
  <div class="clr"></div>
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="task" value="" />
  <input type="hidden" name="layout" value="config_license" />
  <input type="hidden" name="view" value="default" />
</form>
</fieldset>

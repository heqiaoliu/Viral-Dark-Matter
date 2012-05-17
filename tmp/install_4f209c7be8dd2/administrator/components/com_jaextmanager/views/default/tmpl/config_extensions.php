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

$extId = $this->extension->extId;
$configId = $this->configId;
$serviceId = "params[{$configId}]";

?>
<form action="index.php" method="post" name="adminForm" id="adminForm">
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="cId[]" value="<?php echo $extId; ?>" />
  <input type="hidden" name="tmpl" value="component" />
  <input type="hidden" name="task" value="config_extensions" />
  <input type="hidden" name="layout" value="config_extensions" />
  <input type="hidden" name="view" value="default" />
  <?php echo JHTML::_( 'form.token' ); ?>
    <fieldset>
    <legend> <?php echo JText::_('SERVICES' ); ?> </legend>
    <table class="admintable">
      <tr>
        <td>
        <?php 
		foreach($this->services as $service) {
			$id = $this->params->get($configId, '');
			$checked = (($id == $service->id) || ($id == '' && $service->ws_default)) ? ' checked="checked"' : ''; 
		?>
        <input type="hidden" name="service-name-<?php echo $service->id; ?>" value="<?php echo $service->ws_name; ?>" />
        <input type="radio" <?php echo $checked; ?> class="inputbox" name="<?php echo $serviceId; ?>" id="<?php echo $serviceId . $service->id; ?>" value="<?php echo $service->id; ?>">
        <label for="<?php echo $serviceId . $service->id; ?>"><?php echo $service->ws_name; ?></label><br />
        <?php } ?>        
        </td>
      </tr>
      <tr>
        <td><a href="index.php?option=com_jaextmanager&view=services" target="_parent" title="<?php echo JText::_('MANAGE_SERVICES'); ?>"><?php echo JText::_('MANAGE_SERVICES'); ?></a></td>
      </tr>
    </table>
  </fieldset>
</form>
<?php
/*
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
*/

// no direct access
defined ( '_JEXEC' ) or die ( 'Restricted access' ); 

$services = $this->services; 
$lists = $this->lists; 
$page = $this->pageNav; 

$backLink = 'index.php?option='.JACOMPONENT.'&view=services';

$view = 'services';
$viewLink = 'index.php?tmpl=component&option='.JACOMPONENT.'&view='.$view.'&viewmenu=0&task=%s&cid[]=%d&number=%d';
$linkNew = sprintf($viewLink, 'edit', 0, 0);
?>
<script type="text/javascript">
/*<![CDATA[*/
Joomla.submitbutton = function(pressbutton) {
	var form = document.adminForm;
	if (pressbutton == 'add' || pressbutton == 'edit') {
		jaCreatePopup('<?php echo $linkNew; ?>', 400, 350, '<?php echo JText::_("NEW_REMOTE_SERVICE", true)?>');
	} else if (pressbutton == 'remove') {
		var selected = jQuery('input[name^=cid]:checked').val();
		if(jQuery('#chkDel' + selected).val() == 0) {
			alert('<?php echo JText::_('CAN_NOT_DELETE_CORE_OR_DEFAULT_SERVICE', true); ?>');
			return false;
		} else {
			form.task.value = pressbutton;
			form.submit();
		}
	} else {
		form.task.value = pressbutton;
		form.submit();
	}
}
/*]]>*/
</script>

<form action="index.php" method="post" name="adminForm">
  <?php echo JHTML::_( 'form.token' ); ?>
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="task" value="" />
  <input type="hidden" name="boxchecked" value="0" />
  <input type="hidden" name="view" value="<?php echo $view; ?>" />
  <input type="hidden" name="filter_order_Dir" value="<?php echo $lists['filter_order_Dir']; ?>" />
  <fieldset>
  <legend><?php echo JText::_('SERVICES_MANAGER'); ?></legend>
  <table class="adminlist ja-uc">
    <thead>
      <tr>
        <th width="2%" align="left"> <?php echo JText::_('NUM' ); ?> </th>
        <th width="2%">&nbsp;    </th>
        <th> <?php echo JText::_("SERVICE_NAME"); ?> </th>
        <th> <?php echo JText::_("MODE"); ?> </th>
        <th> <?php echo JText::_("SERVICE_URL"); ?> </th>
        <th> <?php echo JText::_("USERNAME"); ?> </th>
        <th width="5%"> <?php echo JText::_("DEFAULT"); ?> </th>
        <th width="5%">&nbsp;</th>
      </tr>
    </thead>
    <tfoot>
      <tr>
        <td colspan="12"><?php echo $page->getListFooter(); ?> </td>
      </tr>
    </tfoot>
    <?php
	$count=count($services);
	if( $count>0 ) {
	for ($i=0;$i<$count; $i++) {
		$item	= $services[$i];

		JFilterOutput::objectHtmlSafe($item);
		$title=JText::_('EDIT_SERVICES_')." ID: ".$item->id;	
		$linkEdit = sprintf($viewLink, 'edit', $item->id, $i);
		
		$deleted = ($item->ws_core || $item->ws_default) ? 0 : 1;
		$core = ($item->ws_core) ? '<sup style="color:red;">['.JText::_('CORE').']</sub>' : '';
		?>
    <tr>
      <td><?php echo $page->getRowOffset( $i ); ?> </td>
      <td>
        <input type="radio" id="cb<?php echo $item->id; ?>" name="cid[]" value="<?php echo $item->id; ?>" onclick="isChecked(this.checked);" />
        <input type="hidden" id="chkDel<?php echo $item->id; ?>" name="chkDel<?php echo $item->id; ?>" value="<?php echo $deleted; ?>" />
      </td>
      <td><span id="ws_name<?php echo $item->id?>"> <?php echo $item->ws_name . $core;?> </span></td>
      <td><span id="ws_mode<?php echo $item->id?>"> <?php echo $item->ws_mode;?> </span></td>
      <td><span id="ws_uri<?php echo $item->id?>"> <?php echo $item->ws_uri;?> </span></td>
      <td><span id="ws_user<?php echo $item->id?>"> <?php echo $item->ws_user;?> </span></td>
      <td align="center">
      <span id="ws_default<?php echo $item->id?>">
        <?php if($item->ws_default ==1): ?>
        <img  border="0" alt="" src="components/<?php echo JACOMPONENT; ?>/assets/images/icon-16-default.png"/>
        <?php endif; ?>
        </span>        
      </td>
      <td align="center"><a href="#" title="<?php echo JText::_('EDIT'); ?>" onclick="jaCreatePopup('<?php echo $linkEdit; ?>', 400, 350, '<?php echo JText::_($item->ws_name . " [Edit]", true)?>'); return false;"><?php echo JText::_('EDIT'); ?></a></td>
    </tr>
    <?php }?>
    <?php }else{ ?>
    <tr>
      <td colspan="5"><?php echo JText::_("HAVE_NO_RESULT")?> </td>
    </tr>
    <?php } ?>
  </table>
  </fieldset>
</form>

<?php
/*
# ------------------------------------------------------------------------
# JA Extensions Manager
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/

//no direct access
defined( '_JEXEC' ) or die( 'Retricted Access' );

global $mainframe, $option, $jauc;

$checkLog = JaextmanagerModelDefault::getLastCheckObject();
?>
<script language="javascript">
// Proccess for check update button
//<![CDATA[
function submitbutton(pressbutton) {
	var form = document.adminForm;
	// Check update
	if ( pressbutton == 'checkupdate'){
		checkNewVersions();
		return;
	}
	
	// Recovery
	if ( pressbutton == 'recovery'){
		recoveryAll();
		return;
	} 
	//config services
	<?php foreach($this->services as $service): ?>
	if ( pressbutton == 'config_extensions_<?php echo $service->id; ?>'){
		form.service_id.value = '<?php echo $service->id; ?>';
		form.service_name.value = '<?php echo JText::_($service->ws_name, true); ?>';
		submitform( 'config_multi_extensions' );
		return;
	} 
	<?php endforeach; ?>
	
	submitform( pressbutton );
}
//]]>
</script>

<form name="adminForm" id="adminForm" action="index.php" method="post">
  <div id="ja-filter">
    <table width="100%">
      <tr>
        <td align="left"><?php 
		$tipid = uniqid("ja-tooltip-");
		$linkRepo = "<a href=\"#\" id=\"{$tipid}\" class=\"ja-tips-title\" title=\"\">".JText::_("JA_REPOSITORY")."</a>";
		$linkEditRepo = "<a href=\"index.php?option=".JACOMPONENT."&view=default&layout=config_service\" title=\"\">".JText::_("EDIT")."</a>";
		$linkUpload = "<a href=\"#\" onclick=\"jaOpenUploader(); return false;\" title=\"".JText::_("UPLOAD")."\" class=\"highlight\">".JText::_("UPLOAD")."</a> ";
		$linkHelp = "<a href=\"index.php?option=".JACOMPONENT."&view=default&layout=help_support\" title=\"".JText::_("HELP_AND_SUPPORT")."\" class=\"highlight\">".JText::_("HELP_AND_SUPPORT")."</a>";
		$intro = "All versions of extensions are stored in %s (%s), to start using auto update of supported extension, %s new version of the extension now.<br /> Please read %s for more information.<br />";
		$intro = JText::sprintf($intro, $linkRepo, $linkEditRepo, $linkUpload, $linkHelp);
		echo $intro;
		?>
          <script type="text/javascript">
		/*<![CDATA[*/
		window.addEvent('domready', function(){
			new JATooltips ([$('<?php echo $tipid; ?>')], {
					content: '<?php echo addslashes(JText::_("JA_REPOSITORY")."<br />".JA_WORKING_DATA_FOLDER); ?>'
			});
		});
		/*]]>*/
		</script>
        </td>
        <td align="right" valign="top" width="300"><?php echo JText::_("FILTER");?>:
          <input type="text" class="text_area" value="<?php echo JRequest::getVar('search');?>" id="search" name="search"/>
          <?php echo $this->boxType;?>
          <input type="button" onclick="this.form.submit();" value="<?php echo JText::_('GO'); ?>" />
        </td>
      </tr>
    </table>
  </div>
  <fieldset>
  <legend><?php echo JText::_("EXTENSIONS");?></legend>
  <?php if (isset($this->showMessage) && $this->showMessage) : ?>
  <?php echo $this->loadTemplate('message'); ?>
  <?php endif; ?>
  <?php if (count($this->listExtensions)) : ?>
  <table class="adminlist ja-uc" cellspacing="1">
    <thead>
      <tr>
        <th width="10"><?php echo JText::_('NUM' ); ?></th>
        <th width="20"> <input type="checkbox" name="toggle" value="" onclick="checkAll(<?php echo count($this->listExtensions); ?>, 'cId');" />
        </th>
        <th width="200" style="text-align: left;" nowrap="nowrap"> <?php echo JText::_('EXTENSION_NAME' ); ?> </th>
        <th style="text-align: left;"><?php echo JText::_('AUTHOR' ); ?></th>
        <th width="25"><?php echo JText::_('TYPE' ); ?></th>
        <th width="80"> <?php echo JText::_('VERSION' ); ?> </th>
        <th> <?php echo JText::_('CREATED_DATE' ); ?> </th>
        <th width="100"><?php echo JText::_('SERVICE' ); ?></th>
      </tr>
    </thead>
    <tbody>
      <?php
      $index = 0;
	 /* echo "<pre>";
	  print_r($this->listExtensions);
	  echo "</pre>";*/
      foreach ($this->listExtensions as $key=>$obj):
        $obj->index = $index++;
		
		$obj->img    = $obj->enabled ? 'tick.png' : 'publish_x.png';
		$obj->task   = $obj->enabled ? 'disable' : 'enable';
		$obj->alt    = $obj->enabled ? JText::_('ENABLED' ) : JText::_('DISABLED' );
		$obj->action = $obj->enabled ? JText::_('DISABLE' ) : JText::_('ENABLE' );

		if ($obj->iscore) {
			$obj->cbd    = 'disabled';
			$obj->style  = 'color:#999999;';
		} else {
			$obj->cbd    = null;
			$obj->style  = null;
		}
		//$obj->author_info = @$obj->authorEmail .'<br />'. @$obj->authorUrl;
		$extID = $obj->extId;
		$css = "row".($index%2);
		
		$diffDate = $this->nicetime($obj->creationdate);
    ?>
      <tr>
        <td valign="top"><?php echo $this->pagination->getRowOffset( $obj->index ); ?></td>
        <td valign="top"><input type="checkbox" id="cId<?php echo $obj->index;?>" name="cId[]" value="<?php echo $extID; ?>" onclick="isChecked(this.checked);" <?php echo $obj->cbd; ?> /></td>
        <td valign="top"><strong class="addon-name"><?php echo $obj->name; ?></strong> </td>
        <td valign="top"><?php 
			//fix url
			if(strpos($obj->authorUrl, "http") !== 0) {
				$obj->authorUrl = "http://".$obj->authorUrl;
			}
			
			$tipid = uniqid("ja-tooltip-");
			$authorTip = "<strong>{$obj->author}</strong><br />";
			$authorTip .= JText::_('WEBSITE') . ": <a href=\"{$obj->authorUrl}\" title=\"\">{$obj->authorUrl}</a><br />";
			$authorTip .= JText::_('EMAIL') . ": <a href=\"mailto:{$obj->authorEmail}\" title=\"\">{$obj->authorEmail}</a><br />";
			?>
          <a id="<?php echo $tipid; ?>" class="ja-tips-title author" href="<?php echo $obj->authorUrl; ?>" target="_blank"><?php echo $obj->author; ?></a>
          <script type="text/javascript">
            /*<![CDATA[*/
            window.addEvent('domready', function(){
                new JATooltips ([$('<?php echo $tipid; ?>')], {
                        content: '<?php echo addslashes($authorTip); ?>'
                });
            });
            /*]]>*/
            </script>
        </td>
        <td valign="top" align="left"><span class="icon-<?php echo $obj->type; ?>" title="<?php echo JText::_($obj->type); ?>"><?php echo JText::_($obj->type); ?></span></td>
        <td valign="top" align="center"><?php echo (isset($obj->version) && $obj->version != '') ? $obj->version : '&nbsp;'; ?></td>
        <td valign="top" align="center"><?php echo $obj->creationdate; ?>
          <?php if($diffDate !== false): ?>
          <small class="nicetime"><?php echo $diffDate; ?></small>
          <?php endif; ?>
        </td>
        <td valign="top" align="center"><a href="#" id="config<?php echo $extID;?>" title="<?php echo addslashes($obj->name); ?>" onclick="configExtensions(this, '<?php echo $extID;?>'); return false;" > <?php echo $obj->ws_name; ?> </a> </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td valign="top">&nbsp;<img src="<?php echo JURI::root().'administrator/components/'.JACOMPONENT.'/assets/css/images/arrow_point_right.gif'; ?>" alt="" /></td>
        <td valign="top">
        <div class="clearfix"> 
            <a class="check-update" title="Check Update" href="#" onclick="checkNewVersion('<?php echo $extID;?>', 'LastCheckStatus_<?php echo $extID;?>'); return false;"><?php echo JText::_('CHECK_UPDATE'); ?></a> 
            <a class="recovery" title="<?php echo JText::_('ROLLBACK'); ?>" href="#" onclick="recoveryItem('<?php echo $extID;?>', 'LastCheckStatus_<?php echo $extID;?>'); return false;"><?php echo JText::_('ROLLBACK'); ?></a> 
        </div>
        </td>
        <td colspan="5" class="checkstatus" id="LastCheckStatus_<?php echo $extID; ?>"><?php echo JaextmanagerModelDefault::getLastCheckStatus($checkLog, $extID);?></td>
      </tr>
      <?php endforeach; ?>
    </tbody>
    <tfoot>
      <tr>
        <td colspan="11"><?php echo $this->pagination->getListFooter(); ?></td>
      </tr>
    </tfoot>
  </table>
  <?php else : ?>
  <?php echo JText::_('DATA_NOT_FOUND' ); ?>
  <?php endif; ?>
  <input type="hidden" name="option" value="<?php echo JACOMPONENT; ?>" />
  <input type="hidden" name="view" value="<?php echo JRequest::getVar("view", "default")?>" />
  <input type="hidden" name="task" value="" />
  <input type="hidden" name="boxchecked" value="0" />
  <input type="hidden" name="Itemid" value="<?php echo JRequest::getVar( 'Itemid');?>" />
  <input type="hidden" name="service_id" id="service_id" value="" />
  <input type="hidden" name="service_name" id="service_name" value="" />
  <?php echo JHTML::_( 'form.token'); ?>
  </fieldset>
</form>

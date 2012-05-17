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

global $mainframe, $option, $jauc;
$obj = $this->obj;
$listRecoveryFiles = $this->listRecoveryFiles;

$totalFiles = count($listRecoveryFiles);

$index		= 0;
$version	= "";

$conflictNote = JText::_("CONFLICTED_FILES_ARE_FILES_THAT_BOTH_CHANGED_IN_NEW_VERSION_AND_YOUR_CURRENT_VERSION_CONFLICTED_FILES_WILL_BE_REPLACED_WITH_NEW_FILES_IN_NEW_VERSIONS_IF_YOU_WISH_TO_REAPPLY_THE_CHANGECUSTOMIZATION_TO_THE_NEW_VERSION_AFTER_UPGRADE_YOU_CAN_VIEW_AND_DO_IT_BY_COPY_THE_CODE_CHANGES_FROM_YOUR_CUSTOMIZED_FILES_TO_NEW_FILE_AFTER_UPGRADE_READ_HELP__SUPPORT_FOR_MORE_INFORMATION");
$sTooltips = "";
for ($index	= 1; $index <= $totalFiles; $index++) {
	$file = $listRecoveryFiles[$index-1];
	
	if ( $file['version'] != $version ) {
		$version = $file['version'];
		$containerId = "backup-".$obj->extId."-".$index;
		$startGroup = true;
	} else {
		$startGroup = false;
	}
	$endGroup = (($index == $totalFiles) || (($index < $totalFiles) && $listRecoveryFiles[$index]['version'] != $version)) ? true : false;
	$displayGroup = ($index==1) ? "block" : "none";
	$statusGroup = ($index==1) ? JText::_("HIDE") : JText::_("SHOW");
?>
	<?php if($startGroup): ?>
    <?php
		$tipid 		= uniqid("ja-tooltip-");
		$sTooltips		.= jaEMTooltips($tipid, $conflictNote);
	?>
	<?php echo JText::sprintf("VERSION_S", $file['version']); ?>
    [ <a href="#" style="color:#800000" onclick="showMoreOlderVersion(this, '<?php echo $containerId; ?>'); return false;"><?php echo $statusGroup; ?></a> ]
    <br />
    <div id="<?php echo $containerId; ?>" style="display:<?php echo $displayGroup; ?>" class="ja-backup-list">
    <table class="ja-uc-child">
      <tr>
        <th width="120"><?php echo JText::_("BACKUP_DATE"); ?></th>
        <th><?php echo JText::_("COMMENT"); ?></th>
        <th width="100"><?php echo JText::sprintf("CONFLICT_S", "<sup id=\"{$tipid}\">[?]<sup>"); ?></th>
        <th width="100">&nbsp;</th>
      </tr>
    <?php endif; ?>
      <tr>
        <td><?php echo $file['title']; ?></td>
        <td><?php echo (isset($file['comment']) ? $file['comment'] : ''); ?></td>
        <td>
			<?php 
            if($file['conflicted']):
                $link = sprintf("?option=%s&view=default&task=compare_conflicted&cId[]=%s&folder=%s", JACOMPONENT, $obj->extId, $file['conflictedFolder']);
            ?>
				<?php echo JText::_("YES"); ?>
                (<a href="<?php echo $link; ?>" title="<?php echo JText::_("VIEW_CONFLICTED_FILES"); ?>">
                <?php echo JText::_("VIEW"); ?>
                </a>)
            <?php else: ?>
				<?php echo JText::_("NO"); ?>
			<?php endif; ?>
        </td>
        <td>
        <a href="#" onclick="doRecoveryItem('<?php echo $obj->extId; ?>', '<?php echo $file['version']; ?>', '<?php echo $file['name']; ?>'); return false;" title="<?php echo JText::_("ROLLBACK_TO_THIS_POINT"); ?>">
		<?php echo JText::_("ROLLBACK_NOW"); ?>		</a>        </td>
      </tr>
    <?php if($endGroup): ?>
    </table>
    </div>
    <?php endif; ?>
<?php }//endfor ?> 
<?php echo $sTooltips; ?> 
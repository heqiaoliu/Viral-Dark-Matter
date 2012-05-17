<?php defined('_JEXEC') or die('Restricted access'); ?>
<script type="text/javascript">
/*<![CDATA[*/
function multiDelete() {
	var numChecked = jQuery("input[name='rm[]']:checked", window.frames['folderframe'].document).size();
	if(numChecked > 0) {
		var title = '<?php echo JText::_("ARE_YOU_REALLY_WANT_TO_DELETE", true); ?>';
		if(confirm(title)){
			MediaManager.submit('delete');
		}
		return false;
	} else {
		alert("<?php echo JText::_("PLEASE_SELECT_AN_ITEMS_FROM_THE_LIST_TO_DELETE", true); ?>");
		return false;
	}
}
/*]]>*/
</script>
<table width="100%" cellspacing="0">
  <tr valign="top">
    <td width="200px">
      <fieldset id="treeview">
      <legend><?php echo JText::_('FOLDERS' ); ?></legend>
      <div id="media-tree_tree"></div>
      <?php echo $this->loadTemplate('folders'); ?>
      </fieldset>
    </td>
    <td>
    <form action="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=folder&amp;task=create" name="folderForm" id="folderForm" method="post">
        <fieldset id="folderview">
        <legend><?php echo JText::_('FILES' ); ?></legend>
        <div class="path">
          <input class="inputbox" type="text" id="folderpath" readonly="readonly" />
          <input class="update-folder" type="hidden" name="folderbase" id="folderbase" value="<?php echo $this->state->folder; ?>" />
        </div>
        <div class="view">
          <iframe src="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=repolist&amp;tmpl=component&amp;folder=<?php echo $this->state->folder;?>" id="folderframe" name="folderframe" width="100%" marginwidth="0" marginheight="0" scrolling="auto" frameborder="0"></iframe>
        </div>
        </fieldset>
        <?php echo JHTML::_( 'form.token' ); ?>
      </form>
      <form action="index.php?option=<?php echo JACOMPONENT; ?>&amp;view=repo" name="adminForm" id="mediamanager-form" method="post" enctype="multipart/form-data" >
        <input type="hidden" name="task" value="" />
        <input type="hidden" name="cb1" id="cb1" value="0" />
        <input class="update-folder" type="hidden" name="folder" id="folder" value="<?php echo $this->state->folder; ?>" />
      </form>
    </td>
  </tr>
</table>
<?php
/**
* @version 1.5
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*/

defined( '_JEXEC' ) or die( 'Restricted access' );

class jlist_HTML2{   
    
function editFile($option, $row, $licenses, $inputbox_pic, $listbox_system, $listbox_language, $action, $publish, $confirm, $update, $all_custom_arr, $custom_arr, $custom_titles_arr){   
    global $mainframe, $jlistConfig, $page_title;
    
    $user      = &JFactory::getUser();
    $database  = &JFactory::getDBO();
    jimport( 'joomla.html.pane');
    
    $editor =& JFactory::getEditor();
    $editor2 =& JFactory::getEditor();
    $params = array( 'smilies'=> '0' ,
                 'style'  => '1' ,  
                 'layer'  => '0' , 
                 'table'  => '0' ,
                 'clear_entities'=>'0'
                 );

    $document=& JFactory::getDocument();
    $document->setTitle($page_title.' - '.JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TITLE') );
    
    $footer = makeFooter(true, false, false, 0, 0, 0, 0, false, false, false); 

    $allowed_file_types_view = strtolower(str_replace(',', ', ', $jlistConfig['allowed.upload.file.types']));
    $allowed_file_types = strtolower($jlistConfig['allowed.upload.file.types']).','.strtoupper($jlistConfig['allowed.upload.file.types']);
    $max_file_size = $jlistConfig['allowed.upload.file.size'] * 1024 ;
    
?>  
<script language="javascript" type="text/javascript">
<!--
function setgood() {
    // TODO: Put setGood back
    return true;
}

function submitbutton(pressbutton) {
    var form = document.editForm;
    if (pressbutton == 'cancel') {
        history.go(-1);
        return;
    }
    if (pressbutton == 'delete'){
        var r=confirm("<?php echo JText::_( 'COM_JDOWNLOADS_FE_FILESEDIT_DELETE_DOWNLOAD_CONFIRM_MSG', true ); ?>");
        if (r==false){
            return;
        } else {
            form.deletefile.value = 1;
            form.submit();                                   
        }    
    }
        
    try {
        form.onsubmit();
    } catch(e) {
        alert(e);
    }

    // do field validation
    if (form.file_title.value == '') {
        return alert ( "<?php echo JText::_( 'COM_JDOWNLOADS_BACKEND_FILESEDIT_ERROR_TITLE', true ); ?>" );
    } 
    form.submit();
}
//-->
</script>




    <div class="componentheading" style="background-color:#EFEFEF; padding:10px;"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TITLE') ?></div>
    <form action="<?php echo $action; ?>" method="post" name="editForm" id="editForm"  onSubmit="setgood();" enctype="multipart/form-data">
    <div style="float: right;">
            <button type="button" onclick="submitbutton('save')">
                <?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_SAVE_BUTTON') ?>
            </button>
            <button type="button" onclick="submitbutton('cancel')">
                <?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_CANCEL_BUTTON') ?>
            </button>
            <button type="button" name="delete" onclick="submitbutton('delete')">
                <?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_DELETE_BUTTON') ?>
            </button>
        </div>
<?php
$pane =& JPane::getInstance('Tabs');
echo $pane->startPane('editfile');
echo $pane->startPanel(JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TABTITLE_1'),'daten1');
?>
<table width="100%" border="0">
    <tr>
        <td width="100%" valign="top">
                <table cellpadding="4" cellspacing="1" border="0" class="adminlist">
                   <tr>
                      <td valign="top" align="left" width="100%">
                          <table width="100%">
                              <tr>
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_FILE_TITLE')." "; ?></td>
                              <td><input name="file_title" value="<?php echo  stripslashes(htmlspecialchars($row->file_title, ENT_QUOTES)); ?>" size="60" maxlength="255"/></td>
                              </tr><tr>      
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_EDIT_FILES_SET_UPDATE_TITLE').': </td>'; ?>
                              <td>  <?php echo $update.' '.JHTML::_('tooltip',JText::_('COM_JDOWNLOADS_BACKEND_EDIT_FILES_SET_UPDATE_TEXT')); ?></td>   
                              </tr><tr>
                              <td width="150">
                                    <?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_RELEASE')." "; ?></td>
                              <td><input name="release" value="<?php echo  htmlspecialchars($row->release, ENT_QUOTES); ?>" size="15" maxlength="255"/></td>
                              </tr><tr>
                              <td width="150">
                                    <?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_SYSTEM')." "; ?></td>
                              <td>  <?php echo $listbox_system; ?></td>
                              </tr><tr>
                              <td width="150">
                                    <?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_LANGUAGE')." "; ?></td>
                              <td>      <?php echo $listbox_language; ?></td>
                              </tr><tr>
                              <td width="150">      
                                    <?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_LICENSE')." "; ?></td>
                              <td>  <?php
                                    $templic = (int)$row->license;
                                    $inputbox_lic = JHTML::_('select.genericlist', $licenses, 'license', 'size="1" class="inputbox"', 'value', 'text', $templic );
                                    echo $inputbox_lic; ?></td>
                               </tr><tr>
                              <td width="150">     
                                    <?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILE_EDIT_MUST_CONFIRM_LICENSE_TITLE')." "; ?></td>
                              <td>  <?php echo $confirm ?></td>
                              </tr>
                              <tr>
                                <td width="150"><?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_PRICE')." "; ?></td>
                                <td><input name="price" id="price" value="<?php echo  htmlspecialchars($row->price, ENT_QUOTES); ?>" size="20"/></td>
                              </tr>  
                              <tr>
                                <td width="150"><?php echo JText::_('COM_JDOWNLOADS_EDIT_FILE_FILE_DATE_TITLE')." "; ?></td>
                                <td><input name="file_date" id="file_date" value="<?php echo $row->file_date; ?>" size="20"/>
                                    <input name="reset" type="reset" class="button" onclick="return showCalendar('file_date', '%Y-%m-%d')" value="..." />
                                </td> 
                              </tr>
                              
                              
                              <!-- <tr>  
                              <td width="300">     
                                 <?php echo JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_FRONTEND_FPIC_TEXT')." "; ?></td>
                              <td>   <?php echo $inputbox_pic; ?></td>
                              </tr><tr colspan="2">
                              <td width="300">     
                                   <script language="javascript" type="text/javascript">
                                   if (document.editForm.file_pic.options.value!=''){
                                         jsimg="<?php echo JURI::base().'images/jdownloads/fileimages/'; ?>" + getSelectedText( 'editForm', 'file_pic' );
                                      } else {
                                            jsimg='';
                                   }
                                   document.write('<img src=' + jsimg + ' name="imagelib" width="32" height="32" border="1" alt="<?php echo JText::_('COM_JDOWNLOADS_BACKEND_SETTINGS_FRONTEND_FPIC_PREVIEW'); ?>" />');
                                   </script>
                                  </td> 
                              </tr>-->   
                          </tr>
                          </table>
                            <table>
                              <tr>
                                <td><strong><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_DESCRIPTION_KURZ')." "; ?></strong><br />
                                <?php
                                if ($jlistConfig['files.editor'] == "1") {
                                    echo $editor->display( 'description',  @$row->description , '500', '300', '60', '5', false, '' ) ;
                                } else {?>
                                    <textarea name="description" rows="4" cols="60"><?php echo  htmlspecialchars($row->description, ENT_QUOTES); ?></textarea>
                                <?php
                                } ?>
                                </td>
                              </tr>
                              </table>
                            <table>
                            <tr>
                                <td colspan="2"><strong><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_DESCRIPTION_LONG')." "; ?></strong><br />
                                <?php
                                if ($jlistConfig['files.editor'] == "1") {
                                    echo $editor2->display( 'description_long',  @$row->description_long , '500', '300', '60', '5', false, '' ) ;
                                } else {?>
                                    <textarea name="description_long" rows="6" cols="60"><?php echo  htmlspecialchars($row->description_long, ENT_QUOTES); ?></textarea>
                                <?php
                                } ?>
                                </td>
                              </tr>
                          </table>
                </table>
        </td>
    </tr>
</table>  

<?php
echo $pane->endPanel();
echo $pane->startPanel(JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TABTITLE_2'),'daten2');  
?>
<table width="100%" border="0">
    <tr>
        <td width="100%" valign="top">
                <table cellpadding="4" cellspacing="1" border="0" class="adminlist">
                   <tr>
                      <td valign="top" align="left" width="100%">
                          <table width="100%">
                          <tr>
                                <td colspan="2"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_AUTHOR_INFOS_TITLE').": "; ?><br /><br /></td>
                            </tr>
                            <tr>
                                <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_URL_HOME').": "; ?></td>
                                <td><input name="url_home" value="<?php echo  htmlspecialchars($row->url_home, ENT_QUOTES); ?>" size="40" maxlength="255"/></td>
                              </tr>
                              <tr>
                                <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_AUTHOR').": "; ?></td>
                                <td> <input name="author" value="<?php echo  htmlspecialchars($row->author, ENT_QUOTES); ?>" size="40" maxlength="255"/></td>
                              </tr>
                              <tr>
                                <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_AUTHOR_URL').": "; ?></td>
                                <td> <input name="url_author" value="<?php echo  htmlspecialchars($row->url_author, ENT_QUOTES); ?>" size="40" maxlength="255"/></td>
                              </tr>                          
                             <tr><td width="80%" colspan="2"><br /><hr><br /></td></tr>
                            <tr>
                                <td width="150" valign="top"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_EDIT_METADESC_TITLE')." "; ?></td>
                                <td>  <textarea name="metadesc" rows="3" cols="35"><?php echo  htmlspecialchars($row->metadesc, ENT_QUOTES); ?></textarea></td>
                            </tr>
                            <tr>
                                <td width="150" valign="top"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_EDIT_METAKEY_TITLE')." "; ?></td>
                                <td> <textarea name="metakey" rows="3" cols="35"><?php echo  htmlspecialchars($row->metakey, ENT_QUOTES); ?></textarea></td>
                            </tr>                          
                           <?php if (count($all_custom_arr)) { 
                              ?> <tr><td width="80%" colspan="2"><br /><hr><br /></td></tr> <?php
                              for ($i=0; $i < count($all_custom_arr); $i++){
                              ?>
                           <tr>
                             <td width="150" valign="top"><?php echo $custom_titles_arr[$i]; ?></td>
                             <td><?php echo stripslashes($all_custom_arr[$i]); ?></td>
                           </tr>
                           
                           <?php } 
                           } ?>
                          </table>
                </table>
        </td>
    </tr>
</table>                          

<?php
echo $pane->endPanel();
echo $pane->startPanel(JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TABTITLE_3'),'daten3');   
?>
<table width="100%" border="0">
    <tr>
        <td width="100%" valign="top">
                <table cellpadding="4" cellspacing="1" border="0" class="adminlist">
                   <tr>
                      <td valign="top" align="left" width="100%">
                          <table width="100%">
                          <tr>
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_FILE_ADD_FROM_SERVER')." "; ?></td>
                              <td><big><font color="#990000"><?php echo $row->url_download; ?></font></big></td>
                           </tr>
                           <tr>
                              <td valign="top" width="150"><?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_SELECT_FILE'); ?></td>
                              <td><input name="file_upload" id="file_upload" size="30" type="file" onchange="" value=""/><br /><small><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_ALLOWED_FILETYPE').': '.$allowed_file_types_view.'<br />'.JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_ALLOWED_MAX_SIZE').': '.$jlistConfig['allowed.upload.file.size'].' KB'; ?></small></td> 
                           </tr>
                             <tr>
                              <td width="150"><font color="#990000"><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_EXTERN_FILE_OR')."</font><br />".JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_EXTERN_FILE_TITEL'); ?></td>        
                              <td><input name="extern_file" value="<?php echo $row->extern_file; ?>" size="40" maxlength="255"/></td>
                           </tr>
                           <tr>
                                <td valign="top" width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_OPEN_LINK_IN_OTHER_WEBSITE_TITLE')." "; ?></td>
                                    <td><?php echo JHTML::_('select.booleanlist',"extern_site",'',($row->extern_site) ? 1:0);?></td></tr>
                                    <tr><td valign="top" colspan="2"><small><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_OPEN_LINK_IN_OTHER_WEBSITE_DESC'); ?></small>
                                  </td>
                              </tr>                            
                       <tr><td width="80%" colspan="2"><br /><hr><br /></td></tr>
                             <tr> 
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_MIRROR_TITLE')." "; ?></td>
                              <td><input name="mirror_1" value="<?php echo $row->mirror_1 ?>" size="40" maxlength="255"/></td>
                              </tr>
                             <tr>
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_OPEN_LINK_IN_OTHER_WEBSITE_TITLE')." "; ?></td>
                                <td> <?php echo JHTML::_('select.booleanlist',"extern_site_mirror_1",'',($row->extern_site_mirror_1) ? 1:0);?></td> 
                              </tr>
                             <tr>
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_MIRROR_TITLE')." "; ?></td>
                              <td> <input name="mirror_2" value="<?php echo $row->mirror_2 ?>" size="40" maxlength="255"/> </td>
                              </tr>
                             <tr>
                              <td width="150"><?php echo JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_OPEN_LINK_IN_OTHER_WEBSITE_TITLE')." "; ?></td>
                               <td><?php echo JHTML::_('select.booleanlist',"extern_site_mirror_2",'',($row->extern_site_mirror_2) ? 1:0);?></td> 
                              </tr>
                              <tr><td width="100%" colspan="2"><small><?php  echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_MIRROR_DESC'); ?></small></td></tr>    
                          
                       <?php // if ($jlistConfig['fe.upload.view.pic.upload'] == '1') { ?>
                       
                       <tr><td width="80%" colspan="2"><hr><br /></td></tr>
                       <tr><td colspan="2"><?php echo JText::_('COM_JDOWNLOADS_FE_FILESEDIT_PIC_PREVIEW_TEXT').": "; ?></td>  
                       <tr><td style="padding:10px" colspan="2" align="center">
                       <?php
                       if ($row->thumbnail != '')  $pic1 = '<img src="'.JURI::base().'images/jdownloads/screenshots/thumbnails/'.$row->thumbnail.'" align="top" width="'.$jlistConfig['thumbnail.size.width'].'" height="'.$jlistConfig['thumbnail.size.height'].'" border="0" title="'.$row->thumbnail.'" />';
                       if ($row->thumbnail2 != '') $pic2 = '<img src="'.JURI::base().'images/jdownloads/screenshots/thumbnails/'.$row->thumbnail2.'" align="top" width="'.$jlistConfig['thumbnail.size.width'].'" height="'.$jlistConfig['thumbnail.size.height'].'" border="0" title="'.$row->thumbnail2.'" />';
                       if ($row->thumbnail3 != '') $pic3 = '<img src="'.JURI::base().'images/jdownloads/screenshots/thumbnails/'.$row->thumbnail3.'" align="top" width="'.$jlistConfig['thumbnail.size.width'].'" height="'.$jlistConfig['thumbnail.size.height'].'" border="0" title="'.$row->thumbnail3.'" />';
                       echo $pic1.' '.$pic2.' '.$pic3; 
                       ?>
                       </td>
                       </tr>
                       <tr>
                        <td width="150" valign="top"><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PIC_FILETITLE'); ?>
                        </td><td><input name="pic_upload" size="30" type="file" value="<?php echo $pic_upload; ?>"/><br /><small><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PIC_ALLOWED_FILES').' gif, jpg, png'; ?></small>
                        </td>
                        </tr>
                       <tr>
                        <td width="150" valign="top"><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PIC_FILETITLE2'); ?>
                        </td><td><input name="pic_upload2" size="30" type="file" value="<?php echo $pic_upload2; ?>"/><br /><small><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PIC_ALLOWED_FILES').' gif, jpg, png'; ?></small>
                        </td>
                        </tr>
                       <tr>
                        <td width="150" valign="top"><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PIC_FILETITLE2'); ?>
                        </td><td><input name="pic_upload3" size="30" type="file" value="<?php echo $pic_upload3; ?>"/><br /><small><?php echo JText::_('COM_JDOWNLOADS_FRONTEND_UPLOAD_PIC_ALLOWED_FILES').' gif, jpg, png'; ?></small>
                        </td>
                        </tr>
                        
                        <?php // } ?> 
                          
                          </table>
                </table>
        </td>
    </tr>
</table>  
                          
<?php 
echo $pane->endPanel();
echo $pane->endPane('editfile'); ?>  
 
    <input type="hidden" name="modified_date" value="<?php echo $row->modified_date; ?>"/>
    <input type="hidden" name="option" value="<?php echo $option;?>" />
    <input type="hidden" name="deletefile" value="0" />
    <input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $max_file_size;?>" />
    <input type="hidden" name="file_alias" value="<?php echo $row->file_alias; ?>" />
    <input type="hidden" name="cat_id" value="<?php echo $row->cat_id; ?>" />
    <input type="hidden" name="url_download_old" value="<?php echo $row->url_download; ?>" />
    <input type="hidden" name="file_id" value="<?php echo $row->file_id; ?>" />
    <input type="hidden" name="extern_file_old" value="<?php echo $row->extern_file; ?>" />
    <input type="hidden" name="cid" value="<?php echo $row->file_id; ?>" /> 
     
    <?php echo JHTML::_( 'form.token' );
          JHTML::_('behavior.keepalive'); ?>
    </form>    
<?php    
    echo $footer;
}

}
?>
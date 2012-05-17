<?php
/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// No direct access
defined('_JEXEC') or die;

$db = JFactory::getDBO();
$helpurl = 'http://www.joomlart.com/?ajax=module&name=youtubeplaylist';
JHTML::_('behavior.modal', 'a.modal');
?>
<script type="text/javascript">
    var isNewFolderStruct = <?php echo ($isNewFolderStruct)? 'true' : 'false'?>;
    var imgloading = '<?php echo $uri.'/assets/images/loading-small.gif';?>';
    var imgdelete = '<?php echo $uri.'/assets/images/icon-16-deny.png';?>';
    var profiles = <?php echo json_encode($jsonData)?>;
    var general = <?php echo json_encode($jsonData['generalconfigdata'])?>;
    var jatabs = null;
    var template = '<?php echo $template?>';
    var styleid = '<?php echo JRequest::getInt('id')?>';
    var layouts =  <?php echo json_encode($layouts)?>;
    var jat3admin = null;
    var numberTab = '<?php echo $numbertab?>';
    var requesting = false;
    var helpUrl = '<?php echo $helpurl?>';
    window.addEvent('load', function (e){
        jatabs = new JATabs('ja-tabswrap', {
            numbtab : numberTab,
            animType : 'animNone',
            style : 'default',
            position : 'top',
            width : '100%',
            height : 'auto',
            mouseType : 'click',
            duration : 1000,
            colors : 10,
            useAjax : false,
            skipAnim : true
        });

        $$('#style-form .width-60').setStyle('width', '42%');
        $$('#style-form .width-40').setStyle('width', '56%');
        $('ja-tabswrapmain').show();

        $$('#style-form .width-60')[1].set('text', '');
        $('ja-page-assignment').injectInside($$('#style-form .width-60')[1]);
        $$('#style-form .width-60').show();

        jat3admin = new JAT3_ADMIN();
        jatabs.resize();

        $$('#jat3-profile-params h3.title').each(function(el){
            el.addEvent('click', function(e){
                window.fireEvent('resize', e, 300);
            })
        })

        // Button help
        $('toolbar-help').getElement('a.toolbar').destroy();
        $('<?php echo $name?>-ja-popup-pageids').inject($(document.body));
        $('<?php echo $name?>-ja-popup-profiles').inject($(document.body));

        if (helpUrl != '') $('ja-introduce').inject($('toolbar-help'));

        jat3admin.controlHelp();
    });
</script>
<div id="jat3-loading"></div>
<div style="width: 100%;" class="ja-tabswrap default" id="ja-tabswrapmain">

<!-- Left Column: Page settings -->
<table width="100%" class="ja-general-settings" id="ja-page-assignment">
    <tr  class="level2">
        <td>
            <h4 id="ja-head-page-settings" class="block-head block-head-logosetting open" rel="2">
                <span class="block-setting"><?php echo JText::_('PAGE_ASSIGNMENTS')?></span>
                <span class="icon-help editlinktip hasTip" title="<?php echo JText::_('PAGE_ASSIGNMENTS_DESC')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                <a onclick="showHideRegion('ja-head-page-settings', 'level2'); return false;" title="<?php echo JText::_('CLICK_HERE_TO_EXPAND_OR_COLLAPSE')?>" class="toggle-btn">open</a>
             </h4>
        </td>
    </tr>
    <tr  class="level3">
        <td>
            <?php require_once dirname(__FILE__).DS.'pageidsettings.php';?>
        </td>
    </tr>
</table>

<!-- Check ther are error messages -->

<div id="<?php echo $name?>-ja-popup-pageids" class="ja-popup-pageids">
    <div class="page-assignment-bar">
        <input type="button" name="<?php echo JText::_('Select'); ?>" value="select"
            onclick="jaclass_<?php echo $name?>.select_multi_pageids('<?php echo $name?>'); return false;" class="save"/>
        <input type="button" name="<?php echo JText::_('Cancel'); ?>" value="cancel"
            onclick="jaclass_<?php echo $name?>.close_popup('<?php echo $name?>-ja-popup-pageids')" class="cancel"/>
    </div>

    <div class="language">
        <span><?php echo JText::_('Language'); ?></span>
        <?php if ($langlist): ?>
            <select id="ja-language" name="language" class="ja-language"
                onchange="jaclass_<?php echo $name;?>.changeLanguage(this);"
                onfocus ="jaclass_<?php echo $name;?>.focusLanguage(this);"
            >
            <?php foreach ($langlist as $lang): ?>
                <option value="<?php echo $lang;?>"><?php echo $lang;?></option>
            <?php endforeach; ?>
            </select>
        <?php endif; ?>
    </div>

    <div class="pages">
      <span><?php echo JText::_('Pages'); ?></span>
      <?php echo $pageids?>
    </div>
</div>

<div id="<?php echo $name?>-ja-popup-profiles" class="ja-popup-profiles">
    <ul class="ja-popup-profiles">
        <?php if($profiles) {?>
           <?php foreach ($profiles as $k=>$profile) { ?>
            <li>
                <a href="javascript:void(0)" onclick="jaclass_<?php echo $name?>.select_profile(this);">
                    <?php echo $k?>
                </a>
            </li>
        <?php }?>
           <?php }?>
    </ul>
</div>
<!-- Left Column: Page settings -->


<!-- Right Column: Tabs settings -->
<?php if (!$isNewFolderStruct): ?>
<div id="convert-message" style="background:#008000; color:#fff; font-weight:bold; padding:4px; text-align:center;">
  <p style="margin:6px">
    <?php echo JText::_('NOTIFY_CONVERT_MESSAGE'); ?>
    <a style="color:#ffffcc;text-decoration:underline;" href="javascript:jat3admin.convertFolder();">
    <?php echo JText::_('CLICK_HERE_TO_CONVERT'); ?>
    </a>
  </p>
</div>
<?php endif; ?>


<div class="container" id="ja-tabswrap">
    <div style="height: 30px;" class="ja-tabs-title-top">
        <ul class="ja-tabs-title">
            <li class="first general">
                <h3><span class="general"><?php echo JText::_('General')?></span></h3>

                <!-- BEGIN: Help -->
                <div class="ja-subcontent-help">
                    <a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
                    <?php echo JText::_('JAT3_GENERAL_HELP')?>
                </div>
                <!-- END: Help -->

            </li>
            <li class="profiles">
                <h3><span class="profiles"><?php echo JText::_('Profiles')?></span></h3>

                <!-- BEGIN: Help -->
                <div class="ja-subcontent-help">
                    <a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
                    <?php echo JText::_('JAT3_PROFILE_HELP')?>
                </div>
                <!-- END: Help -->

            </li>
            <li class="layouts">
                <h3><span class="layouts"><?php echo JText::_('Layouts')?></span></h3>

                <!-- BEGIN: Help -->
                <div class="ja-subcontent-help">
                    <a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
                    <?php echo JText::_('JAT3_LAYOUT_HELP')?>
                </div>
                <!-- END: Help -->

            </li>
            <li class="themes">
                <h3><span class="themes"><?php echo JText::_('Themes')?></span></h3>

                <!-- BEGIN: Help -->
                <div class="ja-subcontent-help">
                    <a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
                    <?php echo JText::_('JAT3_THEME_HELP')?>
                </div>
                <!-- END: Help -->


            </li>
            <li class="last help-support">
                <h3><span class="help-support"><?php echo JText::_('UPDATE_AND_HELP')?></span></h3>

                <!-- BEGIN: Help -->
                <div class="ja-subcontent-help">
                    <a title="<?php echo JText::_('Hide')?>" class="ja-help-close" href="javascript:void(0)" onclick="jat3admin.closeHelp(this, true)"><?php echo JText::_('Close')?></a>
                    <?php echo JText::_('JAT3_HELP_SUPPORT_HELP')?>
                </div>
                <!-- END: Help -->

            </li>
        </ul>
        <a class="ja-icon-video" href="javascript:void(0)" onclick="$('ja-introduce').fireEvent('click', new Event(window.event || event));"><span><?php echo JText::_('Video')?></span></a>
    </div>
    <div class="ja-tab-panels-top" style="height:0;">


        <!-- Begin: General Content -->
        <div class="ja-tab-content"    style="position: absolute; left: 0px; display: block;">
            <div class="ja-tab-subcontent">
                <?php $fieldSets = $configform->getFieldsets('general');?>
                <?php require_once dirname(__FILE__).DS.'global.php';?>
            </div>
        </div>
        <!-- End: General Content -->

        <!-- Begin: Profiles Content -->
        <div class="ja-tab-content"    style="position: absolute; left: 0px; display: block;">
            <div class="ja-tab-subcontent" id="ja-profiles-content">
                <?php require_once dirname(__FILE__).DS.'profiles.php';?>
            </div>
        </div>
        <!-- End: Profiles Content -->

        <!-- Begin: Layouts Content -->
        <div class="ja-tab-content"    style="position: absolute; left: 0px; display: block;">
            <div class="ja-tab-subcontent" id="ja-layouts-content">
                <table width="100%" class="ja-layout-settings">
                    <tr  class="level2">
                        <td>
                            <h4 id="ja-head-layout-settings" class="block-head block-head-logosetting open" rel="2">
                                <span class="block-setting"><?php echo JText::_('LAYOUT_SETTING')?></span>
                                <span class="icon-help editlinktip hasTip" title="<?php echo JText::_('LAYOUT_SETTING_DESC')?>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
                                <a onclick="showHideRegion('ja-head-layout-settings', 'level2'); return false;" title="<?php echo JText::_('CLICK_HERE_TO_EXPAND_OR_COLLAPSE')?>"  class="toggle-btn">open</a>
                             </h4>
                        </td>
                    </tr>
                    <tr  class="level3">
                        <td>
                            <?php require_once dirname(__FILE__).DS.'layouts.php';?>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <!-- End: Layouts Content -->

        <!-- Begin: Themes Content -->
        <div class="ja-tab-content"    style="position: absolute; left: 0px; display: block;">
            <div class="ja-tab-subcontent">
                <?php require_once dirname(__FILE__).DS.'themes.php';?>
            </div>
        </div>
        <!-- End: Themes Content -->


        <!-- Begin: Update & Help Content -->
        <div class="ja-tab-content"    style="position: absolute; left: 0px; display: block;">
            <div class="ja-tab-subcontent">
                <?php require_once dirname(__FILE__).DS.'help.php';?>
            </div>
        </div>
        <!-- End: Update & Help Content -->
    </div>
</div>
</div>


<div id="ja-layout-container" style="display: none; width:450px;height:340px;">
    <ul>
        <li class="save" onclick="jat3admin.saveLayout(this)"><?php echo JText::_('Save')?></li>
        <li class="cancel" onclick="jat3admin.cancelLayout(this)"><?php echo JText::_('Cancel')?></li>
    </ul>

    <div class="layout-name">
        <label for="name_layout"><?php echo JText::_('LAYOUT_NAME')?>:</label>
        <input type="text" value="" name="name_layout" id="name_layout" maxlength="20"/>
    </div>

    <textarea rows="20" cols="80" id="content_layout" name="content_layout"><?php //echo @$layouts['default']?></textarea>
</div>

<script type="text/javascript">
Joomla.submitbutton = function(pressbutton){
    if (pressbutton == 'style.apply') {
        jat3admin.saveData($('toolbar-apply'));
        return false;
    }
    else{
        submitform( pressbutton );
    }
    return false;
}
</script>
<script type="text/javascript">
    var lg_profile_name_exist = '<?php echo JText::_('PROFILE_NAME_S_ALREADY_EXIST_PLEASE_CHOOSE_ANOTHER')?>';
    var lg_enter_profile_name = '<?php echo JText::_('ENTER_PROFILE_NAME')?>';
    var lg_select_profile = '<?php echo JText::_('PLEASE_SELECT_PROFILE')?>';
    var lg_please_enter_profile_name = '<?php echo JText::_('PROFILE_NAME_CAN_NOT_BE_EMPTY')?>';
    var lg_confirm_delete_profile = '<?php echo JText::_('ARE_YOU_SURE_TO_DELETE_THIS_PROFILE')?>';
    var lg_confirm_reset_profile = '<?php echo JText::_('ARE_YOU_SURE_TO_RESET_TO_DEFAULT_THIS_PROFILE')?>';
    var lg_confirm_rename_profile = '<?php echo JText::_('CONFIRM_WHEN_RENAME_OR_DELETE_PROFILE')?>';

    var lg_layout_name_exist = '<?php echo JText::_('LAYOUT_NAME_S_ALREADY_EXIST_PLEASE_CHOOSE_ANOTHER')?>';
    var lg_enter_layout_name = '<?php echo JText::_('ENTER_LAYOUT_NAME')?>';
    var lg_please_enter_layout_name = '<?php echo JText::_('LAYOUT_NAME_CAN_NOT_BE_EMPTY')?>';
    var lg_select_layout = '<?php echo JText::_('PLEASE_SELECT_LAYOUT')?>';
    var lg_confirm_to_cancel = '<?php echo JText::_('ARE_YOU_SURE_TO_CANCEL')?>';
    var lg_confirm_delete_layout = '<?php echo JText::_('ARE_YOU_SURE_TO_DELETE_THIS_LAYOUT')?>';
    var lg_confirm_reset_layout = '<?php echo JText::_('ARE_YOU_SURE_TO_RESET_TO_DEFAULT_THIS_LAYOUT')?>';
    var lg_confirm_rename_layout = '<?php echo JText::_('CONFIRM_WHEN_RENAME_OR_DELETE_PROFILE')?>';
    var lg_confirm_save_layout = '<?php echo JText::_('DO_YOU_WANT_TO_SAVE_CHANGES_TO_LAYOUT_S')?>';
    var lg_invalid_xml_format = '<?php echo JText::_('INVALID_XML_FORMAT'); ?>';

    var lg_invalid_info = '<?php echo JText::_('INVALID_INFO')?>';
    var lg_confirm_delete_theme = '<?php echo JText::_('ARE_YOU_SURE_TO_DELETE_THIS_THEME')?>';
    var lg_confirm_delete_assignment = '<?php echo JText::_('ARE_YOU_SURE_TO_DELETE_THIS_ASSIGNMENT'); ?>';

    var lg_confirm_convert_folder = '<?php echo JText::_('ARE_YOU_SURE_TO_CONVERT_FOLDER'); ?>';
    var lg_convert_folder_success = '<?php echo JText::_('CONVERT_SUCCESS_MESSAGE'); ?>';

    //Move panels to profile tab
    var table_params = $('style-form').getElement('div.width-40').getFirst();

    var tabs = $('ja-tabswrapmain');
    if(table_params){
        tabs.injectBefore(table_params);
        // Fix bug show extra panels
        //if(table_params.getElement('div.panel')!=null){
        //    table_params.getElement('div.panel').injectInside($('jat3-profile-params'));
        //}
        expand_panel = table_params.getElements('div.panel');
        if (expand_panel.length > 0) {
            for(i = 0; i < expand_panel.length; i++) {
                expand_panel[i].injectInside($('jat3-profile-params'));
            }
        }
        table_params.dispose();
    }

    //Init accordion for profiles panel
    var panels = $$('div#jat3-profile-params.pane-sliders .panel div.jpane-slider');
    $$('div#jat3-profile-params.pane-sliders .panel h3.jpane-toggler').each(function (el, i){
        var regionID = 'regionID<?php echo time()?>';
        while($(regionID)!=null) regionID = 'regionID<?php echo time().rand()?>';
        panels[i].set('id', regionID);
        el.addClass('block-head-1');
        var bt1 = new Element('a', {
                                    'href': 'javascript:void(0)',
                                    'class':'toggle-btn open',
                                    'events': {
                                                'click': function (){
                                                    showGroup(regionID);
                                                }.bind(this)
                                            }
                                }).inject(el);
        bt1.innerHTML = '<?php echo JText::_('Expand all')?>';

        var bt2 = new Element('a', {
                                    'href': 'javascript:void(0)',
                                    'class':'toggle-btn close',
                                    'events': {
                                                'click': function (){
                                                    hideGroup(regionID);
                                                }.bind(this)
                                            }
                                }).inject(el);
        bt2.innerHTML = '<?php echo JText::_('Close all')?>';
    })


</script>

<?php
/* Check info.php file */
$file = JPATH_SITE.DS.'templates'.DS.$template.DS.'info'.DS.'info.php';
if (file_exists($file)) {?>
    <fieldset class="adminform" id="additional_information" style="display: none">
        <?php include_once $file;?>
    </fieldset>
<?php }?>

<?php if ($helpurl != '') {?>
<a rel="{handler: 'iframe', size: {x: 930, y: 510} }" href="<?php echo $helpurl?>" class="modal toolbar" id="ja-introduce">
    <span title="<?php echo JText::_('Help')?>" class="icon-32-help"></span>
    <?php echo JText::_('Help')?>
</a>
<?php }?>
<div id="jat3-help-content-wrap">
    <div class="center-bottom">
        <div class="top1"><div class="top2"><div class="top3"><div class="top4"></div></div></div></div>
        <div class="mid1"><div class="mid2"><div class="mid3"><div class="tool-text-content"><div class="tool-text"></div></div></div></div></div>
        <div class="bot1"><div class="bot2"><div class="bot3"><div class="bot4"></div></div></div></div>
    </div>
</div>
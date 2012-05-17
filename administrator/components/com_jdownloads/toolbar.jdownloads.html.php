<?php
/**
* @version 1.5
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*
*/

defined( '_JEXEC' ) or die( 'Restricted access' );

class menujlist {
    function _DEFAULT(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_MAIN'), 'jdlogo' ); 
    }

	function EDIT_MENU(){ 
		JToolBarHelper::title( JText::_(''), 'jdlogo' ); 
        JToolBarHelper::save();
		JToolBarHelper::cancel();
	}

	function SETTINGS_MENU(){ 
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_SETTINGS'), 'jdlogo' ); 
        JToolBarHelper::save('config.save');
        JToolBarHelper::apply('config.apply');
        if (JFactory::getUser()->authorise('core.admin', 'com_jdownloads')) {
            JToolBarHelper::divider(); 
            JToolBarHelper::preferences('com_jdownloads');
            JToolBarHelper::divider(); 
        }
		JToolBarHelper::cancel('',JText::_('COM_JDOWNLOADS_BACKEND_TOOLBAR_CLOSE'));
	}

	function CATEGORIES_LIST(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_CATEGORIES'), 'jdlogo' ); 
        JToolBarHelper::addNewX('categories.edit');
		JToolBarHelper::publish('categories.publish');
		JToolBarHelper::unpublish('categories.unpublish');
		JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_CATSLIST_DEL_QUEST'),'categories.delete');
	}

	function CATEGORIES_ADD(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CATSEDIT_TITLE'), 'jdlogo' ); 
        JToolBarHelper::save('categories.save');
        JToolBarHelper::apply('categories.apply');
		JToolBarHelper::cancel('categories.cancel');
	}

	function FILES_LIST(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_FILES'), 'jdlogo' ); 
        JToolBarHelper::custom( 'files.upload', 'upload32.png', 'upload32.png', JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_TITLE_FILES_UPLOAD'), false, true ); 
        JToolBarHelper::custom( 'manage.files', 'files32.png', 'files32.png', JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_TITLE_MANAGE_FILES'), false, false );
        JToolBarHelper::divider();
        JToolBarHelper::addNewX('files.edit');
        JToolBarHelper::custom( 'files.move', 'move.png', 'move_f2.png', 'Move', false ); 
        JToolBarHelper::custom( 'files.copy', 'copy.png', 'copy_f2.png', 'Copy', false );     
		JToolBarHelper::publish('files.publish');
		JToolBarHelper::unpublish('files.unpublish');
		JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_DEL_QUEST'),'files.delete');
	}

	function FILES_EDIT(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_FILESEDIT_TITLE'), 'jdlogo' ); 
        JToolBarHelper::save('files.save');
		JToolBarHelper::apply('files.apply');
		JToolBarHelper::cancel('files.cancel');
	}
    
    function FILES_MOVE(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_FILES_MOVE_TITLE'), 'jdlogo' );
        JToolBarHelper::save('files.move.save');
        JToolBarHelper::cancel('files.list');
    }     
    
    function FILES_COPY(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_FILES_COPY_TITLE'), 'jdlogo' ); 
        JToolBarHelper::save('files.copy.save');
        JToolBarHelper::cancel('files.list'); 
    }

    function FILES_UPLOAD(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_TITLE_FILES_UPLOAD'), 'jdlogo' ); 
        JToolBarHelper::custom( 'manage.files', 'files32.png', 'files32.png', JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_TITLE_MANAGE_FILES'), false, false );
        JToolBarHelper::custom( 'files.list', 'downloads_2.png', 'downloads_2.png', JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_FILES'), false, false );
        JToolBarHelper::cancel('',JText::_('COM_JDOWNLOADS_BACKEND_TOOLBAR_CLOSE'));
    }
    
    function MANAGE_FILES(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_TITLE_MANAGE_FILES'), 'jdlogo' ); 
        JToolBarHelper::custom( 'files.upload', 'upload32.png', 'upload32.png', JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_TITLE_FILES_UPLOAD'), false, true );
        JToolBarHelper::custom( 'files.list', 'downloads_2.png', 'downloads_2.png', JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_FILES'), false, false );
        JToolBarHelper::divider();
        JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_FILESLIST_DEL_QUEST_FILES'),'delete.root.files');
    }    
       
    function LICENSE_LIST(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_LICENSE'), 'jdlogo' ); 
        JToolBarHelper::addNew('license.edit');
		JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_LICLIST_DEL_QUEST'),'license.delete');
	}

	function LICENSE_EDIT(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_LICEDIT_TITLE'), 'jdlogo' );
        JToolBarHelper::save('license.save');
		JToolBarHelper::cancel('license.cancel');
    }
    
	function TEMPLATES_MENU(){
	    JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_TEMPLATES_NAME'), 'jdlogo' ); 
    }

    function TEMPLATES_LIST_CATS(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_CATTITLE_HEAD'), 'jdlogo' );
        JToolBarHelper::custom( 'templates.list.files', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_FILESTITLE_HEAD'), false );
        JToolBarHelper::custom( 'templates.list.details', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DETAILSTITLE_HEAD'), false );
        JToolBarHelper::custom( 'templates.list.summary', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_SUMTITLE_HEAD'), false );
        JToolBarHelper::divider();
        JToolBarHelper::custom( 'templates.active.cats', 'apply.png', 'apply_f2.png', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_MENU_TEXT_ACTIVE'), true );
		JToolBarHelper::addNew('templates.edit.cats');
		JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DEL_QUEST'),'templates.delete.cats');
	}

	function TEMPLATES_EDIT_CATS(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPEDIT_CATTITLE'), 'jdlogo' ); 
        JToolBarHelper::save('templates.save.cats');
		JToolBarHelper::apply('templates.apply.cats');
		JToolBarHelper::cancel('templates.cancel.cats');
    }

    function TEMPLATES_LIST_FILES(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_FILESTITLE_HEAD'), 'jdlogo' );
        JToolBarHelper::custom( 'templates.list.cats', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_CATTITLE_HEAD'), false );
        JToolBarHelper::custom( 'templates.list.details', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DETAILSTITLE_HEAD'), false );
        JToolBarHelper::custom( 'templates.list.summary', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_SUMTITLE_HEAD'), false );
        JToolBarHelper::divider(); 
        JToolBarHelper::custom( 'templates.active.files', 'apply.png', 'apply_f2.png', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_MENU_TEXT_ACTIVE'), true );
		JToolBarHelper::addNew('templates.edit.files');
		JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DEL'),'templates.delete.files');
	}

	function TEMPLATES_EDIT_FILES(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPEDIT_FILESTITLE'), 'jdlogo' ); 
        JToolBarHelper::save('templates.save.files');
		JToolBarHelper::apply('templates.apply.files');
		JToolBarHelper::cancel('templates.cancel.files');
    }
    
    function TEMPLATES_LIST_DETAILS(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DETAILSTITLE_HEAD'), 'jdlogo' );
        JToolBarHelper::custom( 'templates.list.cats', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_CATTITLE_HEAD'), false );
        JToolBarHelper::custom( 'templates.list.files', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_FILESTITLE_HEAD'), false );        
        JToolBarHelper::custom( 'templates.list.summary', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_SUMTITLE_HEAD'), false );
        JToolBarHelper::divider(); 
        JToolBarHelper::custom( 'templates.active.details', 'apply.png', 'apply_f2.png', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_MENU_TEXT_ACTIVE'), true );
        JToolBarHelper::addNew('templates.edit.details');
        JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DEL'),'templates.delete.details');
    }

    function TEMPLATES_EDIT_DETAILS(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPEDIT_DETAILSTITLE'), 'jdlogo' ); 
        JToolBarHelper::save('templates.save.details');
        JToolBarHelper::apply('templates.apply.details');
        JToolBarHelper::cancel('templates.cancel.details');
    }    

    function TEMPLATES_LIST_SUMMARY(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_SUMTITLE_HEAD'), 'jdlogo' );
        JToolBarHelper::custom( 'templates.list.cats', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_CATTITLE_HEAD'), false );
        JToolBarHelper::custom( 'templates.list.files', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_FILESTITLE_HEAD'), false );  
        JToolBarHelper::custom( 'templates.list.details', 'template', 'template', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DETAILSTITLE_HEAD'), false ); 
        JToolBarHelper::divider();         
        JToolBarHelper::custom( 'templates.active.summary', 'apply.png', 'apply_f2.png', JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_MENU_TEXT_ACTIVE'), true );
		JToolBarHelper::addNew('templates.edit.summary');
		JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_TEMPLIST_DEL'),'templates.delete.summary');
	}

	function TEMPLATES_EDIT_SUMMARY(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_TEMPEDIT_SUMTITLE'), 'jdlogo' ); 
        JToolBarHelper::save('templates.save.summary');
		JToolBarHelper::apply('templates.apply.summary');
		JToolBarHelper::cancel('templates.cancel.summary');
    }
    
 	function CSS_EDIT(){
		JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_EDIT_CSS_TITLE_EDIT'), 'jdlogo' ); 
        JToolBarHelper::save('css.save');
		JToolBarHelper::cancel('templates.menu');
    }
    
	function LANG_EDIT(){
		JToolBarHelper::title( JText::_(''), 'jdlogo' ); 
        JToolBarHelper::save('language.save');
		JToolBarHelper::cancel('');
    }

	function RESTORE_MENU(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_RESTORE'), 'jdlogo' ); 
	}
    
    function LIST_LOGS(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_DOWNLOAD_LOGS'), 'jdlogo' ); 
        JToolBarHelper::custom( 'add.ip', 'cancel.png', 'cancel.png', JText::_('COM_JDOWNLOADS_BACKEND_LOG_LIST_BLOCK_IP'), true );
        JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_VIEW_LOGS_DEL_QUEST'),'delete.logs');
    } 
    
    function LIST_GROUPS(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_GROUPS'), 'jdlogo' ); 
        JToolBarHelper::addNewX('edit.groups');
        JToolBarHelper::deleteList(JText::_('COM_JDOWNLOADS_BACKEND_VIEW_GROUPS_DEL_QUEST'),'delete.groups');
    } 
    
    function EDIT_GROUPS(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_GROUPS_EDIT_TITLE'), 'jdlogo' ); 
        JToolBarHelper::save('save.groups');
        JToolBarHelper::apply('apply.groups');
        JToolBarHelper::cancel('cancel.groups');
    }       
	
	function INFO_MENU(){
        JToolBarHelper::title( JText::_('COM_JDOWNLOADS_BACKEND_CPANEL_INFO'), 'jdlogo' ); 
	}
    
}

?>
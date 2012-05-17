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
require_once( JPATH_COMPONENT.DS.'toolbar.jdownloads.html.php' );

switch ( $task ) {

		case "new":
		case "edit":
		case "editA":
		case "copy":
		menujlist::EDIT_MENU();
		break;

		case "categories.list":
			menujlist::CATEGORIES_LIST();
		break;

		case "categories.edit":
			menujlist::CATEGORIES_ADD();
		break;

		case "files.list":
			menujlist::FILES_LIST();
		break;

		case "files.edit":
			menujlist::FILES_EDIT();
		break;

        case "files.copy":
            menujlist::FILES_COPY();
        break;

        case "files.move":
            menujlist::FILES_MOVE();
        break;
        
        case "license.list":
			menujlist::LICENSE_LIST();
		break;

		case "license.edit":
			menujlist::LICENSE_EDIT();
		break;

        case "templates.menu":
			menujlist::TEMPLATES_MENU();
		break;
		
        case "templates.list.cats":
			menujlist::TEMPLATES_LIST_CATS();
		break;

		case "templates.edit.cats":
			menujlist::TEMPLATES_EDIT_CATS();
		break;

        case "templates.list.files":
			menujlist::TEMPLATES_LIST_FILES();
		break;

		case "templates.edit.files":
			menujlist::TEMPLATES_EDIT_FILES();
		break;
        
        case "templates.list.details":
            menujlist::TEMPLATES_LIST_DETAILS();
        break;

        case "templates.edit.details":
            menujlist::TEMPLATES_EDIT_DETAILS();
        break;        

        case "templates.list.summary":
			menujlist::TEMPLATES_LIST_SUMMARY();
		break;

		case "templates.edit.summary":
			menujlist::TEMPLATES_EDIT_SUMMARY();
		break;
		
        case "css.edit":
    	menujlist::CSS_EDIT();
    	break;

        case "language.edit":
    	menujlist::LANG_EDIT();
    	break;

		case "config.show":
    	menujlist::SETTINGS_MENU();
    	break;

		case "restore":
    	menujlist::RESTORE_MENU();
    	break;

 		case "info":
    	menujlist::INFO_MENU();
    	break;
        
        case "view.logs":
        menujlist::LIST_LOGS();
        break;        

        case "view.groups":
        menujlist::LIST_GROUPS();
        break;
        
        case "edit.groups":
        menujlist::EDIT_GROUPS();
        break;

        case "files.upload":
        menujlist::FILES_UPLOAD();
        break;
        
        case "manage.files":
        menujlist::MANAGE_FILES();
        break;

        case "add.ip":
        menujlist::ADD_IP();
        break;
                
		default:
		menujlist::_DEFAULT();
		break;
        
	}
?>
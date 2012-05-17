<?php
/**
* @version 1.5
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*/

defined( '_JEXEC' ) or die( 'Restricted access-class' );



class jlist_config extends JTable{
	var $id = null;
	var $setting_name = null;
	var $setting_value = null;

	function jlist_config(&$db){
		parent::__construct('#__jdownloads_config', 'id', $db);
	}

}

class jlist_cats extends JTable{
	var $cat_id = null;
	var $cat_dir = null;
	var $parent_id = null;
	var $cat_title = null;
    var $cat_alias = null;
	var $cat_description = null;
	var $cat_pic = null;
	var $cat_access = null;
    var $cat_group_access = null;
    var $metakey = null;
    var $metadesc = null;
	var $jaccess = null;
    var $jlanguage = null;
    var $ordering = null;
	var $published = null;
	var $checked_out = null;
	var $checked_out_time = null;
    
	function jlist_cats(&$db){
		parent::__construct('#__jdownloads_cats', 'cat_id', $db);
	}

}

class jlist_files extends JTable{
	var $file_id = null;
	var $file_title = null;
    var $file_alias = null;
	var $description = null;
	var $description_long = null;
	var $file_pic = null;
    var $thumbnail = null;
    var $thumbnail2 = null;
    var $thumbnail3 = null;
    var $price = null;
	var $release = null;
    var $language = null;
    var $system = null;
	var $license = null;
	var $url_license = null;
    var $license_agree = null;
	var $update_active = null;
    var $cat_id = null;
    var $metakey = null;
    var $metadesc = null;
	var $size = null;
	var $date_added = null;
    var $file_date = null;
    var $publish_from = null;
    var $publish_to = null;
    var $use_timeframe = null;
	var $url_download = null;
    var $extern_file = null;
    var $extern_site = null;
    var $mirror_1 = null;
    var $mirror_2 = null;
    var $extern_site_mirror_1 = null;	
    var $extern_site_mirror_2 = null;
    var $url_home = null;
	var $author = null;
	var $url_author = null;
	var $created_by = null;
    var $created_id = null;
	var $created_mail = null;
	var $modified_by = null;
    var $modified_id = null;
  	var $modified_date = null;
    var $submitted_by = null;
    var $set_aup_points = null;    		
	var $downloads = null;
    var $custom_field_1 = null;
	var $custom_field_2 = null;
    var $custom_field_3 = null;
    var $custom_field_4 = null;
    var $custom_field_5 = null;
    var $custom_field_6 = null;
    var $custom_field_7 = null;
    var $custom_field_8 = null;
    var $custom_field_9 = null;
    var $custom_field_10 = null;
    var $custom_field_11 = null;
    var $custom_field_12 = null;
    var $custom_field_13 = null;
    var $custom_field_14 = null;
    var $jaccess = null;
    var $jlanguage = null;
    var $ordering = null;
	var $published = null;
	var $checked_out = null;
	var $checked_out_time = null;

	function jlist_files(&$db){
		parent::__construct('#__jdownloads_files', 'file_id', $db);
	}

}

class jlist_license extends JTable{
	var $id = null;
	var $license_title = null;
	var $license_text = null;
	var $license_url = null;
    var $jlanguage = null;
	var $checked_out = null;
	var $checked_out_time = null;
	
	function jlist_license(&$db){
		parent::__construct('#__jdownloads_license', 'id', $db);
	}
}

class jlist_templates extends JTable{
	var $id = null;
	var $template_name = null;
	var $template_typ = null;
	var $template_header_text = null;
    var $template_subheader_text = null;
    var $template_footer_text = null;
    var $template_text = null;
	var $template_active = null;
	var $locked = null;
    var $note = null;
    var $cols = null;
    var $checkbox_off = null;
    var $symbol_off = null;
    var $jlanguage = null;	
    var $checked_out = null;
	var $checked_out_time = null;
	
	function jlist_templates(&$db){
		parent::__construct('#__jdownloads_templates', 'id', $db);
	}
}

class jlist_groups extends JTable{
    var $id = null;
    var $groups_name = null;
    var $groups_description = null;
    var $groups_access = null;
    var $groups_members = null;
    var $jlanguage = null;
    
    function jlist_groups(&$db){
        parent::__construct('#__jdownloads_groups', 'id', $db);
    }
}

class jlist_log extends JTable{
    var $id = null;
    var $log_file_id = null;
    var $log_ip = null;
    var $log_datetime = null;
    var $log_user = null;
    var $log_browser = null;
    var $jlanguage = null;
    
    function jlist_log(&$db){
        parent::__construct('#__jdownloads_log', 'id', $db);
    }
}

class jlist_rating extends JTable{
    var $file_id = null;
    var $rating_sum = null;
    var $rating_count = null;
    var $lastip = null;
    var $jlanguage = null;
   
    function jlist_rating(&$db){
        parent::__construct('#__jdownloads_rating', 'file_id', $db);
    }
}

/** SS_ZIP class is designed to work with ZIP archives
@author Yuriy Horobey, smiledsoft.com
@email info@smiledsoft.com
*/
class ss_zip{
	/** contains whole zipfile
	@see ss_zip::archive()
	@see ss_zip::ss_zip()
	*/
	var $zipfile="";
	/** compression level	*/
	var $complevel=6;
	/** entry counter */
	var $cnt=0;
	/** current offset in zipdata segment */
	var $offset=0;
	/** index of current entry
		@see ss_zip::read()
	*/
	var $idx=0;
	/**
	ZipData segment, each element of this array contains local file header plus zipped data
	*/
	var $zipdata=array();
	/**	central directory array	*/
	var $cdir=array();
	/**	constructor
	@param string zipfile if not empty must contain path to valid zip file, ss_zip will try to open and parse it.
	If this parameter is empty, the new empty zip archive is created. This parameter has no meaning in LIGHT verion, please upgrade to PROfessional version.
	@param int complevel compression level, 1-minimal compression, 9-maximal, default is 6
	*/
	function ss_zip($zipfile="",$complevel=6){
		$this->clear();
		if($complevel<1)$complevel=1;
		if($complevel>9)$complevel=9;
		$this->complevel=$complevel;
		$this->open($zipfile);
	}

	/**Resets the objec, clears all the structures
	*/
	function clear(){
		$this->zipfile="";
		$this->complevel=6;
		$this->cnt=0;
		$this->offset=0;
		$this->idx=0;
		$this->zipdata=array();
		$this->cdir=array();
	}
		/**opens zip file.
		<center><hr nashade>*** This functionality is available in PRO version only. ***<br><a href='http://smiledsoft.com/demos/phpzip/' target='_blank'>please upgrade </a><hr nashade></center>
	This function opens file pointed by zipfile parameter and creates all necessary structures
	@param str zipfile path to the file
	@param bool append if true the newlly opened archive will be appended to existing object structure
	*/
	function open($zipfile, $append=false){}


	/**saves to the disc or sends zipfile to the browser.
	@param str zipfile path under which to store the file on the server or file name under which the browser will receive it.
	If you are saving to the server, you are responsible to obtain appropriate write permissions for this operation.
	@param char where indicates where should the file be sent
	<ul>
	<li>'f' -- filesystem </li>
	<li>'b' -- browser</li>
	</ul>
	Please remember that there should not be any other output before you call this function. The only exception is
	that other headers may be sent. See <a href='http://php.net/header' target='_blank'>http://php.net/header</a>
	*/
	function save($zipfile, $where='f'){
		if(!$this->zipfile)$this->archive();
		$zipfile=trim($zipfile);

		if(strtolower(trim($where))=='f'){
			 $this->_write($zipfile,$this->zipfile);
		}else{
			$zipfile = basename($zipfile);
			header("Content-type: application/octet-stream");
			header("Content-disposition: attachment; filename=\"$zipfile\"");
			print $this->archive();
		}
	}

	/** adds data to zip file
	@param str filename path under which the content of data parameter will be stored into the zip archive
	@param str data content to be stored under name given by path parameter
	@see ss_zip::add_file()
	*/
	function add_data($filename,$data=null){

		$filename=trim($filename);
		$filename=str_replace('\\', '/', $filename);
		if($filename[0]=='/') $filename=substr($filename,1);

		if( ($attr=(($datasize = strlen($data))?32:16))==32 ){
			$crc	=	crc32($data);
			$gzdata = gzdeflate($data,$this->complevel);
			$gzsize	=	strlen($gzdata);
			$dir=dirname($filename);
//			if($dir!=".") $this->add_data("$dir/");
		}else{
			$crc	=	0;
			$gzdata = 	"";
			$gzsize	=	0;

		}
		$fnl=strlen($filename);
        $fh = "\x14\x00";    // ver needed to extract
        $fh .= "\x00\x00";    // gen purpose bit flag
        $fh .= "\x08\x00";    // compression method
        $fh .= "\x00\x00\x00\x00"; // last mod time and date
		$fh .=pack("V3v2",
			$crc, //crc
			$gzsize,//c size
			$datasize,//unc size
			$fnl, //fname lenght
			0 //extra field length
		);


		//local file header
		$lfh="PK\x03\x04";
		$lfh .= $fh.$filename;
		$zipdata = $lfh;
		$zipdata .= $gzdata;
		$zipdata .= pack("V3",$crc,$gzsize,$datasize);
		$this->zipdata[]=$zipdata;
		//Central Directory Record
		$cdir="PK\x01\x02";
		$cdir.=pack("va*v3V2",
		0,
		$fh,
    	0, 		// file comment length
    	0,		// disk number start
    	0,		// internal file attributes
    	$attr,	// external file attributes - 'archive/directory' bit set
		$this->offset
		).$filename;

		$this->offset+= 42+$fnl+$gzsize;
		$this->cdir[]=$cdir;
		$this->cnt++;
		$this->idx = $this->cnt-1;
	}
	/** adds a file to the archive
	@param str filename contains valid path to file to be stored in the arcive.
	@param str storedasname the path under which the file will be stored to the archive. If empty, the file will be stored under path given by filename parameter
	@see ss_zip::add_data()
	*/
	function add_file($filename, $storedasname=""){
		$fh= fopen($filename,"r");
		$data=fread($fh,filesize($filename));
		if(!trim($storedasname))$storedasname=$filename;
		return $this->add_data($storedasname, $data);
	}
	/** compile the arcive.
	This function produces ZIP archive and returns it.
	@return str string with zipfile
	*/
	function archive(){
		if(!$this->zipdata) return "";
		$zds=implode('',$this->zipdata);
		$cds=implode('',$this->cdir);
		$zdsl=strlen($zds);
		$cdsl=strlen($cds);
		$this->zipfile=
			$zds
			.$cds
			."PK\x05\x06\x00\x00\x00\x00"
	        .pack('v2V2v'
        	,$this->cnt			// total # of entries "on this disk"
        	,$this->cnt			// total # of entries overall
        	,$cdsl					// size of central dir
        	,$zdsl					// offset to start of central dir
        	,0);							// .zip file comment length
		return $this->zipfile;
	}
	/** changes pointer to current entry.
	Most likely you will always use it to 'rewind' the archive and then using read()
	Checks for bopundaries, so will not allow index to be set to values < 0 ro > last element
	@param int idx the new index to which you want to rewind the archive curent pointer
	@return int idx the index to which the curent pointer was actually set
	@see ss_zip::read()
	*/
	function seek_idx($idx){
		if($idx<0)$idx=0;
		if($idx>=$this->cnt)$idx=$this->cnt-1;
		$this->idx=$idx;
		return $idx;
	}
	
	function read(){}
    	
	function remove($idx){}
    	
	function extract_data($idx){}

    function extract_file($idx,$path="."){}
    
	function _check_idx($idx){
		return $idx>=0 and $idx<$this->cnt;
	}
	function _write($name,$data){
		$fp=fopen($name,"w");
		fwrite($fp,$data);
		fclose($fp);
	}
}

?>
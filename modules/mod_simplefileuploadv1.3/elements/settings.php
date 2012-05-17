<?php

/**
* @version		1.3
* @copyright	Copyright (C) 2010 Anders Wasén
* @license		GNU/GPL
*/

// Check to ensure this file is included in Joomla!
defined('_JEXEC') or die();

?>

<script language="javascript" type="text/javascript">


function moveUDDuser() {
	var ol = document.getElementById('jformparamssettingidsuddsel');

	var os = ol.selectedIndex;
	if (os < 0) {
		alert('You have to select a user from the list first.');
		return false;
	}
	var userid = ol.options[os].text;
	
	var path = prompt('Give the path for the user defined directory for ' + userid + '.');
	
	var oli = document.getElementById('jformparamssettingidsudd');
	
	var val = userid + '>' + path;
	
	addOption(oli, val, val);
	
	var i = 0;
	var n = ol.options.length;
	for (i = 0; i < n; i++) {
		//oli.options[i].disabled = true;
		ol.options[i].selected = false;
	}
	
	selectAll(oli);
	
}

function selectAll(oe) {
	var i = 0;
	var n = oe.options.length;
	for (i = 1; i < n; i++) {
		//oli.options[i].disabled = true;
		oe.options[i].selected = true;
	}
}

function removeUDDuser() {
	var ol = document.getElementById('jformparamssettingidsudd');

	var os = ol.selectedIndex;
	if (os < 0) {
		alert('You have to select a user from the list first.');
		return false;
	}
	
	var ret = confirm('Are you sure you want to remove the user defined path for ' +ol.options[os].text + '?');
	
	if (ret) {
		deleteOption(ol, os);
	}
	
	selectAll(ol);
}

function addOption(theSel, theText, theValue)
{
  var newOpt = new Option(theText, theValue);
  var selLength = theSel.length;
  theSel.options[selLength] = newOpt;
}

function deleteOption(theSel, theIndex)
{ 
  var selLength = theSel.length;
  if(selLength>0)
  {
    theSel.options[theIndex] = null;
  }
}

//Make sure paths list is all selected!
var oapply = document.getElementById("toolbar-apply");
oapply.onmousedown = function() {
	selectAll(document.getElementById('jformparamssettingidsudd'));
}
var osave = document.getElementById("toolbar-save");
osave.onmousedown = function() {
	selectAll(document.getElementById('jformparamssettingidsudd'));
}

function resetList(oel) {
	if (!confirm("Are you sure you want to clear the list?")) return false;
	var obj = document.getElementById(oel);
	for (var i=0; i < obj.options.length; i++) {
		obj.options[i].selected = null;
	}
}

function restoreSFUSettings(go) {
	
	var txt = document.getElementById("sfuRestoreText").value;
	
	if (go == "cancel") {
		var close = true;
		if (txt.length > 0) {
			if (!confirm("Are you sure you want to cancel the restore operation?")) close = false;
		}
		if (close) {
			document.getElementById("sfuRestoreText").value = "";
			document.getElementById("sfuRestoreCode").style.display = "none";
			return false;
		}
	} else {
		if (txt.length == 0) {
			alert("You must enter the restore text into the text-box to restore your settings.")
			return false;
		}
	}
	
	txt = txt.replace(/\s+$/g,"");
	var lines = txt.split("\r\n");
	if (lines.length == 1)
		var lines = txt.split("\n");

	var arLen=lines.length;
	if (arLen < 34) {
		alert("There should be more than 35 lines and there must be a line-break after each line in the restore text. Please check your text and try again.");
		return false;
	}
	
	var val = null;
	var oel = null;
	var usr = "|";
	var usrn = "|";
	var chk = null;
	
	for ( var i=0, len=arLen; i<len; ++i ){
		init = lines[i].substr(0, 7);
		val = lines[i].split("=");
		// Make sure there always is an equalsign
		if (val.length != 2) {
			init = "";
		} else {
			oel = document.getElementById("params" + val[0]);
			if (typeof oel == "undefined" || oel == null) {
				// Try for a radiobutton
				oel = document.getElementById("params" + val[0] + val[1]);
				if (typeof oel=="undefined") {
					// If still not found fail it... :(
					init = "";
				}
			}
		}
		
		if(init == "upload_") {
			
			if (oel.type == "text") {
				oel.value = val[1];
			} else if (oel.type == "radio") {
				oel.checked = "checked";
			} else {
				alert("ERROR: Empty or corrupted line found [" + lines[i] + "]. Refresh the page WITHOUT saving your changes!");
				return false;
			}
			
		} else if (init == "setting") {
			
			if (oel.type == "select-multiple") {
				
				// Loop through list and collect usernames in system at the same time:
				if (oel.id == "paramssettingids") {
					for(var j = 0; j < oel.options.length; ++j) {
						usr += oel.options[j].value + "|";
						usrn += oel.options[j].text + "|";
					}
				}
				
				chk = val[1].split("|");
				if (oel.id == "paramssettingids" || oel.id == "paramssettingidsund") {	
					// settingids=62|63
					// settingidsund=62|63
				
					for(var j = 0; j < chk.length; ++j) {
						var srch = "|" + chk[j] + "|";
						if (usr.indexOf(srch) > -1) {
					
							for(var k = 0; k < oel.options.length; ++k) {
								if (chk[j] == oel.options[k].value) {
									oel.options[k].selected="selected";
								}
							}
							
						} else {
							alert("User with ID " + chk[j] + " was not found in this system and will be omitted.");
						}
					}
				
				} else if (oel.id == "paramssettingidsuddpath") {
					// settingidsuddpath=Tester1>./tmp/test|admin>/tmp/admin
					
					// Remove all old from list
					selectAll(oel);
					for (j = oel.length - 1; j>=0; j--) {
						if (oel.options[j].selected) {
							oel.remove(j);
						}
					}
					
					for(var j = 0; j < chk.length; ++j) {
					
						var srch = chk[j].split(">");
						
						if (srch.length != 2) {
							alert("setting with value " + chk[j] + " was not found to match this system and will be omitted.");
						} else {
							
							if (usrn.indexOf("|" + srch[0] + "|") > -1) {
						
								addOption(oel, chk[j], chk[j])
								
							} else {
								alert("User with ID " + chk[j] + " was not found in this system and will be omitted.");
							}
						}
					}
				
				}
				
			} else {
				alert("ERROR: Empty or corrupted line found [" + lines[i] + "]. Refresh the page WITHOUT saving your changes!");
				return false;
			}
			
		} else if (init == "modulec") {
			
			if (oel.type == "text") {
				oel.value = val[1];
			} else {
				alert("ERROR: Empty or corrupted line found [" + lines[i] + "]. Refresh the page WITHOUT saving your changes!");
				return false;
			}
			
		} else {
			alert("ERROR: Empty or corrupted line found [" + lines[i] + "]. Refresh the page WITHOUT saving your changes!");
			return false;
		}
	}
	alert("The restore procedure is completed. Remeber to verify and save your settings! The restored settings will NOT take affect until you save it!");

	document.getElementById("sfuRestoreCode").style.display = "none";
	
}

</script>

<?php

jimport('joomla.form.helper');
JFormHelper::loadFieldClass('MySettings');
 
class JFormFieldSettings extends JFormFieldMySettings {
 
	protected $type = 'Settings';
	
	//function fetchElement($name, $value, &$node, $control_name)
	protected function getInput()
	{
		$db = &JFactory::getDBO();
//echo "name=$name, value=".print_r($value).", control_name=$control_name";

		// Get Module ID
		$mid = JRequest::getVar('id');
		if (strlen($mid) == 0) {
			$mid = JRequest::getVar('cid');
			if (is_array($mid)) $mid = $mid[0];
		}
		
		$name = (string)$this->element['name'];
		$control_name = 'jform[params]';
		$control_name_basic = 'jformparams';
		if (is_array($this->value))
			$value = $this->value;
		else	
			$value 	= (string)$this->value;

		
		$query = 'SELECT id AS value, username AS text'
 		. ' FROM #__users'
 		. ' WHERE block=0 ORDER BY name';

		$db->setQuery($query);
		$optionsAll[] = JHTML::_('select.option', "[ALL]", "[ALL]");
		$optionsDB = $db->loadObjectList();
		
		$options = array_merge($optionsAll, $optionsDB);
//echo $name;
		if ($name === "settingidsudd" ) {
			$slist = '';
			$slist = JHTML::_('select.genericlist',  $optionsDB, 'jform[params][settingidsuddsel][]', 
				'class="inputbox" size="12"',
				'value', 'text', $value, 'jformparamssettingidsuddsel');
		//test
			$optionsPath[] = JHTML::_('select.option', '0', '[user defined directory paths]');
			
			// Get DB settings
			$udddblist = getBaseSettings($db, $mid);

			// Get rid of double quotes
			$udddblist = str_replace("\"", "", $udddblist);
			// Fix front-slashes
			$udddblist = str_replace("\/", "/", $udddblist);

			$tmp = "";
			$bracket = false;
			$uddlist = "";

			for ($i=0; $i<strlen($udddblist); $i++) {
				// There must be a smarter way to do this... but...
				$tmp = substr($udddblist, $i, 1);
				
				if ($tmp === "[") {
					$bracket = true;
					$tmp = "";
				}
				if ($tmp === "]") {
					$bracket = false;
					$tmp = "";
				}
				
				if ($bracket && $tmp === ",")
					$tmp = ";";
					
				$uddlist .= $tmp;
			}


//echo "uddlist=".$uddlist;

			$uddlist = explode(',', $uddlist);
		
			$optionsAddPath = '';
			foreach($uddlist as $val){

// "settingidsudd":["Anders>aaaa","Super User>super"]  should be cleaded as: settingidsudd:Anders>aaaa;Super User>super

			    if (substr($val, 0, 14) === 'settingidsudd:') {

					$val = str_replace('settingidsudd:', '', $val);
					//$val = str_replace('"]', '', $val);

					//echo $value.'&';

					$uddsellist = explode(";", $val);
					foreach($uddsellist as $listval) {
						if ($listval != '0') {
						$optionsAddPath[] = JHTML::_('select.option', $listval, $listval);
						}
					}
					
				}
			}
			
			if (is_array($optionsAddPath)) {
				$optionsPath = array_merge($optionsPath, $optionsAddPath);
			}
			
			$slistpath = '';
			/*$slistpath = JHTML::_('select.genericlist', $optionsPath, 'params[settingidsuddpath][]', 
				'class="inputbox" size="12" multiple="multiple"',
				'value', 'text', $value, 'paramssettingidsuddpath');
			*/
			$slistpath = JHTML::_('select.genericlist', $optionsPath, 'jform[params][settingidsudd][]', 
				'class="inputbox" size="12" multiple="multiple"',
				'value', 'text', $value, 'jformparamssettingidsudd');
			
			return setUDDhtml($slist, $slistpath);
			

		} elseif ($name === "settingidsund" || $name === "settingids") {

			$slistpath = '';
			/*$slistpath = JHTML::_('select.genericlist',  $options, ''.$control_name.'['.$name.'][]', 
				'class="inputbox" size="12" multiple="multiple"',
				'value', 'text', $value, $control_name.$name);
			*/
			$slistpath = JHTML::_('select.genericlist',  $options, ''.$control_name.'['.$name.'][]', 
				'class="inputbox" size="12" multiple="multiple"',
				'value', 'text', $value, $control_name_basic.$name);
			return setListResetBtn($name, $slistpath);
			
		} elseif ($name === "settingbackup") {
		
			$sin = "";
			$dblist = getBaseSettings($db, $mid);
			
			$uddlist = explode(chr(10), $dblist);
			
			foreach($uddlist as $value){
				$sin .= $value."\r";
			}

			return setBackuphtml($sin);
		}
	}

}

function setBackuphtml($sin) {
	$shtml = '';
	
	$shtml .= '<div class="clr"></div><span><input type="button" value="Backup" onclick="javascript: document.getElementById(\'sfuBackupCode\').style.display = \'block\';" />&nbsp;&nbsp;<input type="button" value="Restore" onclick="javascript: document.getElementById(\'sfuRestoreCode\').style.display = \'block\';" /></span>';
	$shtml .= '<div id="sfuBackupCode" style="background-color: #dfdfdf; position: relative; border: 3px outset white; left: -80px; top: -300px; height: 300px; width: 400px; overflow: hidden; z-index: 999; display: none;"><b>Copy the below text into a text-document and save it on your computer (Use right-click menu or Ctrl+A selects all text, Ctrl+C copies it):</b><br/><br/><textarea style="height: 220px; width: 396px;">' . $sin . '</textarea><br/><input type="button" value="Close..." onclick="javascript: document.getElementById(\'sfuBackupCode\').style.display = \'none\';" /></div>';
	$shtml .= '<div id="sfuRestoreCode" style="background-color: #dfdfdf; position: relative; border: 3px outset white; left: -80px; top: -300px; height: 300px; width: 400px; overflow: hidden; z-index: 999; display: none;"><b>Paste the backup text into the text-box below and click the [Restore] button:</b><br/><br/><textarea id="sfuRestoreText" style="height: 220px; width: 396px;"></textarea><br/><input type="button" value="Close..." onclick="javascript: restoreSFUSettings(\'cancel\');" />&nbsp;&nbsp;<input type="button" value="Restore" onclick="javascript: restoreSFUSettings(\'\');" /></div>';
	
	return $shtml;
}

function setUDDhtml($sin, $sin2) {
	$shtml = '';

	//$shtml .= '<table border=0><tr><td>';
	$shtml .= $sin;
	//$shtml .= '</td><td><input type="button" value=">>" onclick="javascript: moveUDDuser();"/><br /><input type="button" value="<<" onclick="javascript: removeUDDuser();" /></td><td>';
	$shtml .= '<input type="button" value=">>" onclick="javascript: moveUDDuser();"/><input type="button" value="<<" onclick="javascript: removeUDDuser();" />';
	$shtml .= $sin2;
	//$shtml .= '</td></tr></table>';
	
	return $shtml;
}

function setListResetBtn($name, $sin) {
	$shtml = '';
	//$shtml .= '<table border=0><tr><td>';
	$shtml .= $sin;
	$shtml .= '<input type="button" value="Reset" onclick="javascript: resetList(\'jformparams'.$name.'\');"/>'; //jformparamssettingids
	//$shtml .= '</td><td valign="top"><input type="button" value="Reset" onclick="javascript: resetList(\'params'.$name.'\');"/>';
	//$shtml .= '</td></tr></table>';
	
	return $shtml;
}

function getBaseSettings($db, $mid) {
	$udddblist = '';
	$query = 'SELECT params AS value'
	. ' FROM #__modules where id=' . $mid;
	$db->setQuery($query);
	$dblist = $db->loadObjectList();
	// Parameter list is last in array
	//$udddblist = $dblist[count($dblist)-1]->value;
	// Above not always true, make sure to search all params in dblist!!!!
	$cnt = 0;
	do {
		$udddblist = $dblist[$cnt]->value;
//echo "udddblist$cnt=".$udddblist."(".strrpos($udddblist, "upload_location").")<br/>";
		if (strrpos($udddblist, "upload_location") >= 1) {
			//echo "FOUND IT!";
			break;
		}
		$cnt = $cnt + 1;
	} while (count($dblist) > $cnt);
	
	return $udddblist;
}

?>


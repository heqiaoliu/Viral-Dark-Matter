<?php defined('_JEXEC') or die('Restricted access'); // no direct access ?>
<?php error_reporting (E_ALL ^ E_NOTICE); ?>

<?php
// Server redirect if user has opted to
if (isset($_FILES["uploadedfile$mid"]["name"])) {
	if ($_FILES["uploadedfile$mid"]["name"] > 0) {
		if ((strlen($upload_redirect) > 0) && ($_SESSION["uploaderr$mid"] != 1)) {
			header('Location: '.$upload_redirect);
			exit();
		}
	}
}

$document =& JFactory::getDocument();
$document->addStyleSheet( $sfu_basepath."mod_simplefileupload.css" );
$document->addStyleSheet( $sfu_basepath."tmpl/fancybox/jquery.fancybox-1.3.4.css" );

if ($upload_jquery == 0) {
	if ($upload_jqueryinclude == 0)
		$document->addScript( $sfu_basepath."tmpl/jquery-1.4.3.min.js" );
	else
		echo '<script type="text/javascript" src="'.$sfu_basepath.'tmpl/jquery-1.4.3.min.js"></script>';
}
if ($upload_jquery < 2) {
	if ($upload_jqueryinclude == 0) {
		$document->addScript( $sfu_basepath."tmpl/fancybox/jquery.mousewheel-3.0.4.pack.js" );
		$document->addScript( $sfu_basepath."tmpl/fancybox/jquery.fancybox-1.3.4.js" );
	} else {
		echo '<script type="text/javascript" src="'.$sfu_basepath.'tmpl/fancybox/jquery.mousewheel-3.0.4.pack.js"></script>';
		echo '<script type="text/javascript" src="'.$sfu_basepath.'tmpl/fancybox/jquery.fancybox-1.3.4.js"></script>';
	}
}

$document->addScript( JURI::root().$sfu_basepath."tmpl/md5-min.js" );

if ($upload_users == "true") {
?>
<!-- use different getImageSrc function for IE
	 - which can't parse base64-encoded images
	 -->
<script type="text/javascript">
	function getImageSrc<?php echo $mid ?>(base64Src)
	{ return base64Src; }
</script>
<!--[if gte IE 5]>
	<script type="text/javascript">
		function getImageSrc<?php echo $mid ?>(base64Src)
		{ return "<?php echo JURI::root().$sfu_basepath;?>tmpl/sfuieimgfix.php";}
	</script>
<![endif]-->


<script language="javascript" type="text/javascript">
<!--
var $jqsfu = jQuery.noConflict();

var curPageURL<?php echo $mid ?> = window.location.href;
if (curPageURL<?php echo $mid ?>.indexOf(".php?") > 0) {
	curPageURL<?php echo $mid ?> += "&";
} else {
	curPageURL<?php echo $mid ?> += "?";
}

var sfuSubmitting<?php echo $mid ?> = false;

// NEW TEST AJAX
( function($jqsfu) {
// wait till the DOM is loaded

	$jqsfu(document).ready(function() {

		var params = '';

		$jqsfu('#sfu_AChkCredentials<?php echo $mid ?>').live('click', function() {
			
			var user = document.getElementById('txtUploadUser<?php echo $mid ?>').value;
			var pass = document.getElementById('txtUploadPass<?php echo $mid ?>').value;
			
			var hash = hex_md5(pass);
			params = '&val1='+user+'&val2='+hash+'&mid=<?php echo $mid ?>';
			
			$jqsfu.ajax({
				type: 'GET',
				url: curPageURL<?php echo $mid ?>,
				data: 'sfuaction=sfuuser' + params,
				cache: false,
				success: function(data) {
					
					var tr = document.getElementsByTagName('tr');
					var dispLogin = "none";
					var dispUpload = "none";
					
					if (data == "true") {
						//if usr/pass matches
						dispUpload = "block";
					} else {
						dispLogin = "block";
					}
					
					for ( var j = 0; j < tr.length; j++ ) {
						if (tr[j].className == "logintr<?php echo $mid ?>") tr[j].style.display = dispLogin;
						if (tr[j].className == "uploadtr<?php echo $mid ?>") tr[j].style.display = dispUpload;
					}
					
					if (data == "true" && document.getElementById("txtUploadFile<?php echo $mid ?>").value != "") {
						// Checking before submit
						processStep2<?php echo $mid ?>();
					} else {
						if (data == '<?php echo JText::_('FAIL_CREDENTIALS'); ?>') {
							// Session time-out, try to trigger session by reloading Captcha and then try again
							//reloadCaptcha<?php echo $mid ?>();
							//$jqsfu("a.sfu_AChkCredentials<?php echo $mid ?>").trigger("click");
							alert(data);
						} else {
							// Failed credentials
							if (data != "true") alert(data);
						}
					}
				}
			});
			
			return false;

		});
		
		$jqsfu('#sfu_AChkCaptcha<?php echo $mid ?>').live('click', function() {
			
			var el = document.getElementById('txtsfucaptcha<?php echo $mid ?>');
			var captcha = el.value;
			var casesense = '<?php echo $upload_capthcacase ?>';
			
			params = '&val1='+captcha+'&val2='+casesense+'&mid=<?php echo $mid ?>';
			
			$jqsfu.ajax({
				type: 'GET',
				url: curPageURL<?php echo $mid ?>,
				data: 'sfuaction=sfucaptcha' + params,
				cache: false,
				success: function(data) {
					if (data == "true") {
						//if captcha matches
						//alert("match");
						el.style.background  = "#C3FDB8";
						processStep3<?php echo $mid ?>();
					} else {
						alert(data);
						el.style.background  = "#F9966B";
					}
				}
			});
			
			return false;

		});
		
		$jqsfu('#sfu_AKillSession<?php echo $mid ?>').live('click', function() {
			
			params = '&val1=dummy&val2=dummy&mid=<?php echo $mid ?>';
			
			$jqsfu.ajax({
				type: 'GET',
				url: curPageURL<?php echo $mid ?>,
				data: 'sfuaction=sfukillsession' + params,
				cache: false,
				success: function(data) {
						alert(data);
					}
				
			});
			
			return false;

		});


	});
} ) ( jQuery );

function startProcess<?php echo $mid ?>() {
	if (document.getElementById("txtUploadFile<?php echo $mid ?>").value == "" || sfuSubmitting<?php echo $mid ?>) {
		return false;
	}
	
	if (!selPathSet<?php echo $mid ?> && document.getElementById("div_simplefileuploadpaths<?php echo $mid ?>").style.display=="block") {
		//alert("You must select a path to upload to!");
		alert("<?php echo JText::_('ADD_PATH'); ?>");
		return false;
	}
	
	<?php if (($upload_username != "") && ($usr_id == 0) && (strcmp($_SESSION["upload_username_ok$mid"], md5($upload_password)) != 0)) { ?>
		// Check user
		$jqsfu("a.sfu_AChkCredentials<?php echo $mid ?>").trigger("click");
	<?php } else { ?>
		processStep2<?php echo $mid ?>();
	<?php } ?>
	
}

function processStep2<?php echo $mid ?>() {
	
	<?php if (($upload_capthca == 1) && (strlen($upload_capthca) > 0)) { ?>
		$jqsfu("a.sfu_AChkCaptcha<?php echo $mid ?>").trigger("click");
	<?php } else { ?>
		processStep3<?php echo $mid ?>();
	<?php } ?>
	
}


function processStep3<?php echo $mid ?>() {
	
	if (selPath<?php echo $mid ?> == -1) {
		document.getElementById("div_simplefileuploadpaths<?php echo $mid ?>").style.display="block";
	} else {
		<?php if (($upload_useformsfields == 1) && (strlen($upload_formfields) > 0)) { ?>
			sfufancyFill<?php echo $mid ?>();
			$jqsfu("a.sfuFormFields<?php echo $mid ?>").trigger("click");
		<?php } else { ?>
			showProgress<?php echo $mid ?>();
		<?php } ?>
	}
	
}


// NEW TEST AJAX

function showProgress<?php echo $mid ?>() {
		
		document.getElementById("div_simplefileuploadpaths<?php echo $mid ?>").style.display="none";
		$jqsfu("a.sfuUploadProgress<?php echo $mid ?>").trigger("click");
		sfuSubmitting<?php echo $mid ?> = true;

		document.forms["frm_sfu<?php echo $mid ?>"].submit();

}

function addFile<?php echo $mid ?>() {

	var tab = document.getElementById('sfuContentTblInner<?php echo $mid ?>');
	var rowcnt=tab.rows.length;
	
	if (rowcnt >= <?php echo $upload_maxmulti; ?>) {

		alert("<?php echo JText::_('MAX_MULTI_REACHED'); ?>");
		return false;
	}
	
	var clone=tab.getElementsByTagName('tr')[0].cloneNode(true);//the clone of the first row

	tab=document.getElementById('sfuContentTblInner<?php echo $mid ?>').insertRow(-1);
	var y=tab.insertCell(0);
	var cont=clone.innerHTML;


	<?php if ($upload_stdbrowse == 0) { ?>
	cont=cont.replace(/fakefileinput/g,"fakefileinput"+rowcnt);
	<?php } else { ?>
	//Move the textbox to the left
	cont=cont.replace(/-1px/g,"-3px");
	<?php } ?>

	y.innerHTML=cont;
}

function reloadCaptcha<?php echo $mid ?>() {
	var date = new Date();
	var tmp = "sfuaction=captcha&v=" + date.getTime();
	tmp += "&mid=<?php echo $mid ?>";

	var cap = document.getElementById('sfuCaptchaImg<?php echo $mid ?>');
	cap.setAttribute("src", ""+curPageURL<?php echo $mid ?>+tmp);
}

function chkUserPass<?php echo $mid ?>() {
	var user = document.getElementById('txtUploadUser<?php echo $mid ?>').value;
	var pass = document.getElementById('txtUploadPass<?php echo $mid ?>').value;

	if (user.length == 0 || pass.length == 0) {
		alert("<?php echo JText::_('UPLOAD_USER'); ?>");
		return false;
	}
	$jqsfu("a.sfu_AChkCredentials<?php echo $mid ?>").trigger("click");
	
}

var selPath<?php echo $mid ?> = -1;
var selPathSet<?php echo $mid ?> = false;

function getCheckedValue<?php echo $mid ?>(radioObj) {
	if(!radioObj)
		return "";
	var radioLength = radioObj.length;
	if(radioLength == undefined)
		if(radioObj.checked)
			selPath<?php echo $mid ?> = radioObj.value;
		else
			selPath<?php echo $mid ?> = "";
	for(var i = 0; i < radioLength; i++) {
		if(radioObj[i].checked) {
			selPath<?php echo $mid ?> = radioObj[i].value;
		}
	}
	selPathSet<?php echo $mid ?> = true;
	document.getElementById("selPathId<?php echo $mid ?>").value = selPath<?php echo $mid ?>;
}

// TEST Multi SELECT in FireFox 3.6+
function listFiles<?php echo $mid ?>() {


	try {
			var input = document.querySelector("input[type='file']");
			// Only if more than one selected!
			if (input.files.length > 1) {
				var ul = document.querySelector("#bag<?php echo $mid ?>>ul");
				while (ul.hasChildNodes()) {
					ul.removeChild(ul.firstChild);
				}
				for (var i = 0; i < input.files.length; i++) {
					var li = document.createElement("li");
					li.innerHTML = "<b>* " + input.files[i].name + "</b>";
					
					ul.appendChild(li);
					document.getElementById("trfileList<?php echo $mid ?>").style.display="block";
				}
			}
	
	} catch(e) {
		// Just ignore, not supported browser
	}
}

// FancyBox below
( function($jqsfu) {
$jqsfu(document).ready(function() {
	$jqsfu("#sfuAFormFields<?php echo $mid ?>").fancybox({
		'titlePosition'		: 'inside',
		'transitionIn'		: 'elastic',
		'transitionOut'		: 'elastic',
		'hideOnOverlayClick': false,
		'hideOnContentClick': false,
		'showCloseButton'	: true,
		'autoDimensions'	: true
		 
	});
	
	$jqsfu("#sfuAUploadProgress<?php echo $mid ?>").fancybox({
		'titlePosition'		: 'inside',
		'transitionIn'		: 'elastic',
		'transitionOut'		: 'elastic',
		'hideOnOverlayClick': false,
		'hideOnContentClick': false,
		'showCloseButton'	: false,
		'autoDimensions'	: true
		});

});

} ) (jQuery);


function sfufancyFill<?php echo $mid ?>() {
	var current = null;
	var filename = "";
	var firstfilename = "";
	var inputmatch = "uploadedfile<?php echo $mid ?>";
	var cnt = 0;
	var tab = null;
	
	if (document.getElementById("sfuffFileName<?php echo $mid ?>_0").innerHTML.length > 0) {
		// We have already been here, remove any set rows incase user has added or changed files					
		
		tab = document.getElementById('sfuffTab<?php echo $mid ?>');
		var rowCount = tab.rows.length;
		var j = rowCount - 1;
		if (rowCount > 1) {
			do {
				tab.deleteRow(j);
				j--;
			} while (tab.rows.length > 1);
		}
		
	}
	
	for(var i = 0; current = document.getElementsByTagName('input')[i]; i++) {
		
		if (current.type == "file" && current.name.substr(0, inputmatch.length) == inputmatch) {
			
			if (current.value.length > 2) {
				// There must be a path and slash and a name "a/b" would be the minimum therefore lenght >2
				//This is a crude and uly thing if you have PHP server problems that removes double backslashes
				
				var tmp = "";
				filename = "";
				for (var j = 1; j <= current.value.length; j++) {
					
					tmp = current.value.substr(current.value.length-j,1);
					if (tmp.length > 0) {
						if ((tmp.charCodeAt(0) == 92) || (tmp.charCodeAt(0) == 47)) break;
						filename = tmp + filename;
					}
				}
				
				/*
				// Anders Wasén 2011-05-24, I am going for the somewhat more crude version above as the PHP server \\ bugs are affecting quite a few people... :(
				try {
					// this fails on some clients, retry to fix by adding PHP echo, should work for all PHP versions...
					// some PHP versions replaces the double back-slashes even though it was in the HTML block! :o (=PHP Bug)
					// Work-around by letting PHP echo in teh text to the JavaScript... 2011-05-23, Anders Wasén
					filename = current.value.match(<?php echo "/[^\/\\\\]+$/"; ?>).toString();
				} catch(E) {
					// fall-back plan...
					var fullPath = current.value.split(<?php echo "/(\\\\|\/)/g"; ?>).toString();
					filename = fullPath[fullPath.length-1];
				}
				*/
				
				if (cnt == 0) {
					// First objects already exists
					document.getElementById("sfuffFileName<?php echo $mid ?>_0").innerHTML = filename;
					firstfilename = filename;
				} else {
					
					tab = document.getElementById('sfuffTab<?php echo $mid ?>');
					
					var clone=tab.getElementsByTagName('tr')[0].cloneNode(true);//the clone of the first row, i.e. the whole nested table
					
					tab=document.getElementById('sfuffTab<?php echo $mid ?>').insertRow(-1);
					var y=tab.insertCell(0);
					var cont=clone.innerHTML;

					cont=cont.replace(/sfuffFileName<?php echo $mid ?>_0/g,"sfuffFileName<?php echo $mid ?>_" + cnt);
					
					cont=cont.replace(/rplcfilename/g, filename);

					y.innerHTML=cont;
					
					document.getElementById("sfuffFileName<?php echo $mid ?>_" + cnt).innerHTML = filename;
					
				}
				cnt += 1;
				
			}
		}
	}
	
	if (firstfilename.length > 0) {
		inputmatch = "sfuff<?php echo $mid ?>_";
		for(var i = 0; current = document.getElementsByTagName('input')[i]; i++) {

			if (current.name.indexOf(inputmatch) == 0 && current.name.indexOf("rplcfilename") > 0)
				current.name = current.name.replace(/rplcfilename/g, firstfilename);
		}
	}
}

function sfufancyClose<?php echo $mid ?>() {
	var current = null;
	var txtFF = document.forms["frm_sfu<?php echo $mid ?>"].elements["sfuFormFields<?php echo $mid ?>"];
	txtFF.value = "";
	inputmatch = "sfuff<?php echo $mid ?>_";
	for(var i = 0; current = document.getElementsByTagName('input')[i]; i++) {
		
		if (current.type == "text" && current.name.substr(0, inputmatch.length) == inputmatch) {
			txtFF.value += current.name+"="+current.value+"[||]";
		}
	}
	
	showProgress<?php echo $mid ?>();
	$jqsfu.fancybox.close();
}


-->
</script>

<!-- keep it in html as names change with module id -->
<style>
	.sfu_table {
		border-bottom: none !important;
		border-left: none !important;
		border-right: none !important;
		border-top: none !important;
	}
	
	.logintr<?php echo $mid ?> {
		border-bottom: none !important;
		border-left: none !important;
		border-right: none !important;
		border-top: none !important;
	}
	
	.uploadtr<?php echo $mid ?> {
		border-bottom: none !important;
		border-left: none !important;
		border-right: none !important;
		border-top: none !important;
	}

</style>

<!-- FancyBox -->
<a id="sfu_AChkCredentials<?php echo $mid ?>" class="sfu_AChkCredentials<?php echo $mid ?>" href="#sfu_AChkCredentials<?php echo $mid ?>" style="display: none;">UserCredentials</a>
<a id="sfu_AChkCaptcha<?php echo $mid ?>" class="sfu_AChkCaptcha<?php echo $mid ?>" href="#sfu_AChkCaptcha<?php echo $mid ?>" style="display: none;">Captcha</a>
<!-- BELOW ONLY FOR DEBUGING DEVELOPMENT -->
<a id="sfu_AKillSession<?php echo $mid ?>" class="sfu_AKillSession<?php echo $mid ?>" href="#sfu_AKillSession<?php echo $mid ?>" style="display: none;">Kill Session</a>


<a id="sfuAUploadProgress<?php echo $mid ?>" class="sfuUploadProgress<?php echo $mid ?>" href="#sfuUploadProgress<?php echo $mid ?>" style="display: none;">sfuUploadProgressFancy</a>
<div style="display: none;">
	<div id="sfuUploadProgress<?php echo $mid ?>" class="sfu_content" style="text-align: center; margin-bottom: 10px; margin-top: 10px; margin-left: 10px; margin-right: 10px; width: 220px;">
		<table class="sfu_table" border=0 style="width: 100%;">
			<tr class="sfu_table">
				<td class="sfu_table" id="popProgress<?php echo $mid ?>" style="text-align: center;">
					<?php echo JText::_('UPLOADING'); ?>
				</td>
			</tr>
			<tr class="sfu_table">
				<td class="sfu_table" style="text-align: center;">
					<img src="<?php echo JURI::root().$sfu_basepath;?>images/bigrotation2.gif" />
				</td>
			</tr>
			<tr class="sfu_table">
				<td class="sfu_table" style="text-align: center;">
					<?php echo JText::_('PLEASE_WAIT'); ?>
				</td>
			</tr>
		</table>
	</div>
</div>

<table class="sfu_table" border="0" cellspacing=0 cellpadding=0>
<tr class="sfu_table">
<td class="sfu_table">

<form id="frm_sfu<?php echo $mid ?>" enctype="multipart/form-data" action="" method="POST">
<input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $upload_maxsize;?>" />
<input type="hidden" name="sfuFormFields<?php echo $mid ?>" value="" />
	
<div>

	<table class="sfu_table" id="sfuContentTbl<?php echo $mid ?>" border="0" cellpadding="0" cellspacing="0">
		
		<?php if (($upload_username != "") && ($usr_id == 0) && (strcmp($_SESSION["upload_username_ok$mid"], md5($upload_password)) != 0)) { 
			$divUploadShow = "none";
		
		?>
		<tr class="logintr<?php echo $mid ?>"><td class="sfu_table"><?php echo JText::_('FILE_LABEL'); ?></td></tr>
		<tr class="logintr<?php echo $mid ?>">
			<td class="sfu_table" colspan="2">
<!-- Added position:relative DIV due to IE bug -->
				<div style="position: relative;">
					<div id="div_simplefileuploaduser<?php echo $mid ?>" class="sfu_content" style="position: relative; width: 150px; padding: 10px 30px; margin: 10px auto; left: -28px; top:0px; display: block; background: <?php echo $upload_bgcolor ?>; text-align: left; border: 1px outset white; z-index: 20;">
						<table class="sfu_table" border=0 style="width: 100%;">
							<tr class="sfu_table"><td class="sfu_table" colspan="2" style="padding-bottom: 10px;"><b><?php echo JText::_('UPLOAD_USER'); ?></b></td></tr>
							<tr class="sfu_table"><td class="sfu_table"><?php echo JText::_('USERNAME'); ?></td><td><input type="text" style="width: 71px;" size="10" id="txtUploadUser<?php echo $mid ?>" /></td></tr>
							<tr class="sfu_table"><td class="sfu_table"><?php echo JText::_('PASSWORD'); ?></td><td><input type="password" style="width: 70px;" size="10" id="txtUploadPass<?php echo $mid ?>" /></td></tr>
							<tr class="sfu_table"><td class="sfu_table" colspan="2" style="text-align: right;"><input type="button" value="OK" onclick="javascript:chkUserPass<?php echo $mid ?>();" /></td></tr>
						</table>
					</div>
				</div>
			</td>
		</tr>
		<?php } else {
				$divUploadShow = "block";
			}

		?>
		<tr class="uploadtr<?php echo $mid ?>" style="display: <?php echo $divUploadShow; ?>">
			<td class="sfu_table"><?php echo JText::_('FILE_LABEL'); ?> <?php if ($upload_multi == 1) { ?><span style="cursor: hand; cursor: pointer;" onclick="javascript:addFile<?php echo $mid ?>()"><b>[&nbsp;+&nbsp;]</b></span> <?php } ?></td>
		</tr>
		<tr class="uploadtr<?php echo $mid ?>" style="display: <?php echo $divUploadShow; ?>">
			<td class="sfu_table">

				<table class="sfu_table" id="sfuContentTblInner<?php echo $mid ?>" border="0" cellpadding="0" cellspacing="0">
				<?php if ($upload_startmulti == 0 || !is_numeric($upload_startmulti)) $upload_startmulti = 1;

				// Create nunber of start boxes
				for ($is = 0; $is < $upload_startmulti; $is++) {
					if ($is > 0)
						$ispostfix = $is;
					else
						$ispostfix = "";
				?>
				<tr class="sfu_table"><td class="sfu_table">
				<?php if ($upload_stdbrowse == 0) { ?>

						<div style="position: relative; height: 24px; white-space: nowrap; overflow: hidden;">
							<input id="fakefileinput<?php echo $mid.$ispostfix ?>" style="position: relative; width: 98px; z-index: 1; top: -8px;" />&nbsp;<img style="position: relative; z-index: 1; top: -5px;" src="<?php echo JURI::root().$sfu_basepath;?>images/button_select.gif" />

							<span  style="position: relative; left: -171px; top: 0px; height: 24px; z-index: 10; top: -7px;">
								<input type="file" id="txtUploadFile<?php echo $mid.$ispostfix ?>" name="uploadedfile<?php echo $mid ?>[]" size=12 style="width: 160px; z-index: 10; -moz-opacity: 0; filter:alpha(opacity: 0); opacity: 0;" multiple="" onchange="javascript: listFiles<?php echo $mid ?>(); document.getElementById('fakefileinput<?php echo $mid.$ispostfix ?>').value=this.value;" />
							</span>

						</div>

				<?php } else { ?>
					<input type="file" id="txtUploadFile<?php echo $mid.$ispostfix ?>" name="uploadedfile<?php echo $mid ?>[]" size="<?php echo $upload_filewidth; ?>" style="position: relative; left: -1px;" multiple="" onchange="javascript: listFiles<?php echo $mid ?>();" />
				<?php } // end if ?>


				</td></tr>
				<?php } // end for ?>
				</table>
			</td>
		</tr>
		<tr class="sfu_table" id="trfileList<?php echo $mid ?>" style="display: none;">
			<td class="sfu_table">
				<div id="bag<?php echo $mid ?>"><ul/></div>
			</td>
		</tr>
	

	<?php if ($upload_capthca == 1) { ?>
		<tr class="uploadtr<?php echo $mid ?>" style="display: <?php echo $divUploadShow; ?>">
			<td class="sfu_table">
				<span id="sfucaptcha<?php echo $mid ?>"><img id="sfuCaptchaImg<?php echo $mid ?>" width="<?php echo $upload_capthcawidth;?>" height="<?php echo $upload_capthcaheight;?>" src="data:image/jpeg;base64,<?php echo SFUAjaxServlet::getCaptcha($sfu_version, $bgcolor, $mid, 'site');?>" /></span><a href="#" onclick="javascript: reloadCaptcha<?php echo $mid ?>();"><img height="24px" src="<?php echo JURI::root().$sfu_basepath;?>images/button_refresh.gif" alt="Refresh Captcha" /></a>
				
				<?php if (($upload_capthcacasemsg == 1) && ($upload_capthcacase == 1)) { ?>
				<br/>
				<span style="font-size: 7pt;" ><?php echo JText::_('CASE_INSENSITIVE'); ?></span>
				<?php } ?>
			</td>
		</tr>
		
		<tr class="uploadtr<?php echo $mid ?>" style="display: <?php echo $divUploadShow; ?>">
			<td class="sfu_table">
				<nobr>
				<?php echo JText::_('CAPTCHA_LABEL'); ?>:&nbsp;
				<input type="text" id="txtsfucaptcha<?php echo $mid ?>" name="txtsfucaptcha<?php echo $mid ?>" value="" maxlength="10" style="width: 80px;" />
				</nobr>
			</td>	
		</tr>
	<?php
	}
	?>
		<tr class="uploadtr<?php echo $mid ?>" style="display: <?php echo $divUploadShow; ?>">
			<td class="sfu_table" style="padding-top: 5px;">
				<input type="button" style="" onclick="javascript:startProcess<?php echo $mid ?>();" value="<?php echo JText::_('UPLOAD_BUTTON_TEXT'); ?>" />
				
				<?php if (is_array($upload_userpath)) { 
						if (count($upload_userpath) > 1) {
				?>
				<div id="div_simplefileuploadpaths<?php echo $mid ?>" class="sfu_content" style="padding: 10px 30px; margin: 10px auto; position: relative; left:-20px; top:-50px; display: none; background: <?php echo $upload_bgcolor ?>; text-align: left; border: 1px outset white; z-index: 20;">
					<table class="sfu_table" border=0 style="width: 100%;">
						<tr class="sfu_table"><td colspan="2"><nobr><u><?php echo JText::_('SELECT_DIR'); ?>:</u></nobr></td></tr>
						<?php
						$ix = 0;
						foreach ($upload_userpath as $path) {
							
							echo "<tr class=\"sfu_table\"><td class=\"sfu_table\"><input type=\"radio\" name=\"selPath$mid\" value=\"".$ix."\" onclick=\"javascript:getCheckedValue".$mid."(this);\" /></td><td><nobr>".$path."</nobr></td></tr>";
							$ix += 1;
						}
						echo "<input type=\"hidden\" id=\"selPathId$mid\" name=\"selPathId$mid\" value=\"\" style=\"display: none;\" />";
						?>
						<tr class="sfu_table"><td class="sfu_table" colspan="2" style="text-align: right;"><input type="button" value="<?php echo JText::_('OK_BUTTON'); ?>" onclick="javascript:processStep3<?php echo $mid ?>();" /></td></tr>
					</table>
				</div>
				<?php 
					} else {
						?>
						<div id="div_simplefileuploadpaths<?php echo $mid ?>" style="display: none;"></div>
				
						<script language="javascript" type="text/javascript">
							var selPath<?php echo $mid ?> = 0;
						</script>
						<?php
					}
				}
								
				if (($upload_useformsfields == 1) && (strlen($upload_formfields) > 0)) { 
				?>
					<!-- FancyBox -->
					<a id="sfuAFormFields<?php echo $mid ?>" class="sfuFormFields<?php echo $mid ?>" href="#sfuFormFields<?php echo $mid ?>" style="display: none;">sfuFormFieldsFancy</a>

					<div style="display: none;">
						<div id="sfuFormFields<?php echo $mid ?>" style="width:400px;overflow:auto;">
							<span style="text-align: left; color: #fff;" class="fancybox-bar-under"><?php echo JText::_('FORM_FIELDS_LABEL'); ?></span>
							<table class="sfu_table" id="sfuffTab<?php echo $mid ?>" border="0">
							<tr class="sfu_table"><td class="sfu_table">
								<table class="sfu_table" border="0" width="100%">
									<tr class="sfu_table"><td class="sfu_table" colspan="2" style="background-color: #bdbdbd; border: 1px outset white;"><span style="font-style: italic;" id="sfuffFileName<?php echo $mid ?>_0"></span></td></tr>
								<?php
								$fields = explode(";", $upload_formfields);
								foreach ($fields as $f) {
									echo "<tr class=\"sfu_table\"><td class=\"sfu_table\">".$f."</td><td class=\"sfu_table\"><input type=\"text\" name=\"sfuff" . $mid . "_" . $f . "_rplcfilename\" style=\"width: 280px;\" /></td></tr>";
								}
								?>
								</table>
							</td></tr>
							</table>
							<span style="text-align: right;" class="fancybox-bar-under"><input type="button" onclick="javascript: sfufancyClose<?php echo $mid ?>();"  value="<?php echo JText::_('UPLOAD_BUTTON_TEXT'); ?>" /></span>
						</div>
					</div>
				<?php
				}
				?>

			</td>
		</tr>
	</table>
	
</div>
</form>

</td>
</tr>

<?php
if (isset($_FILES["uploadedfile$mid"]["name"])) {
	if ($_FILES["uploadedfile$mid"]["name"] > 0) {
?>

<tr class="sfu_table">
<td class="sfu_table" valign="top">

<?php
 if (($upload_popcaptchamsg == 0) && ($results == JText::_('FAULTY_APTCHA'))) {
	echo "<span style='font-weight: bold; color: #dd1010;'>" . $results . "</span>";
	$results = "";
} else { ?>

	<!-- FancyBox -->
	<a id="sfuAUploadMsg<?php echo $mid ?>" class="sfuUploadMsg<?php echo $mid ?>" href="#sfuUploadMsg<?php echo $mid ?>" style="display: none;">sfuUploadMsgFancy</a>
	<div style="display: none;">
		<table id="sfuUploadMsg<?php echo $mid ?>" class="sfu_content" style="margin-right: 10px; margin-top: 10px; margin-left: 10px; width: 350px; height:252px;" cellspacing=0 cellpadding=0>
			<tr class="sfu_table">
				<td class="sfu_table" valign="top" style="width: 100%; height: 25px; font-weight: bold; font-size: 12pt; color: #898998;">
					<?php echo JText::_('FILE_UPLOAD_NAME'); ?>
				</td>
			</tr>
			<tr class="sfu_table">
				<td class="sfu_table" valign="top" style="width: 100%; font-size: 9pt; color: #898998;">
					<hr />

					<?php echo $results; ?>
					
				</td>
				<!--td style="width: 12px;" valign="bottom"><img src="<?php echo JURI::root().$sfu_basepath;?>images/infobox_bg.gif" /></td-->
			</tr>
		</table>
	</div>
	
	<script language="javascript" type="text/javascript">
	<!--
	var sflt<?php echo $mid ?>;
	var sflt<?php echo $mid ?>cnt = 0;
	// FancyBox below
	( function($jqsfu) {
	$jqsfu(document).ready(function() {

		$jqsfu("#sfuAUploadMsg<?php echo $mid ?>").fancybox({
			'titlePosition'		: 'inside',
			'transitionIn'		: 'elastic',
			'transitionOut'		: 'elastic',
			'hideOnOverlayClick': false,
			'hideOnContentClick': false,
			'showCloseButton'	: true,
			'autoDimensions'	: true
			 
		});
		
		$jqsfu("a.sfuUploadMsg<?php echo $mid ?>").trigger('click');
		
		<?php if ($sfu_autorefreshsfl === "1") { ?>
		var sflt<?php echo $mid ?>=setTimeout("callSFLRefresh<?php echo $mid ?>()", 500);
		<?php } ?>
	});

	} ) ( jQuery );

		function callSFLRefresh<?php echo $mid ?>() {
		// Give it 3 seconds...
		if (sflt<?php echo $mid ?>cnt >= 5) {
			clearTimeout(sflt<?php echo $mid ?>);
			return false;
		}
		
		try {
			// Try to find it...
			$jqsfl("a.sfl_ARefresh").trigger('click');
		} catch(e) {
			sflt<?php echo $mid ?>cnt += 1;
			var sflt<?php echo $mid ?>=setTimeout("callSFLRefresh<?php echo $mid ?>()", 500);
		}
		
	}
	-->
	</script>


<?php } ?>
	
</td>
</tr>

<?php

	}
}

?>

</table>

<?php

} else {

	echo "<div style=\"font-size: 10pt; color: #898998; width: 90%;\">" . JText::_('NOT_ALLOWED_USER') . "</div>";

}

?>
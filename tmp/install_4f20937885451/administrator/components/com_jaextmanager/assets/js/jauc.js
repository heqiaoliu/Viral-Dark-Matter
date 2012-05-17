// JavaScript Document
if (jQuery && jQuery.noConflict) jQuery.noConflict();

function jaOpenUploader() {
	width = 600;
	height = 400;
	var url = 'index.php?tmpl=component&option=com_jaextmanager&view=default&viewmenu=0&layout=uploader';
	JAOpenPopup(url, '', width, height);
	//jaCreatePopup(url, width, height, 'JA Uploader');
	return false;
}

function checkNewVersion(itemID, resultID){
	//jQuery("#"+resultID).html(itemID);
	jQuery("#"+resultID).html("Please wait...");
	
	jQuery.ajax({
		  url: "index.php?option=com_jaextmanager&view=default&task=checkupdate&ajax=1",
		  type: "POST",
		  data:  {'cId[]' : itemID} ,
		  success: function(msg){
			 jQuery("#"+resultID).html(msg);
		  }
	   }
	);
}

function checkNewVersions() {
	// IDs checked
	arrID = jQuery("[id*=cId]:checked");
	if(arrID.length == 0){
		alert("Please select items to check update!");
		return;
	}
	
	jQuery.each(arrID, function(){
		checkNewVersion(this.value, 'LastCheckStatus_'+this.value);
	});
}

function doUpgrade(etxId, version, resultID) {
	var dialogTitle = "JoomlArt Extensions Manager";
	
	if(etxId == '') {
		jAlert('Please select product to Upgrade!', dialogTitle);
		return false;
	}
	if(version == '') {
		jAlert('Please select version that you want to upgrade to!', dialogTitle);
		return false;
	}
	
	var now = new Date();
	var msgAlert = 'Upgrade to version ' + version + ' - Dated ' + now.toLocaleString();
	
	jPrompt('Hint: Click to enter your own note', msgAlert, dialogTitle, function(r) {
		if( r ) {
			var sComment = r;
			jQuery("#"+resultID).html("Processing. Please wait...");
			
			jQuery.ajax({
				  url: "index.php?option=com_jaextmanager&view=default&task=upgrade&ajax=1",
				  type: "POST",
				  data:  {'cId[]' : etxId, 'version': version, 'comment': sComment} ,
				  success: function(msg){
					 jQuery("#"+resultID).html(msg);
				  }
			   }
			);
		}
	});
}


function JAOpenPopup(url, popup_name, width, height) {
	if(width == 'full') {
		width = screen.width;
	}
	if(height == 'full') {
		height = screen.height;
	}
	var left = Math.floor((screen.width - width) / 2);
	var top = Math.floor((screen.height - height) / 2);
	var win= window.open(url, popup_name, 'height=' + height + ', width=' + width + ', left=' + left + ',top=' + top + ',toolbar=no, menubar=no, scrollbars=yes, resizable=yes, location=no, status=no');
	return win;
}

// Recovery function
function recoveryItem(itemID, resultID){
	jQuery("#"+resultID).html("Please wait...");
	
	jQuery.ajax({
		  url: "index.php?option=com_jaextmanager&view=default&task=recovery&ajax=1",
		  type: "POST",
		  data:  {'cId[]' : itemID} ,
		  success: function(msg){
			 jQuery("#"+resultID).html(msg);
		  }
	   }
	);
}

// Recovery function
function doRecoveryItem(itemID, version, recoveryFile){
	var dialogTitle = "JoomlArt Extensions Manager";
	
	var now = new Date();
	var msgAlert = 'Rollback to version ' + version + ' - Dated ' + now.toLocaleString();
	
	jPrompt('Hint: Click to enter your own note', msgAlert, dialogTitle, function(r) {
		if( r ) {
			var sComment = r;
			jQuery("#LastCheckStatus_"+itemID).html("Rolling Back...");
			jQuery.ajax({
				  url: "index.php?option=com_jaextmanager&view=default&task=doRecovery&ajax=1",
				  type: "POST",
				  data:  {'cId[]' : itemID, 'file': recoveryFile, 'comment': sComment} ,
				  success: function(msg){
					 jQuery("#LastCheckStatus_"+itemID).html(msg);
				  }
			   }
			);
		}
	});
}

function recoveryAll() {
	// IDs checked
	arrID = jQuery("[id*=cId]:checked");
	if(arrID.length == 0){
		alert("Please select items to rollback!");
		return;
	}
	jQuery.each(arrID, function(){
		recoveryItem(this.value, 'LastCheckStatus_'+this.value);
	});
}

// get list of conflicted backup folder
function getListConflictedFolder(itemID, resultID){
	jQuery("#"+resultID).html("Please wait...");
	
	jQuery.ajax({
		  url: "index.php?option=com_jaextmanager&view=default&task=list_backup_conflicted&ajax=1",
		  type: "POST",
		  data:  {'cId[]' : itemID} ,
		  success: function(msg){
			 jQuery("#"+resultID).html(msg);
		  }
	   }
	);
}

function showMoreOlderVersion(linkObj, regionID){
	if( jQuery("#" + regionID ).css('display') == 'none' ){
		jQuery('#'+regionID).fadeIn(1000);
		jQuery(linkObj).html("Hide");
	}else{
		jQuery('#'+regionID).fadeOut(1000);
		jQuery(linkObj).html("Show");	
	}
}

function configExtensions(element, extId) {
	var offset = jQuery(element).offset();
	var top = offset.top - jQuery(window).scrollTop() - 30;
	jaCreatePopup('index.php?option=com_jaextmanager&tmpl=component&view=default&layout=config_extensions&cId[]='+extId, 370, 200, jQuery(element).attr('title'));
	//jQuery('#jaForm').css({'top': top, 'left': offset.left - 370});
}
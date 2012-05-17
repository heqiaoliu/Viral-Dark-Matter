// JavaScript Document
if (jQuery && jQuery.noConflict) jQuery.noConflict();

var jaTreeTimer;

function jaTreeConflictedAddActions(product, conflictedFolder) {
	jQuery('div[class*=dTreeNode]').each(function(e){
		jQuery(this).mouseover(function(){
			jQuery(this).addClass('active');
		}).mouseout(function(){
			jQuery(this).removeClass('active');
		});
	});
	
	var title = "Compare between backup file and live file";
	var allowedExtensions = /\.(?:php|php3|php4|php5|asp|aspx|jsp|phtml|inc|tpl|htm|html|xml|shtml|xhtml|sql|txt|js|css|ini)$/gi;
	jQuery('div[class*=dtree_status]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action">'
				+ '<a href="#" title="'+title+'" class="compare" onclick="jaCompareConflictedFiles(\''+product+'\',\''+conflictedFolder+'\',\''+file+'\'); return false;">Compare</a>'
				+ '</span>'
			);
		}
	}); 
	//view source links
	jQuery('div[class*=dtree_status]').each(function(e) {
		jQuery(this).find('a[id^=sd]').bind('click', function(e){
			var file = jQuery(this).attr('title');				  
			if(file.match(allowedExtensions)){
				var url = 'index.php?option=com_jaextmanager&tmpl=component&view=default&layout=view_source&cId[]='+product+'&file=' + file;
				JAOpenPopup(url, '', 'full', 'full');
			}
		});
	});
}

function jaCompareConflictedFiles(product, folder, file) {
	var url = "index.php?option=com_jaextmanager&tmpl=component&view=default&task=files_compare_conflicted";
	url += "&cId[]="+product;
	url += "&folder="+folder;
	url += "&file="+file;
	JAOpenPopup(url, "", 'full', 'full') ;
}

function jaTreeAddActions(product, currVersion, newVersion) {
	//L: live version
	//O: original version
	//N: new version
	var nameLN = 'Diff vs Current';
	var titleLN = 'View Difference bettween '+newVersion+' vs current file ('+currVersion+' and modified by you)';
	var nameON = 'Diff vs '+currVersion;
	var titleON = 'View Difference bettween '+newVersion+' vs '+currVersion+'';
	var nameLO = currVersion+' vs Current';
	var titleLO = 'View Difference bettween '+currVersion+' vs current file ('+currVersion+' and modified by you)';
	var allowedExtensions = /\.(?:php|php3|php4|php5|asp|aspx|jsp|phtml|inc|tpl|htm|html|xml|shtml|xhtml|sql|txt|js|css|ini)$/gi;
	
	jQuery('div[class*=dTreeNode]').each(function(e){
		jQuery(this).mouseover(function(){
			jQuery(this).addClass('active');
		}).mouseout(function(){
			jQuery(this).removeClass('active');
		});
	});
	
	jQuery('div[class*=dtree_status_update]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');	  
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action"><strong>Compare<\/strong>: '
				+ '<a href="#" title="'+titleON+'" class="compare" onclick="jaCompareFiles(\'ON\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameON+'</a>'
				+ '</span>'
			);
		}
	}); 
	jQuery('div[class*=dtree_status_bmodified]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');	  
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action"><strong>Compare<\/strong>: '
				+ '<a href="#" title="'+titleLN+'" class="compare" onclick="jaCompareFiles(\'LN\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameLN+'</a>'
				+ ' | '
				+ '<a href="#" title="'+titleLO+'" class="compare" onclick="jaCompareFiles(\'LO\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameLO+'</a>'
				+ ' | '
				+ '<a href="#" title="'+titleON+'" class="compare" onclick="jaCompareFiles(\'ON\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameON+'</a>'
				+ '</span>'
			);
		}
	}); 
	jQuery('div[class*=dtree_status_umodified]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');	  
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action"><strong>Compare<\/strong>: '
				+ '<a href="#" title="'+titleLN+'" class="compare" onclick="jaCompareFiles(\'LN\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameLN+'</a>'
				+ '</span>'
			);
		}
	}); 
	
	//view source of live files
	var selector = '';
	selector += 'div[class*=dtree_status_bmodified]';
	selector += ',div[class*=dtree_status_updated]';
	selector += ',div[class*=dtree_status_removed]';
	selector += ',div[class*=dtree_status_umodified]';
	selector += ',div[class*=dtree_status_ucreated]';
	selector += ',div[class*=dtree_status_nochange]';
	jQuery(selector).each(function(e) {
		jQuery(this).find('a[id^=sd]').bind('click', function(e){	  
			var file = jQuery(this).attr('title');
			if(file.match(allowedExtensions)){
				var url = 'index.php?option=com_jaextmanager&tmpl=component&view=default&layout=view_source&cId[]='+product+'&file=' + file;
				JAOpenPopup(url, '', 'full', 'full');
			}
		});
	});
	//view source of new files on new version
	jQuery('div[class*=dtree_status_new]').each(function(e) {
		jQuery(this).find('a[id^=sd]').bind('click', function(e){ 
			var file = jQuery(this).attr('title');
			if(file.match(allowedExtensions)){
				var url = 'index.php?option=com_jaextmanager&tmpl=component&view=default&layout=view_remote_source&cId[]='+product+'&file=' + file+'&version='+newVersion;
				JAOpenPopup(url, '', 'full', 'full');
			}
		});
	});
}

function jaCompareFiles(type, product, version, file) {
	var url = "index.php?option=com_jaextmanager&tmpl=component&view=default&task=files_compare";
	url += "&diff_type=" + type;
	url += "&cId[]="+product;
	url += "&version="+version;
	url += "&file="+file;
	JAOpenPopup(url, "", 'full', 'full') ;
}

function jaShowTreeFiles(numTreeNode, changedType){
	var startTime = jaStartBreakPoint();
	
	var arrType = jQuery("input[name=file_type]");
	var arrFolder = new Array();
	
	//disabled checkboxes
	arrType.attr('disabled','disabled');
	
	for(tid = 0; tid < arrType.size(); tid++) {
		var type = arrType[tid].value;
		if(arrType[tid].checked) {
			//files show
			if(typeof(aTreeFileStatus[type]) != 'undefined') {
				if(changedType == '' || changedType == type) {
					jaUpdateCss('.dtree_status_'+type, 'display', 'block');
				}
				//jaTreeApplyStatus(aTreeFileStatus[type], "block");
			}
			
			if(typeof(aTreeFolderStatus[type]) != 'undefined') {
				//folders show
				var arr = aTreeFolderStatus[type];
				for(i=0; i<arr.length; i++){
					arrFolder[arr[i]] = 1;
				}
			}
		} else {
			//files hide
			if(typeof(aTreeFileStatus[type]) != 'undefined') {
				if(changedType == '' || changedType == type) {
					jaUpdateCss('.dtree_status_'+type, 'display', 'none');
				}
				//jaTreeApplyStatus(aTreeFileStatus[type], "none");
			}
			
			if(typeof(aTreeFolderStatus[type]) != 'undefined') {
				//folders hide
				var arr = aTreeFolderStatus[type];
				for(i=0; i<arr.length; i++){
					if(typeof(arrFolder[arr[i]]) == 'undefined') {
						arrFolder[arr[i]] = 0;
					}
				}
			}
		}	
	}
	
	for(i=0; i<=numTreeNode; i++) {
		if(typeof(arrFolder[i]) != 'undefined') {
			var obj = document.getElementById('node' + i);
			if(arrFolder[i]){
				obj.className = "dTreeNode folder_show";
			} else {
				obj.className = "dTreeNode folder_hide";
			}
		}
	}
	//active checkboxes
	arrType.removeAttr('disabled');
	
	
	var endTime = jaStartBreakPoint();
	//alert(endTime - startTime);
}

function jaTreeApplyStatus(arr, status) {
	var startTime = jaStartBreakPoint();
	//var len = arr.length > 20 ? 20 : arr.length;
	var len = arr.length;
	for(i=0; i<len; i++){
		document.getElementById('node' + arr[i]).title = 'test';
		//document.getElementById('node' + arr[i]).style.display = status;
		/*if(i%5 == 0) {
			if(!(startTime = jaEndBreakPoint(startTime, 20))){
				return false;
			}
		}*/
	}
}

function jaUpdateCss(cssClass, attr, value) {
	jQuery(cssClass).css(attr, value);
}

/**
 * Sample to use debug code
 * add this code after line that you want to debug
 * [code]
 * 
 		var startTime = jaStartBreakPoint();
		if(!(startTime = jaEndBreakPoint(startTime, 100))){
			return false;
		}
 * [/code]
 */

function jaStartBreakPoint() {
	var dt = new Date();
	return dt.getTime();
}
function jaEndBreakPoint(start, limit) {
	var end = jaStartBreakPoint();
	var diff = end - start;
	if(diff > limit) {
		if( confirm('Slowly process! Do you want to continue?' + diff) ) {
			//update stat time
			return jaStartBreakPoint();
		} else {
			return 0;
		}
	}
	return start;
}

function jaTreeAddActionsExtend(product1, version1, product2, version2) {
	jQuery('div[class*=dTreeNode]').each(function(e){
		jQuery(this).mouseover(function(){
			jQuery(this).addClass('active');
		}).mouseout(function(){
			jQuery(this).removeClass('active');
		});
	});
	var titleViewSourceVer1 = "View the file on version " + version1 + " of element " + product1;
	var titleViewSourceVer2 = "View the file on version " + version2 + " of element " + product2;
	var titleCompare = "View Difference between version " + version1 + " of element " + product1 + " and version " + version2 + " of element " + product2;
	
	var allowedExtensions = /\.(?:php|php3|php4|php5|asp|aspx|jsp|phtml|inc|tpl|htm|html|xml|shtml|xhtml|sql|txt|js|css|ini)$/gi;
	//modified files
	jQuery('div[class*=dtree_status_update]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action">'
				+ '<a href="#" title="'+titleViewSourceVer1+'" class="compare" onclick="jaViewSource(\''+product1+'\',\''+version1+'\',\''+file+'\'); return false;">'+version1+'</a>'
				+ ' | <a href="#" title="'+titleViewSourceVer2+'" class="compare" onclick="jaViewSource(\''+product2+'\',\''+version2+'\',\''+file+'\'); return false;">'+version2+'</a>'
				+ ' | <a href="#" title="'+titleCompare+'" class="compare" onclick="jaCompareFilesExtend(\''+product1+'\',\''+version1+'\',\''+product2+'\',\''+version2+'\',\''+file+'\'); return false;">Compare</a>'
				+ '</span>'
			);
		}
	}); 
	
	//nochange files & removed files
	jQuery('div[class*=dtree_status_nochange],div[class*=dtree_status_removed]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action">'
				+ '<a href="#" title="'+titleViewSourceVer1+'" class="compare" onclick="jaViewSource(\''+product1+'\',\''+version1+'\',\''+file+'\'); return false;">'+version1+'</a>'
				+ '</span>'
			);
		}
	}); 
	
	//new files
	jQuery('div[class*=dtree_status_new]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		if(file.match(allowedExtensions)){
			jQuery(this).append(
				'<span class="action">'
				+ '<a href="#" title="'+titleViewSourceVer2+'" class="compare" onclick="jaViewSource(\''+product2+'\',\''+version2+'\',\''+file+'\'); return false;">'+version2+'</a>'
				+ '</span>'
			);
		}
	}); 
}



function jaCompareFilesExtend(product1, version1, product2, version2, file) {
	/*if(ja_ws_user == '') {
		jaOpenLoginBox();
	} else {*/
		var url = "?option=diff.files2&layout=blank";
		url += "&product1="+product1;
		url += "&ver1="+version1;
		url += "&product2="+product2;
		url += "&ver2="+version2;
		url += "&file="+file;
		JAOpenPopup(url, "", 'full', 'full') ;
	/*}*/
}
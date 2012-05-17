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
	jQuery('div[class*=dtree_status]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		jQuery(this).append(
			'<span class="action">'
			+ '<a href="#" title="'+title+'" class="compare" onclick="jaCompareConflictedFiles(\''+product+'\',\''+conflictedFolder+'\',\''+file+'\'); return false;">Compare</a>'
			+ '</span>'
		);
	}); 
	//view source links
	jQuery('div[class*=dtree_status]').each(function(e) {
		jQuery(this).find('a[id^=sd]').bind('click', function(e){
			var url = 'index.php?option=com_jaextmanager&tmpl=component&view=default&layout=view_source&cId[]='+product+'&file=' + jQuery(this).attr('title');
			JAOpenPopup(url, '', 'full', 'full');
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
	
	jQuery('div[class*=dTreeNode]').each(function(e){
		jQuery(this).mouseover(function(){
			jQuery(this).addClass('active');
		}).mouseout(function(){
			jQuery(this).removeClass('active');
		});
	});
	
	jQuery('div[class*=dtree_status_update]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		jQuery(this).append(
			'<span class="action"><strong>Compare<\/strong>: '
			+ '<a href="#" title="'+titleON+'" class="compare" onclick="jaCompareFiles(\'ON\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameON+'</a>'
			+ '</span>'
		);
	}); 
	jQuery('div[class*=dtree_status_bmodified]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		jQuery(this).append(
			'<span class="action"><strong>Compare<\/strong>: '
			+ '<a href="#" title="'+titleLN+'" class="compare" onclick="jaCompareFiles(\'LN\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameLN+'</a>'
			+ ' | '
			+ '<a href="#" title="'+titleLO+'" class="compare" onclick="jaCompareFiles(\'LO\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameLO+'</a>'
			+ ' | '
			+ '<a href="#" title="'+titleON+'" class="compare" onclick="jaCompareFiles(\'ON\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameON+'</a>'
			+ '</span>'
		);
	}); 
	jQuery('div[class*=dtree_status_umodified]').each(function(e) {
		var file = jQuery(this).find('a[id^=sd]').attr('title');
		jQuery(this).append(
			'<span class="action"><strong>Compare<\/strong>: '
			+ '<a href="#" title="'+titleLN+'" class="compare" onclick="jaCompareFiles(\'LN\',\''+product+'\',\''+newVersion+'\',\''+file+'\'); return false;">'+nameLN+'</a>'
			+ '</span>'
		);
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
			var url = 'index.php?option=com_jaextmanager&tmpl=component&view=default&layout=view_source&cId[]='+product+'&file=' + jQuery(this).attr('title');
			JAOpenPopup(url, '', 'full', 'full');
		});
	});
	//view source of new files on new version
	jQuery('div[class*=dtree_status_new]').each(function(e) {
		jQuery(this).find('a[id^=sd]').bind('click', function(e){
			var url = 'index.php?option=com_jaextmanager&tmpl=component&view=default&layout=view_remote_source&cId[]='+product+'&file=' + jQuery(this).attr('title')+'&version='+newVersion;
			JAOpenPopup(url, '', 'full', 'full');
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
	var rules = '';
	var len = document.styleSheets.length;
	
	for (var i=0; i<len; i++){
		var oCss = document.styleSheets[i];//object css
		if(i==0) {
			//detect rules
			if (oCss['rules']) {
				rules = 'rules';
			} else if (oCss['cssRules']) {
				rules = 'cssRules';
			}
		}
		if(rules == '') {
			break;
		}
		if(i<len-1) {
			//only update to last css file
			//cheat for this case only, to fix bug not response on ff
			continue;
		}
		
		found = false;
		for (var j = 0; j < oCss[rules].length; j++) {
			var oRule = oCss[rules][j];//object rules
			if (oRule.selectorText == cssClass) {
				if(oRule.style[attr]){
					oRule.style[attr] = value;
					found=true;
					break;
				}
			}
		}
		if(!found){
			if(oCss.insertRule){
				oCss.insertRule(cssClass+' { '+attr+': '+value+'; }',oCss[rules].length);
			} else if (oCss.addRule) {
				oCss.addRule(cssClass, attr+': '+value+';');
			}
		}
	}
	
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


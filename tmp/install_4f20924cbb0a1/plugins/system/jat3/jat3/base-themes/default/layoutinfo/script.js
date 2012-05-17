//for compartibility
//if is mootools ver 1.2 or above
if(MooTools.version.split(".")[1].slice(0,1) > 1){	
	//loadJsFile("mootools-1.1-to-1.2-upgrade-helper.js");
	var getSize = Element.prototype.getSize;
	Element.implement({	
		setHTML: function(){			
			return this.set('html', arguments);
		},
		getSize: function(){			
			var size = getSize.apply(this, arguments);
			return $merge(size, {
				size: size,
				scroll: this.getScroll(),
				scrollSize: this.getScrollSize()
			});
		},
		remove: function() {			
			return this.dispose.apply(this, arguments);
		}
	});
}

function getInternetExplorerVersion()
// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
{
  var rv = -1; // Return value assumes failure.
  if (navigator.appName == 'Microsoft Internet Explorer')
  {
    var ua = navigator.userAgent;
    var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
    if (re.exec(ua) != null)
      rv = parseFloat( RegExp.$1 );
  }
  return rv;
}
var ie_ver = getInternetExplorerVersion();

function loadJsFile(filename){
	var scripts = $$('script');
	var path = '';
	scripts.each (function(script){
	 if (script.src && script.src.test (/layoutinfo\/script\.js/)) path = script.src; 
	});	
	var src = path.slice(0, path.lastIndexOf("/")) + "/" + filename;	
	document.write("<script type='text/javascript' src='"+src+"'><\/script>");
}

loadJsFile("lang.js");

function _text(txt){
	if(t3lang == "en"){
		return txt;
	}else{
		return langObj[t3lang][txt];
	}
}

var data = jalayout;
var requestParams = {};
window.location.href.split('?')[1].split("&").each(function(e){
	requestParams[e.split("=")[0]] = e.split("=")[1];
});
var stick_blocks = true;
var show_content = true;

if(requestParams.allblocks){
	if(requestParams.allblocks == 1){
		stick_blocks = true;
	}else if(requestParams.allblocks == 0){
		stick_blocks = false;
	}
}

if(requestParams.content){
	if(requestParams.content == 1){
		show_content = true;
	}else if(requestParams.content == 0){
		show_content = false;
	}	
}

if(stick_blocks || show_content){
}else{
	stick_blocks = true;
}

window.addEvent('load', function() {
	(function (){
		initInfoTable();	
		loadEvents();
	}).delay(1000);	
});

function loadEvents(){
	hideOverlay();
	
	if(stick_blocks){
		$$("div.hover[id^=jainfo-block-]").removeClass("hover");
		$$("div[id^=jainfo-block-]").each(function(element, index){		
			//check element 
			var ele_id = element.getAttribute("id");
			if(ele_id.indexOf("cpanel") != -1){			
				return;
			}
			//
			var title = ele_id.replace("jainfo-block-", "");
			var eleToOverlay = element;		
			var blocksName = title.split(".")[0];
			if(blocksName == "top" || blocksName == "bottom"){		
				try{
					eleToOverlay = eleToOverlay.getElement('div').getElement('div.main');
				}catch(err){
				}
			}
			if(!eleToOverlay){
				eleToOverlay = element;
			}
			
			if(eleToOverlay){
				eleToOverlay.removeEvents().addEvents({  
					click: function(e) {				
						new Event(e).stop();				
					},  
					mouseenter: function() {
						loadInfoBox(ele_id);
					},  
					mouseleave: function() {
					}  
				});
				
				showOverlay(eleToOverlay, ele_id);
			}
			
		});
		
		//only for content-main		
		if($("ja-content-main")){
			$("ja-content-main").removeEvents().addEvents({  
				click: function(e) {  	
					new Event(e).stop();
				},  
				mouseenter: function() {
					loadInfoBox("content-main");				
				},  
				mouseleave: function() {			
				}  
			});
			
			showOverlay($("ja-content-main"), "content-main");
		}
		
		window.removeEvents("click");
	}else{
		$$("div[id^=jainfo-block-]").each(function(element, index){		
			//check element 
			var ele_id = element.getAttribute("id");
			if(ele_id.indexOf("cpanel") != -1){
				return;
			}
			//			
			var title = ele_id.replace("jainfo-block-", "");
			var eleToOverlay = element;		
			var blocksName = title.split(".")[0];
			if(blocksName == "top" || blocksName == "bottom"){		
				try{
					eleToOverlay = eleToOverlay.getElement('div').getElement('div');
				}catch(err){
				}
			}
			if(!eleToOverlay){
				eleToOverlay = element;
			}
			if(eleToOverlay){
				eleToOverlay.removeEvents().addEvents({  
					click: function(e) {				
						new Event(e).stop();				
					},  
					mouseenter: function() {
						$$("div.hover[id^=jainfo-block-]").removeClass("hover");
						element.addClass("hover");
						loadInfoBox(ele_id);
						hideOverlay();				
						showOverlay(eleToOverlay, ele_id);
					},  
					mouseleave: function() {					
					}  
				});
			}
			
		});
		
		//only for content-main
		if($("ja-content-main")){
			$("ja-content-main").removeEvents().addEvents({  
				click: function(e) {  	
					new Event(e).stop();
				},  
				mouseenter: function() {
					loadInfoBox("content-main");
					hideOverlay();				
					showOverlay(this, "content-main");
				},  
				mouseleave: function() {}
			});
		};	
		//
		window.removeEvents().addEvent("click", function(){
			hideOverlay();				
		});		
	}
	
	if(show_content){
		$(document.body).removeClass("jainfo-nocontent");		
	}else{
		$(document.body).addClass("jainfo-nocontent");
	}	
}

function showOverlay(eleToOverlay, block_ele_id){	
	
	var borderThick = 3;
	var title = block_ele_id.replace("jainfo-block-", "");
	
	eleToOverlay.set({
		styles: {	
			'position': 'relative'
		}
	});
	
	var overlay = eleToOverlay.getElements("div[class^=jainfo-block-overlay]");
	if(overlay.length > 0){
		overlay.each(function(e){
			e.remove();
		})
	}
	
	//check eleToOverlay, it may be zero! 
	if(!eleToOverlay.getSize().size || eleToOverlay.getSize().size.y < 1){
		eleToOverlay.setStyle("height", eleToOverlay.getParent().getSize().size.y);
	}
	overlay = new Element('div',{	
		'id': 'jainfo-block-overlay',
		'class': 'jainfo-block-overlay'		
	}).inject(eleToOverlay);
		
	var _W = parseInt(overlay.getSize().size.x) - borderThick * 2;
	var _H = parseInt(overlay.getSize().size.y) - borderThick * 2;
	if(_W < 0) _W = 0;
	if(_H < 0) _H = 0;
	
	var overlayBorder = new Element('div', {
		styles: {
			"width": _W,
			"height": _H
		}
	}).addClass('jainfo-block-overlay-border').inject(overlay);
		
	new Element('div',{		
		'id': 'jainfo-block-overlay-title',
		'class': 'jainfo-block-overlay-title'		 
	}).inject(eleToOverlay).setHTML(title);
	//return;
	var listModules = eleToOverlay.getElements('div[id^=jainfo-pos-]');
	if(listModules.length > 0){	
		
		listModules.each(function(ele){
			var ele_id = ele.getAttribute("id");
			ele_id = ele_id.replace("jainfo-pos-","");
			var title = "";
			//if this is content-main
			if(ele_id.split(".")[0] == "content"){
				title = "content" ;
			}else{
				title = ele_id.split(".")[1];
			}
			
			ele.set({
				styles: {
					'position': 'relative'
				}
			});
			
			ele.addEvents({
				mouseenter: function(){
					//load info box in case this event fires before block mouseenter
					loadInfoBox(block_ele_id);
					this.addClass("module-over");
					$('jainfo_table').getElements("span[class*=hover]").removeClass("hover");
					$('jainfo_table').getElements('span[id=jainfo-table-data-module-'+title+']').addClass("hover");
				},
				mouseleave: function (){
					this.removeClass("module-over");
					//$('jainfo_table').getElements('span[id=jainfo-table-data-module-'+title+']').removeClass("hover");
				}
			});
			
			var overlayW = ele.getSize().size.x;
			var overlayH = ele.getSize().size.y;
			/* if(title == "user1" || title == "user2"){
				alert(overlayW+"/"+overlayH);
			} */
			var moduleOverlay = new Element('div',{
				'class': 'jainfo-module-overlay',
				styles: {
					"width": overlayW,
					'height': overlayH
				}
			}).inject(ele);
		
			var overlayBorderW = overlayW - borderThick * 2;
			if(overlayBorderW<0){
				overlayBorderW = 0;
			}
			var overlayBorderH = overlayH - borderThick * 2;
			if(overlayBorderH<0){
				overlayBorderH = 0;
			}
			
			new Element('div', {
				'class': 'jainfo-module-overlay-border',
				styles: {
					"width": overlayBorderW,
					"height": overlayBorderH
				}
			}).inject(moduleOverlay);
			
			/* moduleOverlay.addEvents({
				mouseenter: function(){
					alert("s");
					this.addClass("module-over");
				},
				mouseleave: function (){
					this.removeClass("module-over");
				}
			}); */
			
			new Element('div',{				
				'class': 'jainfo-module-overlay-title'				
			}).inject(ele).setHTML(title);
		});
	}else{
		overlay.addClass("blank");
	}	
}

function hideOverlay(){	
	var eles = $$('.jainfo-block-overlay');
	if(eles){
		eles.each(function(e){
			//for mainnav
			if(e.getParent() && e.getParent().getParent() && e.getParent().getParent().getAttribute("id") == "ja-mainnav"){
				e.setStyle(	'opacity', 0.01 );
			}else{
				e.remove();	
			}			
		})
	}	
	eles = $$('.jainfo-block-overlay-title');
	if(eles){
		eles.each(function(e){
			e.remove();	
		})
	}
	eles = $$('.jainfo-module-overlay');
	if(eles){
		eles.each(function(e){
			e.remove();	
		})
	}
	eles = $$('.jainfo-module-overlay-title');
	if(eles){
		eles.each(function(e){
			e.remove();	
		})
	}
}

function loadInfoBox(id){
	var info_table_ct = $("jainfo-info-table-content");
	if(info_table_ct.getAttribute("block") == id){		
		return;
	}	
	info_table_ct.setAttribute("block", id);
	reloadInfoTable(id);
	id = id.replace("jainfo-block-", "");
	var blocks_name = id.split(".")[0];
	var block_name = id.split(".")[1];
	
	for(var i in data.children){
		
		if(data.children[i].name == "blocks" && data.children[i].attributes.name == blocks_name){			
			var blocks = data.children[i];
			for(var j in blocks.children){
				if(blocks.children[j].name == "block" && blocks.children[j].attributes.name == block_name){
					var block = blocks.children[j];
					
					for(var k in block.attributes){
						createInfoTableRow(k, block.attributes[k]);
					}					
					createInfoTableRow("data", block.data);
					
					break; //watch out
				}				
			}
			break;
		}
	}
}

function hideInfoBox(){	
	$('jainfo_table').removeClass("jainfo-table-full").addClass("jainfo-table-compact");
	$('jainfo-table-toggle-but').setHTML('show');
}

function showInfoBox(){	
	$('jainfo_table').removeClass("jainfo-table-compact").addClass("jainfo-table-full");
	$('jainfo-table-toggle-but').setHTML('hide');
}

function toggleShowHideInfoBox(){
	var container = $('jainfo_table');
	if(container.hasClass("jainfo-table-full")){
		 hideInfoBox();
	}else{
		showInfoBox();
	}
}

function reloadInfoTable(id){
	$("jainfo-info-table-content").empty();	
}

function initInfoTable(){
	var info_table = new Element('div',{
		id: 'jainfo_table',
		'class': "jainfo-info-table",
		events: {
			click: function(e){				
				new Event(e).stop();
			}
		}
	}).addClass("jainfo-table-full").inject(document.body);
		
	if(ie_ver == 6 || ie_ver == 7){		
		new Element("div", {
			"id" : "jainfo-info-table-error-box"
		}).setHTML("The template information works better with Firefox, Chrome, Safari, IE8 or above.").inject(info_table);
	}
	
	var container = new Element('div',{
		'id': 'jainfo-table-container'
	});
	
	info_table.adopt(container);
	
	var toggle_but = new Element('div',{
		'id': 'jainfo-table-toggle-but',
		'title': "Click to show/hide this board",
		'events': {
			click: function(e){
				//window.event.cancelBubble=true,
				new Event(e).stop();
				toggleShowHideInfoBox();
			}
		}
	}).inject(container).setHTML("hide");
	
	var close_but = new Element('div',{
		'id': 'jainfo-table-close-but',
		'title': "Click to exit this mode",
		'events': {
			click: function(e){
				$("jainfo_table").setStyle("display", "none");
				window.location.href = window.location.href.split('?')[0];				
			}
		}
	}).inject(container).setHTML("close");
	
	var optionsDiv = new Element('div',{		  
		"id": "jainfo-info-table-options"
	}).inject(container);
	
	var curClass = "";
	if(requestParams.tp && requestParams.tp == 1){
		curClass = "jainfo-opt-on";
		txt = _text("ON");
	}else{
		curClass = "jainfo-opt-off";
		txt = ("OFF");
	}
	optionsDiv.appendText(_text("Blank positions"));
	new Element('a',{
		'id': 'show_blank_positions_opt',
		'title': "Click to switch on/off",
		'href': "#",
		'class': curClass,
		'events': {
			click: function(e){
				new Event(e).stop();
				
				var query_opts = [];
				
				query_opts.push("t3info=1");
				
				if(stick_blocks){
					query_opts.push("allblocks=1");
				}else{
					query_opts.push("allblocks=0");
				}
				
				if(show_content){
					query_opts.push("content=1");
				}else{
					query_opts.push("content=0");
				}
				
				if(this.hasClass("jainfo-opt-on")){				
					//this.removeClass("jainfo-opt-on").addClass("jainfo-opt-off");										
				}else{
					//this.removeClass("jainfo-opt-off").addClass("jainfo-opt-on");
					query_opts.push("tp=1");
				}
				
				window.location.href = window.location.href.split('?')[0] + '?' + query_opts.join("&");	
			}
		}
	}).inject(optionsDiv).setHTML(txt);
	
	if(stick_blocks){
		curClass = "jainfo-opt-on";
		txt = _text("ON");
	}else{
		curClass = "jainfo-opt-off";
		txt = _text("OFF");
	}
	optionsDiv.appendText(_text("All blocks"));
	new Element('a',{
		'id': 'stick_all_blocks_opt',
		'title': "Click to switch on/off",
		'href': "#",
		'class': curClass,
		'events': {
			click: function(e){			
				new Event(e).stop();
				if(this.hasClass("jainfo-opt-on")){
					toggleAllBlocksOff();
				}else{
					toggleAllBlocksOn();
				}
				
				loadEvents();						
				toggleContentOn();
			}
		}
	}).inject(optionsDiv).setHTML(txt);
	
	/* new Element('input',{
		'type': 'button',
		'value': 'OK',
		'events':  {
			click: function(e){
				new Event(e).stop();
				//window.location.href
				var query_str = "";
				
				var stick_all_blocks_opt = $("stick_all_blocks_opt").checked ;
				if(stick_all_blocks_opt){
					query_str += "t3info=all";
				}else{
					query_str += "t3info=1";
				}
				//alert(stick_all_blocks_opt);
				var show_blank_positions_opt = $("show_blank_positions_opt").checked ;
				if(show_blank_positions_opt){
					query_str += "&tp=1";
				}				
				//alert(show_blank_positions_opt);
				window.location.href = window.location.href.split('?')[0] + '?' + query_str;				
			}
		},
	}).inject(optionsDiv);
	*/
	
	if(show_content){
		curClass = "jainfo-opt-on";
		txt = _text("ON");
	}else{
		curClass = "jainfo-opt-off";
		txt = _text("OFF");
	}
	optionsDiv.appendText(_text("Content"));
	new Element('a',{
		'id': 'toggle-content-but',
		'title': "Click to switch on/off",
		'href': "#",
		'class': curClass,
		'events':  {
			click: function(e){
				new Event(e).stop();
				//$(document.body).toggleClass("jainfo-nocontent");
				if(this.hasClass("jainfo-opt-on")){
					toggleContentOff();
				}else{
					toggleContentOn();
				}				
				toggleAllBlocksOn();				
				loadEvents();
			}
		}
	}).inject(optionsDiv).setHTML(txt);
	
	var titleDiv = 	new Element('div',{			  		  		  
		"id": "jainfo-info-table-title"  
	}).inject(container).setHTML(_text("Block infomation"));
	
	var titleDiv = 	new Element('div',{			  		  		  
		"id": "jainfo-info-table-content"  
	}).inject(container);
	
	info_table.makeDraggable({
		handle : optionsDiv,
		stopPropagation: true,	
		limit: {x: [0, null], y: [0, null]}
	});
}

function browserCompartiableAlert(){
	var info_table = new Element('div',{
		id: 'jainfo_table',
		'class': "jainfo-info-table",
		events: {
			click: function(e){				
				new Event(e).stop();
			}
		}
	}).inject(document.body);
	info_table.addClass("jainfo-table-full");
	//return;
	var container = new Element('div',{
		'id': 'jainfo-table-container'
	});
	
	info_table.adopt(container);	
	
	var close_but = new Element('div',{
		'id': 'jainfo-table-close-but',
		'title': "Click to exit this mode",
		'events': {
			click: function(e){
				window.location.href = window.location.href.split('?')[0];	
			}
		}
	}).inject(container).setHTML("close");
	new Element("div", {		
	}).setHTML("Internet Explorer 6 & 7 is not supported").inject(info_table);
	info_table.makeDraggable({
		stopPropagation: true,	
		limit: {x: [0, null], y: [0, null]}
	});
}

function toggleAllBlocksOn(){
	$("stick_all_blocks_opt").removeClass("jainfo-opt-off").addClass("jainfo-opt-on").setHTML("ON");	
	//$("stick_all_blocks_opt").setHTML("ON");
	stick_blocks = true;
}

function toggleAllBlocksOff(){
	$("stick_all_blocks_opt").removeClass("jainfo-opt-on").addClass("jainfo-opt-off").setHTML("OFF");	
	stick_blocks = false;
}

function toggleContentOn(){
	$("toggle-content-but").removeClass("jainfo-opt-off").addClass("jainfo-opt-on").setHTML("ON");					
	$(document.body).removeClass("jainfo-nocontent");	
	show_content = true;
}
function toggleContentOff(){
	$("toggle-content-but").removeClass("jainfo-opt-on").addClass("jainfo-opt-off").setHTML("OFF");					
	$(document.body).addClass("jainfo-nocontent");	
	show_content =  false;	
}

function createInfoTableRow(label, data){
	
	var info_table = $('jainfo-info-table-content');
	
	var rowDiv = new Element('div',{			  		  		  
		"class": "jainfo-info-table-row"    
	}).inject(info_table);
	
	var labelDiv = new Element('div',{		  			
		"class": "jainfo-info-table-row-title" 	  
	}).inject(rowDiv);
	
	if(label == "data"){
		var dataDiv = new Element('div',{
			"class": "jainfo-info-table-row-data"
		}).inject(rowDiv);
		
		if(data.trim().length > 0){			
			data.split(",").each(function(e){
				var ele = new Element('span',{ "id": "jainfo-table-data-module-" + e}).addClass("ja-module-tag tag-rounded").inject(dataDiv).setHTML(e);
				var mod_content = "";
				try{
					mod_content = $('jainfo-pos-pos.' + e).getElement('div').getElement('div').innerHTML;
				}catch(err){}
				
				if(mod_content == "" || mod_content.trim() == e ){
					ele.addClass('no-content');
				}else{
					ele.addClass('has-content');
				}
			});			
		}else{
			dataDiv.setHTML("&nbsp;");
		}
	}else{
		new Element('div',{		
			"class": "jainfo-info-table-row-data" 	
		}).inject(rowDiv).setHTML(data);			
	}
	
	switch(label){
		case "data":
			labelDiv.setHTML("module position(s)");
			break;
		case "parent":
			labelDiv.setHTML("area");
			break;
		default:
			labelDiv.setHTML(label);			
	}	
}
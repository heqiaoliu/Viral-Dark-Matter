/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */

JAFormController_T3 = new Class( { 
	data: {},
	elements: [],
	controls: [],
	
	_: function (name) {
		if (!name) return ''; 
		return name.replace(/\[|\]/g, '_')
	},
	
	add: function (control, options) {		
		var control_name = options.group+'['+control+']';
		options = $extend ({'group': 'params', 'hideRow': true, 'control':control_name}, options);
		options.hideRow = Boolean(options.hideRow); 
		if (!this.controls.contains(control_name)) this.controls.push (control_name);
		//elements
		var els = options.els_str.split(',');
		els.each (function(el){
			var el_name = options.group+'['+el.trim()+']';			
			if (!this.elements.contains(el_name)) {
				this.elements.push (el_name);
				this.data[this._(el_name)] = [];
			}
			this.data[this._(el_name)].push (this._(control_name) + '_' + options.val);
			this.data[this._(control_name) + '_' + options.val] = options;
		}, this);
	},
	
	update: function () {
		var activelist = [];
		this.elements.each (function(el){
			//this element will be active if one of its parents active & selected
			this.data[this._(el)].each (function (ctrl_val) {
				if (!this.isActive (this.data[ctrl_val].control)) {
					if (activelist.contains (el)) activelist.erase (el);
					//make this disable
					this.disable (el);
				} else if (this.isSelected (this.data[ctrl_val])) {
					//put to active list
					if (!activelist.contains (el)) activelist.push (el);
					//make this enable
					this.enable (el);
				} else {
					if (!activelist.contains (el)) this.disable (el); 
				}
			}, this);
		}, this);
/*		
		//make active list enable
		activelist.each (function(el){
			this.enable (el);
		}, this);
 */		
		//disable elements not in activelist
		this.elements.each (function(el){
			if (!activelist.contains (el)) this.disable (el);
		}, this);
		
		this.updateHeight.delay(100, this);
	},
	
	isActive: function (control) {
		if (this.elements.contains (control)) {
			this.data[this._(control)].each (function(el) {
				var options = this.data[el]; //parent options
				if (!this.isSelected (options) || !this.isActive (options.control)) return false;
			}, this);			
		}
		return true;
	},
	
	isSelected: function (options) {
		var group = this.getElement(options.control);
		var val = options.val;

		if(group){
			var type = $type(group);
			if(type == 'collection' || type == 'array'){
				for(var i=0; i<group.length; i++){
					var subgroup = group[i];
					if(!val || ((this.getParentByTagName (subgroup, 'tr').getStyle ('display') != 'none' && !subgroup.disabled) && (subgroup.id && subgroup.value.trim()==val && ( subgroup.type!='radio' || subgroup.checked))  ))
						return true;
				}
			} else {
				if (!val || ( (this.getParentByTagName (group, 'tr').getStyle ('display') != 'none' && !group.disabled) && (group.value.trim()==val)))
					return true;
			}
		}
		return false;
	},
	
	toggle_el: function (el, status, hideRow) {
		var obj = el;
		if (hideRow) {
			var val = status?'table-row':'none';
			if (this.getParentByTagName (el, 'tr')) obj = this.getParentByTagName (el, 'tr');
			if(obj!=null){
				obj.setStyle ('display', val);
			}
		} else {
			var val = status?'':'disabled';
			obj.disabled = val;
		}
	}, 
	
	enable: function (el) {
		var el_ = this.getElement(el);
		var options = this.data[this.data[this._(el)][0]];
		var type = $type(el_);
		if(type == 'collection' || type == 'array'){
			for(var i=0; i<el_.length; i++){
				this.toggle_el ($(el_[i]), true, options.hideRow);
			}
		} else {
			this.toggle_el ($(el_), true, options.hideRow);
		}
	},
	
	
	disable: function (el) {
		var options = this.data[this.data[this._(el)][0]];
		var el_ = this.getElement(el);
		var type = $type(el_);
		if(type == 'collection' || type == 'array'){
			for(var i=0; i<el_.length; i++){
				this.toggle_el ($(el_[i]), false, options.hideRow);
			}
		} else {
			this.toggle_el ($(el_), false, options.hideRow);
		}
	},
	
	start: function( ){
		//build list 
		this.controls.each (function (control) {
			//control elements
			var group = this.getElement(control);
			
			//bind event
			if(group){
				var type = $type(group);
				if(type == 'collection' || type == 'array'){
					for(var i=0; i<group.length; i++){
						var subgroup = $(group[i]);
						
						if (subgroup.type == 'select-one' || subgroup.type == 'select-multiple'){
							subgroup.addEvent('change', function(){
								this.update();
							}.bind(this));
						}
						else{
							subgroup.addEvent('click', function(){
								this.update();
							}.bind(this));
						}
					}				
				}
				else{
					var group = $(group);
					if (group.type == 'select-one' || group.type == 'select-multiple'){
						group.addEvent('change', function(){
							this.update();
						}.bind(this));
					}
					else{
						group.addEvent('click', function(){
							this.update();
						}.bind(this));
					}
				}
			}
			
		}, this);
		this.update();
	},		
	
	updateHeight: function () {
		$$('.jpane-slider').each(function(el){
			if(el.offsetHeight>0){
				el.setStyle('height', el.getElement('fieldset.panelform').offsetHeight);
			}
		});
		window.fireEvent('resize');
	},
	
	getParentByTagName: function (el, tag) {
		if(el){
			var parent = $(el).getParent();
			if(parent){
				while (!parent || parent.tagName.toLowerCase() != tag.toLowerCase()) {
					parent = parent.getParent();
				}
				return parent;
			}
		}
		return null;
	},

	getElement: function(el_name){
		var el = $(document.adminForm)[el_name];
		if(el==undefined) el = $(document.adminForm)[el_name+'[]'];
		return el;
	} 
});


var japaramhelper_t3 = new JAFormController_T3();

function japh_addgroup_t3 (control, options) {
	japaramhelper_t3.add (control, options);
}

window.addEvent('load', function() {
	japaramhelper_t3.start.delay (100, japaramhelper_t3);
});

function getParentByClassName (el, classname) {
	if($(el)){
		var parent = $(el).getParent();
		if(parent!=null){
			while (parent!=null && !parent.hasClass(classname)) {
				parent = parent.getParent();
			}
			return parent;
		}
	}
	return null;
}

function addClassToTR(){
	var trObject 	= $(document.body).getElements("table.paramlist")
	trObject		= $(trObject[0]).getElements("tr");
	
	var level = "";
	var newLevel = false;
	
	for(i=0; i < trObject.length; i++){
		html = trObject[i].innerHTML.toUpperCase();
		
		if( html.indexOf("<H4") >= 0){
			level = $(trObject[i]).getElement("h4").getProperty("rel");
			newLevel = false;
		}else{
			if( html.indexOf("PARAMLIST_KEY") >= 0  ){
				if(level != "" &&  !newLevel  ){
					level = parseInt(level) + 1;
					newLevel = true;
				}
			}
		}
		if( level != "" )
			$(trObject[i]).addClass("level"+level);
	};
}

//Control show/hide Region:
function showGroup(regionID){
	$$('#'+regionID+' tr').each(function (tr){
		tr.removeClass('disable-row');
		tr.addClass('enable-row');		
		
		var h4 = tr.getFirst().getElement('h4.block-head');
		if($type(h4)){
			 h4.removeClass("open");
			 h4.removeClass("close");
			 h4.addClass("open");
		}		
	});	
	//$(regionID).setStyle('height', $(regionID).getFirst().offsetHeight);
	japaramhelper_t3.updateHeight();
	window.fireEvent('resize');
}

function hideGroup(regionID){
	$$('#'+regionID+' tr').each(function (tr){		
		var h4 = tr.getFirst().getElement('h4.block-head');
		if($type(h4)){
			tr.removeClass('disable-row');
			tr.addClass('enable-row');		
			h4.removeClass("open");
			h4.removeClass("close");
			h4.addClass("close");
		}
		else{
			tr.removeClass('enable-row');
			tr.addClass('disable-row');		
		}
	});
	//$(regionID).setStyle('height', $(regionID).getFirst().offsetHeight);
	japaramhelper_t3.updateHeight();
	window.fireEvent('resize');
}


// Control show/hide Region:
function showRegion(regionID, level){
	var tr = $(regionID).getParent().getParent();
	
	while( tr.getNext()!=null && $(tr.getNext().getFirst()).getElement('h4.block-head')==null){
		var h4 = tr.getNext().getFirst().getElement('h4.block-head');
		if($type(h4)){
			 h4.removeClass("open");
			 h4.removeClass("close");
			 h4.addClass("open");
		}
		tr.getNext().removeClass('disable-row');
		tr.getNext().addClass('enable-row');
		tr = tr.getNext();
	}	
    $(regionID).removeClass("open");
    $(regionID).removeClass("close");
    $(regionID).addClass("open");  
}

function hideRegion(regionID, level){
	var tr = $(regionID).getParent().getParent();
	while( tr.getNext()!=null && $(tr.getNext().getFirst()).getElement('h4.block-head')==null){
		var h4 = $(tr.getNext().getFirst()).getElement('h4.block-head');
		if($type(h4)){
			 tr.getNext().removeClass('disable-row');
			 tr.getNext().addClass('enable-row');			
			 h4.removeClass("open");
			 h4.removeClass("close");
			 h4.addClass("close");
		}
		else{
			tr.getNext().removeClass('enable-row');
			tr.getNext().addClass('disable-row');			
		}
		
		tr = tr.getNext();
	}	
    
    $(regionID).removeClass("open");
    $(regionID).removeClass("close");
    $(regionID).addClass("close");
    
    japaramhelper_t3.updateHeight();
    window.fireEvent('resize');   
}
function showHideRegion(regionID, level){
	if($(regionID).className.indexOf('close')>-1){
		showRegion(regionID, level);
	}
	else if($(regionID).className.indexOf('open')>-1){
		hideRegion(regionID, level);
	}
	
	/*$$('.jpane-slider').each(function (el){
		if(el.getElement('fieldset.panelform')!=null){
			el.setStyle('height', el.getElement('fieldset.panelform').offsetHeight)
		}
	})*/
	japaramhelper_t3.updateHeight();
	window.fireEvent('resize');
}

function updateFormMenu(obj, changeHeight){
	if(!obj) return;
	switch(obj.value.trim()){
		case '0':
			$('jformparamsmega_subcontent_mod_modules').getParent().setStyle('display', 'none');
			$('jformparamsmega_subcontent_pos_positions').getParent().setStyle('display', 'none');
			break;
		case 'mod':
			$('jformparamsmega_subcontent_mod_modules').getParent().setStyle('display', 'block');
			$('jformparamsmega_subcontent_pos_positions').getParent().setStyle('display', 'none');
			break;
		case 'pos':
			$('jformparamsmega_subcontent_mod_modules').getParent().setStyle('display', 'none');
			$('jformparamsmega_subcontent_pos_positions').getParent().setStyle('display', 'block');
			break;
	}
	if(changeHeight){
		$('mega-params-options').getNext().setStyle('height', $('mega-params-options').getNext().getElement('fieldset.panelform').offsetHeight)		
		window.fireEvent('resize');
	}
}
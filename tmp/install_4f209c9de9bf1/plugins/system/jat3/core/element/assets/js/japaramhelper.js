/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

JAFormController = new Class( {
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
					if (activelist.contains (el)) activelist.remove (el);
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
		
		this.updateHeight();
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
					if(!val || ((subgroup.getStyle ('display') != 'none' && !subgroup.disabled) && (subgroup.id && subgroup.value.trim()==val && ( subgroup.type!='radio' || subgroup.checked))  ))
						return true;
				}
			} else {
				if (!val || ( (group.getStyle ('display') != 'none' && !group.disabled) && (group.value.trim()==val)))
					return true;
			}
		}
		return false;
	},
	toggle_el: function (el, status, hideRow) {
		var obj = el;
		if (hideRow) {
			var val = status?'table-row':'none';
			obj = this.getParentByTagName (el, 'tr');
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
		/*_dparent = $('plugin-pane').getElement('div.jpane-slider');
		_tparent = _dparent.getElement('table.paramlist');
		if (_tparent && _dparent && _dparent.hasClass('content') && _dparent.offsetHeight){
			_dparent.setStyle('height', _tparent.offsetHeight);
		}*/
		window.fireEvent('resize');
		if(window.jatabs!=undefined){
			jatabs.resize();
		}
	},
	
	getParentByTagName: function (el, tag) {
		if($(el)){
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

var japaramhelper = new JAFormController();

function japh_addgroup (control, options) {
	japaramhelper.add (control, options);
}

window.addEvent('load', function() {
	addClassToTR();
	japaramhelper.start.delay (100, japaramhelper);
});

function addClassToTR(){
	var tablesObject 	= $(document.body).getElements("table.paramlist");
	for(var j=0; j<tablesObject.length; j++){
		trObject		= $(tablesObject[j]).rows;
		
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
	
}

// Control show/hide Region:
function showRegion(regionID, level){
	var tr = $(regionID).getParent().getParent();
	level = level.toUpperCase().clean();
	
	while( tr.getNext()!=null && tr.getNext().className.toUpperCase().clean().indexOf(level)==-1){
		var h4 = $E('h4.block-head', tr.getNext().getFirst());
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
	if($type(jatabs)){
		jatabs.resize();
	}
}

function hideRegion(regionID, level){
	var tr = $(regionID).getParent().getParent();
	level = level.toUpperCase().clean();
	while( tr.getNext()!=null && tr.getNext().className.toUpperCase().clean().indexOf(level)==-1){
		var h4 = $E('h4.block-head', tr.getNext().getFirst());
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
	if($type(jatabs)){
		jatabs.resize();
	}
}
function showHideRegion(regionID, level){
	if($(regionID).className.indexOf('close')>-1){
		showRegion(regionID, level);
	}
	else if($(regionID).className.indexOf('open')>-1){
		hideRegion(regionID, level);
	}	  
}

function updateFormMenu(obj, changeHeight){
	if(!obj) return;
	switch(obj.value.trim()){
		case '0':
			$('paramsmega_subcontent_mod_modules').getParent().getParent().setStyle('display', 'none');
			$('paramsmega_subcontent_pos_positions').getParent().getParent().setStyle('display', 'none');
			break;
		case 'mod':
			$('paramsmega_subcontent_mod_modules').getParent().getParent().setStyle('display', 'table-row');
			$('paramsmega_subcontent_pos_positions').getParent().getParent().setStyle('display', 'none');
			break;
		case 'pos':
			$('paramsmega_subcontent_mod_modules').getParent().getParent().setStyle('display', 'none');
			$('paramsmega_subcontent_pos_positions').getParent().getParent().setStyle('display', 'table-row');
			break;
	}
	
	if(changeHeight){
		$('mega-params-options').getNext().setStyle('height', $('mega-params-options').getNext().getElement('table.paramlist').offsetHeight)		
		window.fireEvent('resize');
	}
}
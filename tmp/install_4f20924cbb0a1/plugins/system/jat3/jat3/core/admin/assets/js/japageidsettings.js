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

var JAT3_PAGEIDSETTINGS = new Class({
	Implements: Options,
	
	options: {
		param_name:			null,
		page_select: 		null,
		theme_select: 		null,
		activePopIn:		0,
		obj_theme_select:	null
	},
	initialize: function(options) {
		this.setOptions(options);		
	},
	
	choosePageids: function (obj, k){
		obj = $(obj)
		if(!$type(k)){
			k = this.options.page_select;
		}
		
		values = obj.get('text').trim();
		this.close_popup(this.options.param_name + '-ja-popup-profiles');
		this.options.page_select = parseInt(k);
		
		var selected = values.split(',');
		for(var i=0; i<selected.length; i++){
			selected[i] = selected[i].clean();
		}
		
		var selections = $(this.options.param_name + '-selections');
		var all_pageids_selected = this.get_all_pageids_selected();
		
		for (var i=0; i<selections.length; i++){
			selections[i].selected = false;
			selections[i].disabled = false;
			if(all_pageids_selected.contains(selections[i].value.clean())){
				selections[i].onclick = function(){void(0)};
				selections[i].disabled = true;
			}		
			
			if(selected.contains(selections[i].value.clean())){
				selections[i].disabled = false;
				selections[i].selected = true;
			}		
		}
		
		this.setPosition_for_poup($(this.options.param_name + '-ja-popup-pageids'), obj)
		
		this.options.activePopIn = 0;return;
	},
	
	chooseProfile: function (obj, k){
		obj = $(obj);
		if($type(k)){
			this.options.theme_select = k;
		}
		else{
			k = this.options.theme_select;
		}
				
		this.close_popup(this.options.param_name + '-ja-popup-pageids');
		
		this.options.obj_theme_select = obj;
		var selected = obj.get('text').trim().toLowerCase();
		var selections = $$('#' + this.options.param_name + '-ja-popup-profiles li');
				
		for (var i=0; i<selections.length; i++){
			selections[i].removeClass('active');			
			if(selections[i].get('text').trim().toLowerCase()==selected){
				selections[i].addClass('active');
			}
		}
		
		this.options.activePopIn = 0;
		this.setPosition_for_poup($(this.options.param_name + '-ja-popup-profiles'), obj);
	},
	
	add_chooseProfile: function (obj, k){
		obj = $(obj);
		this.chooseProfile(obj, k);
		obj.setOpacity('1');
	},
	
	setPosition_for_poup: function (popup_obj, position_obj){
		var position = position_obj.getPosition();
		var height = position_obj.offsetHeight;		
		popup_obj.setStyles({top: position.y + height, left: position.x, display:'block'});
		$(this.options.param_name + '-ja-popup-pageids').setStyle('width', $(this.options.param_name + '-selections').offsetWidth);
	},
	
	close_popup: function (divid){
		$(divid).setStyle('display', 'none');
	},
	
	select_multi_pageids: function (){
		this.close_popup(this.options.param_name + '-ja-popup-pageids');
		var selections = $(this.options.param_name + '-selections');
		var selected = new Array();
		for (var i=0; i<selections.length; i++){
			if(selections[i].selected){
				selected += selections[i].value + ', ';
			}
		}
		if(selected.length>0) selected =  selected.substring(0, selected.length-2);
		if(parseInt(this.options.page_select)>-1 && selected!=''){			
			$(this.options.param_name + '-row-' + this.options.page_select).getFirst().getFirst().set('text', selected);
			$(this.options.param_name + '-row-' + this.options.page_select).getFirst().getFirst().removeClass('more');
			this.buildData_of_param();		
		}
	},
	
	select_profile: function (obj){
		obj = $(obj);
		var value = obj.get('text').trim();
		this.close_popup(this.options.param_name + '-ja-popup-profiles');
		
		if(obj.getParent().className.indexOf('active')>-1){
			return;
		}
		
		this.options.obj_theme_select.removeClass('active');
		if(parseInt(this.options.theme_select)>-1 && value!=''){			
			var new_el = this.options.obj_theme_select;
			new_el.set('text',value);
			new_el.setStyle('display', 'inline');
			new_el.removeClass('more');	
			$('ja-tabswrap').getElement('li.general').addClass('changed');
			this.buildData_of_param();
		}
	}, 
	
	addrow: function (obj) {
		obj = $(obj);
		var table = $(this.options.param_name + '-ja-list-pageids');
		var k = table.rows.length-1;
		
		this.options.page_select = k;
		this.options.theme_select = k;
		
		var last = table.rows[k];
		
		var li = $(last).clone();
		li.injectAfter(last);
		last.set({'id': this.options.param_name + '-row-'+k });
		
		var args = new Array(last.getElement('span.pageid_text'), k);
		last.getElement('span.pageid_text').addEvent('click', this.choosePageids.pass(args, this));
		
		var args = new Array(last.getElement('span.profile_text'), k);
		last.getElement('span.profile_text').addEvent('click', this.add_chooseProfile.pass(args, this));
		
		last.getElement('span.ja_close').addEvent('click', this.removerow.bind(this, last.getElement('span.ja_close')));
				
		if(obj==last.getFirst()){
			this.choosePageids(obj.getElement('span.pageid_text'), k);
		}
		if(obj==last.getChildren()[1]){
			this.add_chooseProfile(obj.getElement('span.profile_text'), k);
		}
		
		obj.getFirst().setOpacity(1);
		obj.getNext().getFirst().setOpacity(1);
		obj.getNext().getNext().getElement('img').setOpacity(1);
		
		last.setOpacity('1');
		last.getElement('span.ja_close').setStyle('display', '');
		last.getFirst().onclick = function (){void(0)};
		last.getChildren()[1].onclick = function (){void(0)};
		
		if($type(jatabs)){
			jatabs.resize();
		}
		
	},
	
	removerow: function (obj){
		obj = $(obj);
		$(obj.parentNode.parentNode).destroy();
		this.buildData_of_param();
	},
	
	buildData_of_param: function (){
		var params = $(this.options.param_name + '-profile');
		params.value = '';
		var els = $(this.options.param_name+'-ja-list-pageids').getElements ('tr.ja-item');
		var length = els.length-1;
		
		els.each(function (el, i){
			if($type( el.getElement('span.pageid_text' ) ) && el.getElement('span.pageid_text').get('text').trim()!='' && el.getElement('span.profile_text').get('text').trim()!='')
			{
				if(!i){
					params.value += 'all';
				}
				else{
					params.value += el.getElement('span.pageid_text').get('text').trim();
				}
				
				params.value += '=';
				params.value += el.getElement('span.profile_text').get('text').trim();
				if(i<length){
					params.value += '\n';
				}
			}
		});			
	},
	
	deleteTheme: function (obj){	
		obj = $(obj);
		$(obj).getPrevious().destroy();	
		$(obj).destroy();	
		this.buildData_of_param();
	},
	
	get_all_pageids_selected: function (){
		var all_pageids_selected = new Array();
		var k = 0;
		var els = $$('.ja-list-pageids tr.ja-item');
		
		els.each(function (el){
			if($type( el.getElement('span.pageid_text') ) && el.getElement('span.pageid_text').get('text').trim()!='')
			{
				var tem =  el.getElement('span.pageid_text').get('text').trim().split(',');
				for(var j=0; j<tem.length; j++){
					all_pageids_selected[k] = tem[j].clean();
					k++;
				}
			}
		});		
		return all_pageids_selected;
	},
	
	clearData: function(){		
		
		if (this.options.activePopIn == 1) {
			$(this.options.param_name + '-ja-popup-profiles').setStyle('display', 'none');
			$(this.options.param_name + '-ja-popup-pageids').setStyle('display', 'none');
			this.options.activePopIn = 0;
		}	
		this.options.activePopIn = 1;	
		if(parseInt(this.options.theme_select)>-1 && 
				$type($(this.options.param_name + '-row-' + this.options.theme_select)) && 
				$type($(this.options.param_name + '-row-' + this.options.theme_select).getElement('span.active')))
		{
			$(this.options.param_name + '-row-' + this.options.theme_select).getElement('span.active').removeClass('active');
		}
		
	}
});
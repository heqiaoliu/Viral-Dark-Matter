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

var JAT3_THEMESETTINGS = new Class({	
	initialize: function(options) {
		this.options = $extend({
			param_name:			null,
			activePopIn:		0,
			obj_theme_select:	null
		}, options || {});
		
		this.element = $(this.options.param_name + '-ja-list-themes').getElement ('.ja-themes');
		this.action = $(this.options.param_name + '-ja-list-themes').getElement ('.ja-theme-edit');
		this.data = $(this.options.param_name).value;
	},
	
	chooseThemes: function (obj){
		obj = $(obj);
		var selections = $$('#' + this.options.param_name + '-ja-popup-themes li');
		
		var data = this.data.split (',');
		
		for (var i=0; i<selections.length; i++){
			if (selections[i].hasClass ('default')) continue;
			var theme = selections[i].getElement ('.theme');
			var cb = selections[i].getElement ('.cb-span');
			if (!theme || !cb) continue;
			var base = theme.hasClass ('local')?'local':'core';
			var name = theme.getText();
			if (data.contains (name) || data.contains (base + '.' + name)) {
				selections[i].addClass ('selected');
				cb.checked = true;
				cb.addClass ('cb-span-checked');
			} else {
				selections[i].removeClass ('selected');
				cb.checked = false;
				cb.removeClass ('cb-span-checked');
			}
		}
		
		this.options.activePopIn = 1;
		this.setPosition_for_poup($(this.options.param_name + '-ja-popup-themes'), obj);
	},
	
	setPosition_for_poup: function (popup_obj, position_obj){
		var position = position_obj.getPosition();
		var height = position_obj.offsetHeight;		
		popup_obj.setStyles({top: position.y + height, left: position.x, display:'block'});
	},
	
	close_popup: function (divid){
		$(divid).setStyle('display', 'none');
	},	
		
	get_all_themes_selected_on_row: function (){
		return;
		var all_themes_selected = new Array();
		var i = 0;
		var els = $$('#' + this.options.param_name + '-ja-list-themes span.theme_text');
		els.each( function (el){
			if(el.getText().trim()!=''){
				all_themes_selected[i] =  el.getText().trim();
				i++;
			}
		});		
		return all_themes_selected;
	},
	
	
	clearData: function(){		
		if (this.options.activePopIn == 1) {
			$(this.options.param_name + '-ja-popup-themes').setStyle('display', 'none');
			this.options.activePopIn = 0;
			var els = $(this.options.param_name +'-ja-list-themes').getChildren();
			els.each( function (el){
				el.removeClass('active');
			});		
		}	
	},
	
	apply: function (event) {
		if ($(this.options.param_name + '-ja-popup-themes').getStyle ('display') == 'none') return;
		$(this.options.param_name + '-ja-popup-themes').setStyle('display', 'none');
		var els = $(this.options.param_name +'-ja-popup-themes').getElements('li.selected');
		if (!els) return;
		data = [];
		els.each (function(el){
			var theme = el.getElement('.theme');
			if (theme) {
				data.push ((theme.hasClass('local')?'local':'core')+'.'+theme.getText().trim());
			}
		},this);
		if(!Cookie.get('ja-change-theme-help') && $(this.options.param_name + '-ja-change-theme-help').getStyle('visibility')=='hidden'){
			this.tip = $(this.options.param_name + '-ja-change-theme-help');
			this.tip.show();
			$clear(this.timer);			
			this.timer = this.show.delay(100, this);
		}
		this.update (data.join (','), this.data);
	},
	cancel: function () {
		$(this.options.param_name + '-ja-popup-themes').setStyle('display', 'none');
	},
	show: function(){
		
		this.showFade (this.tip);
	},
	
	hide: function(){
		if($('jachangethemecheckbox').checked){
			Cookie.set('ja-change-theme-help', true, 365);
		}
		$clear(this.timer);
		this.hideFade (this.tip);
	},
	
	showFade: function (tip) {	
		if (!tip.fx) tip.fx = new Fx.Styles(tip);
		tip.fx.stop();		
		pos = $(this.options.param_name + '-ja-list-themes').getPosition();
		posy = pos.y - $E('.center-bottom', this.options.param_name + '-ja-change-theme-help').offsetHeight;
		tip.setStyle('left', pos.x-100);
		var curopac = tip.getStyle('opacity');
		tip.fx.start({
			'top': [posy, posy-10],			
			'opacity': [curopac,1]
		});	
	},
	
	hideFade: function (tip) {
		if (!tip.fx) tip.fx = new Fx.Styles(tip);
		tip.fx.stop();
		var curopac = tip.getStyle('opacity');
		tip.fx.start({
			'top': [this.tip.getPosition().y, this.tip.getPosition().y+20],
			'opacity': [curopac, 0]
		});	
	},
		
	update: function (new_data, curr_data) {
		var data = [];
		curr_data = curr_data?curr_data.split (','):[];
		new_data = new_data.split (',');
		curr_data.each (function (el){
			if (new_data.contains (el) && (all_themes.contains(el) || el=='default')) data.push (el);
		});
		new_data.each (function (el){
			if (!curr_data.contains (el) && (all_themes.contains(el) || el=='default')) data.push (el);
		});
		if (this.element.getElements ('.ja-theme')) this.element.getElements ('.ja-theme').each (function (el){el.remove()});
		
		data.each (function (theme) {
			theme = theme.trim();
			if (!theme) return;
			var base = 'core';
			var name = theme;
			theme = theme.split ('.');
			if (theme.length > 1) {
				base = theme[0];
				name = theme[1];
			}
			
			var el = new Element ('span', {'class':'ja-theme'});
			el.setText (name);
			el.addClass (base);
			el.inject (this.element);
			//el.inject (this.element);
		}, this);
		
		this.data = data.join (',');
		$(this.options.param_name).value = this.data;
		//make sortable
		new HSortables(this.element, {constrain: true, clone: true, opacity: 0.9, onComplete: this.buildData.bind(this)});		
	},
	
	buildData: function () {
		var themes = this.element.getElements ('.ja-theme');
		var value = '';
		if (themes) {
			var data = [];
			themes.each (function (theme) {
				data.push ((theme.hasClass('local')?'local':'core')+'.'+theme.getText().trim());
			});
			value = data.join (',');
		}
		this.data = value;
		$(this.options.param_name).value = this.data;
		return this.data;
	}
});

function jathemesettings_disable(name){
	var els = $(name + '-ja-list-themes').getElements('span');
	$(name + '-ja-list-themes').getElement('span.ja-theme-edit').removeEvents();
}

function jathemesettings_enable(name){
	var els = $(name + '-ja-list-themes').getElements('span');
	els.each (function (el){
		var args = new Array(el, name);
		el.disabled = false;
	});
	
	$(name + '-ja-list-themes').getElement('span.ja-theme-edit').addEvent ('click', function (event) {
		jaclass[name].chooseThemes(this);
		new Event(event).stop();
	});
}

function jathemesettings_getValue(name){
	return $(name).value.trim();
}

function enable_el(event, el, name){
	return;
	if (el.disabled) return;
	if(el.hasClass('theme_text')){
		jaclass[name].chooseThemes(el);
	}
	else if(el.hasClass('theme_delete')){
		jaclass[name].deleteTheme(el);
	}	
	event.stop();
	return false;
}

function jathemesettings_setValue(name, data){
	jaclass[name].update (data);	
}
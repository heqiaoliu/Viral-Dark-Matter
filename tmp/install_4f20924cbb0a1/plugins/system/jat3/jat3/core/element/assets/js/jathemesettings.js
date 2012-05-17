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

var JAT3_THEMESETTINGS = new Class({	
	
	Implements: Options,
	
	options: {
		param_name:			null,
		activePopIn:		0,
		obj_theme_select:	null
	},
	
	initialize: function(options) {
		this.setOptions(options);
		
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
			var name = theme.get('text');
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
			if(el.get('text').trim()!=''){
				all_themes_selected[i] =  el.get('text').trim();
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
				data.push ((theme.hasClass('local')?'local':'core')+'.'+theme.get('text').trim());
			}
		},this);
		if(!Cookie.read('ja-change-theme-help') && $(this.options.param_name + '-ja-change-theme-help').getStyle('visibility')=='hidden'){
			this.tip = $(this.options.param_name + '-ja-change-theme-help');
			this.tip.setStyle('visibility', 'visible');
			this.tip.show();
			$clear(this.timer);			
			this.timer = this.showTip.delay(100, this);
		}
		this.update (data.join (','), this.data);
	},
	cancel: function () {
		$(this.options.param_name + '-ja-popup-themes').setStyle('display', 'none');
	},
	showTip: function(){		
		this.showFade (this.tip);
	},
	
	hideTip: function(){
		if($('jachangethemecheckbox').checked){
			Cookie.write('ja-change-theme-help', true, 365);
		}
		$clear(this.timer);
		this.hideFade (this.tip);
	},
	
	showFade: function (tip) {
		if (!tip.fx) tip.fx = new Fx.Tween(tip, {});
		tip.fx.cancel();	
		
		pos = $(this.options.param_name + '-ja-list-themes').getPosition();
		posy = pos.y - $(this.options.param_name + '-ja-change-theme-help').getElement('.center-bottom').offsetHeight;		
		$(this.options.param_name + '-ja-change-theme-help').setStyles({left: $(this.options.param_name + '-ja-list-themes').getPosition().x-100})
		
		tip.fx.start('top', posy, posy-10);
		tip.fx.start('opacity', 0.7, 1);
	},
	
	hideFade: function (tip) {
		if (!tip.fx) tip.fx = new Fx.Tween(tip);
		tip.fx.cancel();
		tip.fx.start('opacity', 1, 0);
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
		if (this.element.getElements ('.ja-theme')) this.element.getElements ('.ja-theme').each (function (el){el.destroy()});
		
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
			el.set('text',name);
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
				data.push ((theme.hasClass('local')?'local':'core')+'.'+theme.get('text').trim());
			});
			value = data.join (',');
		}
		this.data = value;
		$(this.options.param_name).value = this.data;
		return this.data;
	}
});

function jathemesettings_disable(name){
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
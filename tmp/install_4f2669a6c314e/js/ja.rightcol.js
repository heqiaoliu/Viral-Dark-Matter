/*
#------------------------------------------------------------------------
  JA Purity II for Joomla 1.6
#------------------------------------------------------------------------
#Copyright (C) 2004-2010 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/

Fx.Style = new Class({
	Extends: Fx.Tween,
	initialize: function(element, property, options){		
		this.property = property;
		this.parent(element, options);
	},
	
	start: function(from, to) {
		return this.parent(this.property, from, to);
	},
	
	set: function(to) {
		return this.parent(this.property, to);
	},
	
	hide: function(){		
		return this.set(0);
	}

});

var JA_Collapse_Mod = new Class({

	initialize: function(myElements) {
		options = Object.extend({
			transition: Fx.Transitions.quadOut
		}, {});
		this.myElements = myElements;
		var exModules = excludeModules?excludeModules.split(','):[];
		exModules.each(function(el,i){exModules[i]='Mod'+el});
		myElements.each(function(el, i){
			el.elmain = el.getElement('.jamod-content');
			el.titleEl = el.getElement('h3');
			if(!el.titleEl) return;

			if (exModules.contains(el.id)) {
				el.titleEl.className = '';
				return;
			}

			el.titleEl.className = rightCollapseDefault;
			el.status = rightCollapseDefault;
			el.openH = el.elmain.getStyle('height').toInt();
			el.elmain.setStyle ('overflow','hidden');

			el.titleEl.addEvent('click', function(e){
				e = new Event(e).stop();
				el.toggle();
			});

			el.toggle = function(){
				if (el.status=='hide') el.show();
				else el.hide();
			}

			el.show = function() {
				el.elmain.setStyle ('opacity','1');
				el.titleEl.className='show';
				var ch = el.elmain.getStyle('height').toInt();
				new Fx.Style(el.elmain,'height',{onComplete:el.toggleStatus}).start(ch,el.openH);
			}
			el.hide = function() {
				el.elmain.setStyle ('opacity','0');
				el.titleEl.className='hide';
				var ch = (rightCollapseDefault=='hide')?0:el.elmain.getStyle('height').toInt();
				new Fx.Style(el.elmain,'height',{onComplete:el.toggleStatus}).start(ch,0);
			}
			el.toggleStatus = function () {
				el.status=(el.status=='hide')?'show':'hide';
				Cookie.write(el.id,el.status,{duration:365});
			}

			if(!el.titleEl.className) el.titleEl.className=rightCollapseDefault;
			if(el.titleEl.className=='hide') el.hide();
		});
	}
});

window.addEvent ('load', function(e){
	var jamod = new JA_Collapse_Mod ($$('.ja-module'));
});

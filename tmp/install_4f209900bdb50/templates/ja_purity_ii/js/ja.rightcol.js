/*
#------------------------------------------------------------------------
  JA Purity II for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
*/


var JA_Collapse_Mod = new Class({

	initialize: function(myElements) {
		options = Object.extend({
			transition: Fx.Transitions.quadOut
		}, {});
		this.myElements = myElements;
		var exModules = excludeModules?excludeModules.split(','):[];
		exModules.each(function(el,i){exModules[i]='Mod'+el});
		myElements.each(function(el, i){
			el.elmain = $E('.jamod-content',el);
			el.titleEl = $E('h3',el);
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
				Cookie.set(el.id,el.status,{duration:365});
			}

			if(!el.titleEl.className) el.titleEl.className=rightCollapseDefault;
			if(el.titleEl.className=='hide') el.hide();
		});
	}
});

window.addEvent ('load', function(e){
	var jamod = new JA_Collapse_Mod ($$('.ja-module'));
});

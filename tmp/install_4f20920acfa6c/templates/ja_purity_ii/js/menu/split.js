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
 

window.addEvent ('domready', function() {
	if (!$('ja-subnav') || !$('ja-subnav').getElement('ul')) return;
	var sfEls = $('ja-subnav').getElement('ul').getChildren();
	sfEls.each (function(li){
		li.addEvent('mouseenter', function(e) {
			clearTimeout(this.timer);
			if(this.className.indexOf(" hover") == -1)
				this.className+=" hover";
		});
		li.addEvent('mouseleave', function(e) {
			//this.className=this.className.replace(new RegExp(" hover\\b"), "");
			this.timer = setTimeout(jasdl_sub_mouseOut.bind(this), 100);
		});
	});
});

function jasdl_sub_mouseOut () {
	this.className=this.className.replace(new RegExp(" hover\\b"), "");
}

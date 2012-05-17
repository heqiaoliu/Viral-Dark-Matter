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

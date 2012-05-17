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
	var sfEls = $$('#ja-cssmenu li');
	sfEls.each (function(li) {
		if ((a = li.getElement('a')) && li.hasChild (a)) li.a = a;
		else li.a = null;
	});	
	sfEls.each (function(li){
		li.addEvent('mouseenter', function(e) {
			clearTimeout(this.timer);
			if(this.hasClass("havechild")) this.addClass('havechildsfhover').removeClass('havechild');
			else if(this.hasClass("havesubchild")) this.addClass('havesubchildsfhover').removeClass('havesubchild');
			this.addClass ('sfhover');
			if (this.a) this.a.addClass ('sfhover');
		});
		li.addEvent('mouseleave', function(e) {
			this.timer = setTimeout(sfHoverOut.bind(this, e), 100);
		});
	});
});

function sfHoverOut() {
	clearTimeout(this.timer);
	if(this.hasClass("havechildsfhover")) this.addClass('havechild').removeClass('havechildsfhover');
	else if(this.hasClass("havesubchildsfhover")) this.addClass('havesubchild').removeClass('havesubchildsfhover');
	this.removeClass ('sfhover');
	if (this.a) this.a.removeClass ('sfhover');
}

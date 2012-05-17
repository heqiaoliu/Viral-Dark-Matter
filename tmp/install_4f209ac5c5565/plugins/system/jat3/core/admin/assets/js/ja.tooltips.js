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
//Overwrite Tips class

Tips.prototype.start = function(el){
		if (!el) el = this.curTip;
			//Add status to disable tips
	if (el.tip && el.tip == 'disabled') return;
	if (!el.$tmp.myText) return; //blank tip
	this.curTip = el;
	//Original code
	this.wrapper.empty();
	if (el.$tmp.myTitle){
		this.title = new Element('span').inject(new Element('div', {'class': this.options.className + '-title'}).inject(this.wrapper)).setHTML(el.$tmp.myTitle);
	}
	if (el.$tmp.myText){
		this.text = new Element('span').inject(new Element('div', {'class': this.options.className + '-text'}).inject(this.wrapper)).setHTML(el.$tmp.myText);
	}
	$clear(this.timer);
	this.timer = this.show.delay(this.options.showDelay, this);
};
	
Tips.prototype.enableTip = function(el){
	if (el) el.tip = 'enabled';
};

Tips.prototype.disableTip = function(el){
	if (el) el.tip = 'disabled';
	if (this.curTip && this.curTip == el) this.hide();
};

Tips.prototype.initialize = function(elements, options){
	this.setOptions(options);
	this.options.fixed = true;
	this.options.fixed = true;
	this.options.timeout = 0; //no timeout
	this.toolTip = new Element('div', {
		'class': this.options.className + '-tip',
		'styles': {
			'position': window.ie6?'absolute':'fixed',
			'visibility': 'hidden'
		}
	}).inject(document.body);
	this.wrapper = new Element('div').inject(this.toolTip);
	$$(elements).each(this.build, this);
	if (this.options.initialize) this.options.initialize.call(this);
	this.toolTip.addEvent ('mouseenter', function(event) { 
		this.start(this.curTip); event.stop();
		this.curTip.fireEvent ('mouseenter', event);
	}.bind(this));
	this.toolTip.addEvent ('mouseleave', function (event) {
		this.end(event);
		this.curTip.fireEvent ('mouseleave', event);
	}.bind (this));
};

Tips.prototype.position = function(element){
	var pos = element.getPosition();
	var scroll = {'x': window.getScrollLeft(), 'y': window.getScrollTop()};
	this.toolTip.setStyles({
		'left': pos.x + this.options.offsets.x - scroll.x,
		'top': pos.y + this.options.offsets.y - scroll.y
	});
};
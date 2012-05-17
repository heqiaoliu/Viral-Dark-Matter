/*
# ------------------------------------------------------------------------
# JA Extensions Manager
# ------------------------------------------------------------------------
# Copyright (C) 2004-2010 JoomlArt.com. All Rights Reserved.
# @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
# Author: JoomlArt.com
# Websites: http://www.joomlart.com - http://www.joomlancers.com.
# ------------------------------------------------------------------------
*/
var JATooltips = new Class({

	options: {
		title: '',
		content: '',
		style: 'default',
		maxTitleChars: 30,
		width: 0,
		showDelay: 10, //100
		hideDelay: 50, //400
		className: 'ja-tooltip',
		offsets: {'x': 0, 'y': -16},
		pos: 'center-bottom',
		showwhen: 'mouseenter', //mouseenter, click
		hidewhen: 'mouseout' //mouseout, overclosebutton, clickclosebutton
	},

	initialize: function(elements, options){
		this.setOptions(options);
		this.options.pos = this.options.pos.split('-');
		this.pos = {'x':{'left':0,'center':0.5,'right':1}, 'y':{'top':0, 'center': 0.5, 'bottom': 1}};
		this.toolTip = new Element('div', {
			'class': this.options.className + ' ' + this.options.style,
			'styles': {
				'position': 'absolute',
				'top': '0',
				'left': '0',
				'opacity': 0,
				'z-index': 9999
			}
		}).inject(document.body);
		if (this.options.width) {
			this.toolTip.setStyle ('width', this.options.width);
		}
		this.toolTipInner = new Element('div',{'class':this.options.pos[0] + '-' + this.options.pos[1]}).inject(this.toolTip);
		this.wrapper = new Element('div', {'class':'mid3'}).inject(
			new Element('div', {'class':'mid2'}).inject(
				new Element('div', {'class':'mid1'}).inject(
					this.toolTipInner
				)));
		this.listener = new Element('div', {
			'class': this.options.className + '-listener',
			'styles': {
				'position': 'absolute',
				'top': -1000,
				'left': -1000,
				'opacity': 0.1,
				'z-index': 10000,
				'background': '#ffffff'
			}
		}).inject(document.body);
		if (this.options.hidewhen.test('closebutton')) {
			this.closebutton = new Element('a',{'class':'close'}).inject(this.toolTipInner);
		}
		new Element('div', {'class':'top4'}).inject(
			new Element('div', {'class':'top3'}).inject(
				new Element('div', {'class':'top2'}).inject(
					new Element('div', {'class':'top1'}).injectTop(
						this.toolTipInner))));
		new Element('div', {'class':'bot4'}).inject(
			new Element('div', {'class':'bot3'}).inject(
				new Element('div', {'class':'bot2'}).inject(
					new Element('div', {'class':'bot1'}).inject(
						this.toolTipInner))));

		this.listener.addEvent(this.options.showwhen, function(){
			$clear(this.hidetimer);
		}.bind(this));
		switch (this.options.hidewhen) {
			case 'overclosebutton':
				this.closebutton.addEvent('mouseenter', this.hide.bind(this));
				break;
			case 'clickclosebutton':
				this.closebutton.addEvent('click', this.hide.bind(this));
				break;
			case 'mouseout':
			default:
				this.toolTip.addEvent('mouseenter', function(){
					$clear(this.hidetimer);
				}.bind(this));
				this.toolTip.addEvent('mouseleave', function(event){
					this.end (event);
				}.bind(this));
				this.listener.addEvent('mouseleave', function(event){
					this.end (event);
				}.bind(this));
				break;
		}
		this.listener.addEvent('trash', this.end.bind(this));

		$$(elements).each(this.build, this);
		if (this.options.initialize) this.options.initialize.call(this);
	},

	build: function(el){
		el.$tmp.myTitle = this.options.title;
		el.$tmp.myText = this.options.content;
		
		if (!el.$tmp.myTitle && !el.$tmp.myText) {
			el.$tmp.myTitle = (el.href && el.getTag() == 'a') ? el.href.replace('http://', '') : (el.rel || false);
			if (el.title){
				var dual = el.title.split('::');
				if (dual.length > 1){
					el.$tmp.myTitle = dual[0].trim();
					el.$tmp.myText = dual[1].trim();
				} else {
					el.$tmp.myText = el.title;
				}
			} else {
				el.$tmp.myText = false;
			}
		}		
		if (el.title) el.removeAttribute('title');
		
		if (el.$tmp.myTitle && el.$tmp.myTitle.length > this.options.maxTitleChars) el.$tmp.myTitle = el.$tmp.myTitle.substr(0, this.options.maxTitleChars - 1) + "&hellip;";
		el.addEvent(this.options.showwhen, function(event){
			if (!$defined(event.page)) event = new Event(event);
			this.listener.el = el;
			var pos = el.getPosition();
			this.listener.setStyles({
			'display': 'block',
			'left': pos.x - 3,
			'top': pos.y - 3,
			'width': el.offsetWidth + 6,
			'height': el.offsetHeight + 6
			});
			this.start(el);
			this.position(event);
		}.bind(this));
		if (this.options.hidewhen == 'mouseout'){
			el.addEvent('mouseleave', function(event){
				this.end (event);
			}.bind(this));
		}
	},

	start: function(el){
		this.wrapper.empty();
		if (el.$tmp.myTitle){
			this.title = new Element('span').inject(new Element('div', {'class': this.options.className + '-title'}).inject(this.wrapper)).setHTML(el.$tmp.myTitle);
		}
		if (el.$tmp.myText){
			this.text = new Element('span').inject(new Element('div', {'class': this.options.className + '-text'}).inject(this.wrapper)).setHTML(el.$tmp.myText);
		}
		$clear(this.timer);
		this.timer = this.show.delay(this.options.showDelay, this);
	},

	end: function(event){
		$clear(this.hidetimer);
		this.hidetimer = this.hide.delay(this.options.hideDelay, this);
	},

	position: function(event){
	
		var wsize = window.size();
		var win = wsize.size;
		var scroll = wsize.scrollSize;
		var tip = {'x': this.toolTip.offsetWidth, 'y': this.toolTip.offsetHeight};
		var prop = {'x': 'left', 'y': 'top'};
			
		this.toolTip.pos = [];
		var pos = event.page.x + this.options.offsets.x - tip.x*this.pos.x[this.options.pos[0]];
		if ((pos + tip.x - scroll.x) > win.x) pos = event.page.x - this.options.offsets.x - tip.x;
		this.toolTip.pos.x = pos;
		this.toolTip.pos._x = event.page.x - tip.x*this.pos.x[this.options.pos[0]];
		
		var pos = event.page.y + this.options.offsets.y - tip.y*this.pos.y[this.options.pos[1]];
		if ((pos + tip.y - scroll.y) > win.y) pos = event.page.y - this.options.offsets.y - tip.y;
		this.toolTip.pos.y = pos;
		this.toolTip.pos._y = event.page.y - tip.y*this.pos.y[this.options.pos[1]];

	},

	show: function(){
		if (this.options.timeout) this.timer = this.hide.delay(this.options.timeout, this);
		//this.fireEvent('onShow', [this.toolTip]);
		this.showFade (this.toolTip);
	},

	hide: function(){
		//this.fireEvent('onHide', [this.toolTip]);
		$clear(this.timer);
		this.hideFade (this.toolTip);
		this.listener.setStyle('display', 'none');
	},

	showFade: function (tip) {
		if (!tip.fx) tip.fx = new Fx.Styles(tip);
		tip.fx.stop();
		var posx = tip.offsetLeft;
		if (!((posx >= tip.pos._x && posx <= tip.pos.x) ||(posx <= tip.pos._x && posx >= tip.pos.x))) {
			posx = tip.pos._x;
		}
		var posy = tip.offsetTop;
		if (!((posy >= tip.pos._y && posy <= tip.pos.y) ||(posy <= tip.pos._y && posy >= tip.pos.y))) {
			posy = tip.pos._y;
		}
		var curopac = tip.getStyle('opacity');
		tip.fx.start({
			'left': [posx, tip.pos.x],
			'top': [posy, tip.pos.y],
			'opacity': [curopac,1]
		});	
	},
	
	hideFade: function (tip) {
		if (!tip.fx) tip.fx = new Fx.Styles(tip);
		tip.fx.stop();
		var curopac = tip.getStyle('opacity');
		tip.fx.start({
			'left': [tip.offsetLeft, tip.pos._x],
			'top': [tip.offsetTop, tip.pos._y],
			'opacity': [curopac, 0]
		});	
	}
});

JATooltips.implement(new Events, new Options);


window.extend (
{
	size: function(){
		var w = 0;
		var h = 0;
		var sw = 0;
		var sh = 0;

		//IE
		if(!window.innerWidth)
		{
			//strict mode
			if(!(document.documentElement.clientWidth == 0))
			{
				w = document.documentElement.clientWidth;
				h = document.documentElement.clientHeight;
				sw = Math.max(document.documentElement.offsetWidth, document.documentElement.scrollWidth);
				sh = Math.max(document.documentElement.offsetHeight, document.documentElement.scrollHeight);
			}
			//quirks mode
			else
			{
				w = document.body.clientWidth;
				h = document.body.clientHeight;
				sw = document.body.scrollWidth;
				sh = document.body.scrollHeight;
			}
		}
		//w3c
		else
		{
			w = window.innerWidth;
			h = window.innerHeight;
			sw = document.documentElement.scrollWidth;
			sh = document.documentElement.scrollHeight;
		}
		return {
			'size': {x:w,y:h},
			'scrollSize': {x:w,y:h}
		};
	}
});

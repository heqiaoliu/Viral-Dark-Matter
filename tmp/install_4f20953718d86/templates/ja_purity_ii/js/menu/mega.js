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
 
var jaMegaMenuMoo = new Class({
	initialize: function(menu, options){
		this.options = $extend({
			slide:	true, //enable slide
			duration: 300, //slide speed. lower for slower, bigger for faster
			transition: Fx.Transitions.Sine.easeOut,
			fading: false, //Enable fading
			bgopacity: 0.9, //set the transparent background. 0 to disable, 0<bgopacity<1: the opacity of the background
			delayHide: 500,
			position: 'bottom', //position of toolbar. 
			rtl: 0, //right to left mode
			direction: 'down',
			action: 'mouseenter', //mouseenter or click
			tips: true,	//enable jatooltips
			hidestyle: 'fastwhenshow',
			//events
			onItemShow: null, //function (li) {}
			onItemHide: null, //function (li) {}
			onItemShowComplete: null, //function (li) {}
			onItemHideComplete: null, //function (li) {}
			onFirstShow: null, //First child show
			onLastHide: null, //All child hidden			
			onLoad: null //Load done
		}, options || {});
		this.menu = menu;
		this.childopen = new Array();
		
		this.items = null;
		this.imageloaded = false;
		//window.addEvent('load', this.start.bind(this));
		this.start();
	
	},
	
	startedcheck: function () {
		this.imageloaded = true;
		if (!this.items) this.start();
	},
	
	start: function () {
		this.menu = $(this.menu);
		//preload images
		var images = this.menu.getElements ('img');
		if (images && images.length && !this.imageloaded) {
			var imgs = [];
			images.each (function (image) {imgs.push(image.src)});
			if (imgs.length) {
				new Asset.images(imgs, {			
					onComplete: function(){
						this.imageloaded = true;
						this.start();
					}.bind(this)
				});
				
				this.starttimeout = setTimeout (this.startedcheck.bind(this), 3000); //check if start after 10 seconds. If not, call start manual
				return ;
			}
		}
		clearTimeout (this.starttimeout);
		if (this.items) return; //started already
		this.items = this.menu.getElements ('li.mega');
		//this.items.setStyle ('position', 'relative');
		this.items.each (function(li) {
			//link item
			if ((a = li.getElement('a.mega')) && this.isChild (a, li)) li.a = a;
			else li.a = null;
			//parent
			li._parent = this.getParent (li);
			//child content
			if ((childcontent = li.getElement('.childcontent')) && this.isChild (childcontent, li)) {
				li.childcontent = childcontent;
				li.childcontent_inner = li.childcontent.getElement ('.childcontent-inner-wrap');
				var coor = li.getElement('.childcontent-inner').getCoordinates ();
				li._w = coor.width;
				li._h = coor.height;
				li._ml = li.childcontent.getStyle('margin-left').toInt();
				li._mt = li.childcontent.getStyle('margin-top').toInt();
				li.level0 = li.getParent().hasClass('level0');
				//
				//li.childcontent.setStyles ({'width':li._w+50, 'height':li._h});
				if (li._w) {
					li.childcontent.setStyles ({'width':li._w+50});
					li.childcontent_inner.setStyles ({'width':li._w});
				}
				//fix for overflow
				li.childcontent_inner1 = li.childcontent.getElement ('.childcontent-inner');
				li.childcontent_inner1.ol = false;
				//Fix for IE: correct render at the first show
				li.childcontent_inner1.setStyle ('min-height', li.childcontent_inner1.offsetHeight);
				if (li.childcontent_inner1.getStyle ('overflow') == 'auto' || li.childcontent_inner1.getStyle ('overflow') == 'scroll') {
					li.childcontent_inner1.ol = true;
					//fix for ie6/7
					if (window.ie6 || window.ie7) {
						//li.childcontent_inner1.setStyle ('position', 'relative');
					}
					
					if (window.ie6) {
						li.childcontent_inner1.setStyle ('height', li.childcontent_inner1.getStyle ('max-height') || 400);
					}
				}

				//show direction
				if (this.options.direction == 'up') {
					if (li.level0) {
						//li.childcontent.setStyle ('top', -li.childcontent.offsetHeight); //ajust top position
						li.childcontent.setStyle ('bottom', li.offsetHeight);
					} else {
						li.childcontent.setStyle ('bottom', 0);
					}
				}		
			}
			else li.childcontent = null;
			
			if (li.childcontent && this.options.bgopacity) {
				//Make transparent background
				var bg = new Element ('div', {'class':'childcontent-bg'});
				bg.injectTop (li.childcontent_inner);
				bg.setStyles ({'width':'100%', 'height':li._h, 'opacity':this.options.bgopacity,
								'position': 'absolute', 'top': 0, 'left': 0, 'z-index': 1
								});
				if (li.childcontent.getStyle('background')) bg.setStyle ('background', li.childcontent.getStyle('background'));
				if (li.childcontent.getStyle('background-image')) bg.setStyle ('background-image', li.childcontent.getStyle('background-image'));
				if (li.childcontent.getStyle('background-repeat')) bg.setStyle ('background-repeat', li.childcontent.getStyle('background-repeat'));
				if (li.childcontent.getStyle('background-color')) bg.setStyle ('background-color', li.childcontent.getStyle('background-color'));
				li.childcontent.setStyle ('background', 'none');
				li.childcontent_inner.setStyles ({'position':'relative', 'z-index': 2});
			}
			
			if (li.childcontent && (this.options.slide || this.options.fading)) {
				//li.childcontent.setStyles ({'width': li._w});
				li.childcontent.setStyles ({'left':'auto'});
				if (li.childcontent.hasClass ('right')) li.childcontent.setStyle ('right', 0);
				if (this.options.slide) {
					li.childcontent.setStyles ({'left':'auto', 'overflow':'hidden'});
					if (li.level0) {
						if (this.options.direction == 'up') {
							li.childcontent_inner.setStyle ('bottom', -li._h-20);
						} else {
							li.childcontent_inner.setStyle ('margin-top', -li._h-20);
						}
						
					} else {					
						li.childcontent_inner.setStyle ('margin-left', -li._w-20);
					}
				}
				if (this.options.fading) {
					li.childcontent_inner.setStyle ('opacity', 0);
				}
				//Init Fx.Styles for childcontent
				li.fx = new Fx.Styles(li.childcontent_inner, {duration: this.options.duration, transition: this.options.transition, onComplete: this.itemAnimDone.bind(this, li)});
				//effect
				li.eff_on = {};
				li.eff_off = {};
				if (this.options.slide) {
					if (li.level0) {
						if (this.options.direction == 'up') {
							li.eff_on ['bottom'] = 0;
							li.eff_off ['bottom'] = -li._h;
						} else {
							li.eff_on ['margin-top'] = 0;
							li.eff_off ['margin-top'] = -li._h;
						}
					} else {
						li.eff_on['margin-left'] = 0;
						li.eff_off['margin-left'] = -li._w;
					}
				}
				if (this.options.fading) {
					li.eff_on['opacity'] = 1;
					li.eff_off['opacity'] = 0;
					//li.eff_off['margin-top'] = -li._h;
				}
			}
				
			if (this.options.action=='click') {
				if (li.childcontent) {
					li.addEvent('click', function(e) {
						var event = new Event (e);
						if (li.hasClass ('group')) return;
						if (li.childcontent) {
							if (li.status == 'open') {
								if (this.cursorIn (li, event)) {
									this.itemHide (li);
								} else {
									this.itemHideOthers(li);
								}
							} else {
								this.itemShow (li);
							}
						} else {
							if (li.a) location.href = li.a.href;
						}
						event.stop();
					}.bind (this));
				
					//If action is click, click on windows will close all submenus
					this.windowClickFn = function (e) {		
						this.itemHideOthers(null);
					}.bind (this);
				}
				li.addEvent('mouseenter', function(e) {
					if (li.hasClass ('group')) return;
					this.itemOver (li);
					//e.stop();
				}.bind (this));
				
				li.addEvent('mouseleave', function(e) {
					if (li.hasClass ('group')) return;
					this.itemOut (li);
					//e.stop();
				}.bind (this));				
			}

			if (this.options.action == 'mouseover' || this.options.action == 'mouseenter') {
				li.addEvent('mouseenter', function(e) {
					if (li.hasClass ('group')) return;
					$clear (li.timer);
					this.itemShow (li);
					e.stop();
				}.bind (this));
				
				li.addEvent('mouseleave', function(e) {
					if (li.hasClass ('group')) return;
					$clear (li.timer);
					if (li.childcontent) li.timer = setTimeout(this.itemHide.pass([li, e], this), this.options.delayHide);
					else this.itemHide (li, e);
					e.stop();
				}.bind (this));
			}
			
			//when click on a link - close all open childcontent
			if (li.a && !li.childcontent) {
				li.a.addEvent ('click',function (e){
					this.itemHideOthers (null);
					//Remove current class
					this.menu.getElements ('.active').removeClass ('active');
					//Add current class
					var p = li;
					while (p) {
						p.addClass ('active');
						p.a.addClass ('active');
						p = p._parent;
					}
					//new Event (e).stop();
				}.bind (this));
			}
		},this);
		
		if (this.options.slide || this.options.fading) {
			//hide all content child
			//this.menu.getElements('.childcontent').setStyle ('display', 'none');
			this.menu.getElements('.childcontent').setStyle ('left', -9999);
		}
		
		//tooltips
		if (this.options.tips) {
			this.options.tips = this.buildTooltips ();
		}
		
		//Call onLoad
		if (typeof (this.options.onLoad) == 'function') this.options.onLoad.call (this);
	}, 

	position: function (li) {
		if (li.childcontent) {
			//fix position for level0
			//hide it
			if (li.status == 'close' && !this.options.slide && !this.options.fading) {
				li.childcontent.setStyle ('left', -9999);
				return ;
			}
			//show it
			li.childcontent.setStyle ('left', 'auto');
			//reposition

			var pos = $merge (li.getPosition(), {'w':li._w, 'h':li.childcontent.offsetHeight});
			var maxx = window.getWidth(); //window width
			//get x from content region
			var main = $E('#ja-mainnav .main');
			var mainx = main.getPosition().x + main.offsetWidth;
			if (maxx > mainx) maxx = mainx;
			
			var win = {'x': maxx, 'y': window.getHeight()};
			var scroll = {'x': window.getScrollLeft(), 'y': window.getScrollTop()};

			if (li.level0) {
				li.childcontent.setStyle ('margin-left', (pos['x'] + pos['w'] + li._ml > win['x'] + scroll ['x']) ? win['x'] + scroll ['x'] - pos['w'] - pos['x']:li._ml);
			} else {
				//sub level
				if (this.options.direction == 'up') {
					li.childcontent.setStyle ('bottom', pos['y']+li.offsetHeight-pos['h'] - 20 < scroll ['y']?pos['y']+li.offsetHeight-pos['h'] - scroll ['y'] - 20:0);
				} else {
					li.childcontent.setStyle ('margin-top', (pos['y'] + pos['h'] + 20 + li._mt > win['y'] + scroll ['y'])?win['y'] + scroll ['y'] - pos['y'] - pos['h'] - 20 : li._mt);
				}
			}	

		}

	},
	
	getParent: function (li) { 
		var p = li;
		while ((p=p.getParent())) {
			if (this.items.contains (p) && !p.hasClass ('group')) return p;
			if (!p || p == this.menu) return null;
		}
	},
	
	cursorIn: function (el, event) {
		if (!el || !event) return false;
		var pos = $merge (el.getPosition(), {'w':el.offsetWidth, 'h': el.offsetHeight});;
		var cursor = {'x': event.page.x, 'y': event.page.y};
	
		if (cursor.x>pos.x && cursor.x<pos.x+el.offsetWidth
				&& cursor.y>pos.y && cursor.y<pos.y+el.offsetHeight) return true;			
		return false;
	},
	
	isChild: function (child, parent) {
		return !!parent.getChildren().contains (child);
	},
	
	itemOver: function (li) {
		if (li.hasClass ('haschild')) 
			li.removeClass ('haschild').addClass ('haschild-over');
		li.addClass ('over');
		if (li.a) {
			li.a.addClass ('over');
		}
	},
	
	itemOut: function (li) {
		if (li.hasClass ('haschild-over'))
			li.removeClass ('haschild-over').addClass ('haschild');
		li.removeClass ('over');
		if (li.a) {
			li.a.removeClass ('over');
		}
	},

	itemShow: function (li) {		
		clearTimeout(li.timer);
		if (li.status == 'open') return; //don't need do anything
		//Adjust position
		//Setup the class
		this.itemOver (li);
		//Check if this is the first show
		if (li.childcontent) {
			var firstshow = true;
			this.childopen.each (function (li) {
				if (li.childcontent) firstshow = false;
			});
			if (firstshow && typeof (this.options.onFirstShow) == 'function') {
				this.options.onFirstShow.call (this, li);
			}
		}
		//push to show queue
		li.status = 'open';
		this.childopen.push (li);
		//hide other
		this.itemHideOthers (li);
		if (li.childcontent) {
			if (this.options.action=='click' && this.childopen.length && !this.windowClickEventAdded) {
				//addEvent click for window
				$(document.body).addEvent ('click', this.windowClickFn);
				this.windowClickEventAdded = true;
			}
			//call event
			if (typeof (this.options.onItemHide) == 'function') this.options.onItemHide.call (this, li);
		}
		
		this.position (li);
		if (!$defined(li.fx) || !$defined(li.childcontent)) return;
		
		li.childcontent.setStyle ('display', 'block');

		li.childcontent.setStyles ({'overflow': 'hidden'});		
		if (li.childcontent_inner1.ol) li.childcontent_inner1.setStyles ({'overflow': 'hidden'});
		li.fx.stop();
		li.fx.start (li.eff_on);
		//disable tooltip for this item
		this.disableTooltip (li);
		//if (li._parent) this.itemShow (li._parent);
	},
	
	itemHide: function (li, e) {
		if (e && e.page) { //if event
			if (this.cursorIn (li, e) || this.cursorIn (li.childcontent, e)) {
				return;
			} //cursor in li
			var p=li._parent;
			if (p && !this.cursorIn (p, e) && !this.cursorIn(p.childcontent, e)) {
				p.fireEvent ('mouseleave', e); //fire mouseleave event
			}
		}
		clearTimeout(li.timer);
		this.itemOut(li);
		li.status = 'close';
		this.childopen.remove (li);
		if (li.childcontent) {
			if (this.options.action=='click' && !this.childopen.length && this.windowClickEventAdded) {
				//removeEvent click for window
				$(document.body).removeEvent ('click', this.windowClickFn);
				this.windowClickEventAdded = false;
			}
			//call event
			if (typeof (this.options.onItemShow) == 'function') this.options.onItemShow.call (this, li);
		}
		this.position (li);
		if (!$defined(li.fx) || !$defined(li.childcontent)) return;
		
		if (li.childcontent.getStyle ('opacity') == 0) return;
		li.childcontent.setStyles ({'overflow': 'hidden'});
		if (li.childcontent_inner1.ol) li.childcontent_inner1.setStyles ({'overflow': 'hidden'});
		li.fx.stop();
		switch (this.options.hidestyle) {
		case 'fast': 
			li.fx.options.duration = 100;
			li.fx.start ($merge(li.eff_off,{'opacity':0}));
			break;
		case 'fastwhenshow': //when other show
			if (!e) { //force hide, not because of event => hide fast
				li.fx.options.duration = 100;
				li.fx.start ($merge(li.eff_off,{'opacity':0}));
			} else {	//hide as normal
				li.fx.start (li.eff_off);
			}
			break;
		case 'normal':
		default:
			li.fx.start (li.eff_off);
			break;
		}
		//li.fx.start (li.eff_off);		
	},
	
	itemAnimDone: function (li) {
		//hide done
		if (li.status == 'close'){
			//reset duration and enable opacity if not fading
			if (this.options.hidestyle.test (/fast/)) {
				li.fx.options.duration = this.options.duration;
				if (!this.options.fading) li.childcontent_inner.setStyle ('opacity', 1);
			}
			//hide
			//li.childcontent.setStyles ({'display': 'none'});
			li.childcontent.setStyle ('left', -9999);
			//enable tooltip
			this.enableTooltip (li);
			//call event
			if (typeof (this.options.onItemHideComplete) == 'function') this.options.onItemHideComplete.call (this, li);
			//Check if there's no child content shown, raise event onLastHide
			var lasthide = true;
			this.childopen.each (function (li) {
				if (li.childcontent) lasthide = false;
			});
			if (lasthide && typeof (this.options.onLastHide) == 'function') this.options.onLastHide.call (this, li);
		}
		
		//show done
		if (li.status == 'open'){
			li.childcontent.setStyles ({'overflow': ''});
			if (li.childcontent_inner1.ol) li.childcontent_inner1.setStyles ({'overflow-y': 'auto'});
			if (typeof (this.options.onItemShowComplete) == 'function') this.options.onItemShowComplete.call (this, li);
		}
	},
	
	itemHideOthers: function (el) {
		var fakeevent = null
		if (el && !el.childcontent) fakeevent = {};
		var curopen = this.childopen.copy();
		curopen.each (function(li) {
			if (li && typeof (li.status) != 'undefined' && (!el || (li != el && !li.hasChild (el)))) {
				this.itemHide(li, fakeevent);
			}
		},this);
	},

	buildTooltips: function () {
		this.tooltips = new Tips (this.menu.getElements ('.hasTipThumb'), {'className':'ja-toolbar-thumb', 'fixed':true, offsets:{'x':100, 'y': this.options.direction=='up'?-180:20}, 'direction': this.options.direction});
		this.tooltips2 = new Tips (this.menu.getElements ('.hasTipThumb2'), {'className':'ja-toolbar-thumb2', 'fixed':true, offsets:{'x':100, 'y': 20}, 'direction': this.options.direction});
		this.tooltips3 = new Tips (this.menu.getElements ('.hasTipThumb3'), {'className':'ja-toolbar-thumb3', 'fixed':true, offsets:{'x':100, 'y': 20}, 'direction': this.options.direction});
		return true;
	},
	
	disableTooltip: function (el) {
		if (this.options.tips) this.tooltips.disableTip(el);
		return;
	},
	
	enableTooltip: function (el) {
		if (this.options.tips) this.tooltips.enableTip(el);
		return;
	}	

});

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

var jaMegaMenuMoo = new Class({

	initialize: function(menu, options){
		this.options = $extend({
			slide:	true, //enable slide
			duration: 300, //slide speed. lower for slower, bigger for faster
			fading: false, //Enable fading
			bgopacity: 0.9, //set the transparent background. 0 to disable, 0<bgopacity<1: the opacity of the background
			delayHide: 500,
			direction: 'down',
			action: 'mouseenter', //mouseenter or click
			hidestyle: 'normal'
		}, options || {});
		//ignore delayHide if no animation
		if (!this.options.slide && !this.options.fading) this.options.delayHide = 10;
		
		this.menu = menu;
		this.childopen = new Array();
		this.imageloaded = false;
		this.loaded = false;
		//window.addEvent('load', this.start.bind(this));
		this.start();
	},
	
	start: function () {
		//do nothing if loaded
		if (this.loaded) return;
		
		this.menu = $(this.menu);
		//preload images
		var images = this.menu.getElements ('img');
		if (images && images.length && !this.imageloaded) {
			var imgs = [];
			images.each (function (image) {imgs.push(image.src)});
			if (imgs.length) {
				new Asset.images(imgs, {			
					onComplete: function(){
						this.start();
					}.bind(this)
				});
				this.imageloaded = true;
				
				//call this start if cannot load image after sometime
				this.start.delay (3000, this);
				return ;
			}
		}
		
		//mark as called
		this.loaded = true;
		
		//get wrapper
		p = this.menu;
		while (p=p.getParent()) {
			if (p.hasClass ('main') || p.hasClass ('wrap')) {this.wrapper = p; break;}
		}
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
				var coor = li.childcontent_inner.getCoordinates ();
				li._w = li.getElement('.childcontent-inner').offsetWidth;
				li._h = li.getElement('.childcontent-inner').offsetHeight;

				li.level0 = li.getParent().hasClass('level0');
				//
				li.childcontent.setStyles ({'width':li._w+10, 'height':li._h});
				li.childcontent_inner.setStyles ({'width':li._w});
				//fix for overflow
				li.childcontent_inner1 = li.childcontent.getElement ('.childcontent-inner');
				li.childcontent_inner1.ol = false;
				if (li.childcontent_inner1.getStyle ('overflow') == 'auto' || li.childcontent_inner1.getStyle ('overflow') == 'scroll') {
					li.childcontent_inner1.ol = true;
					//fix for ie6/7
					if (window.ie6 || window.ie7) {
						li.childcontent_inner1.setStyle ('position', 'relative');
					}
					
					if (window.ie6) {
						li.childcontent_inner1.setStyle ('height', li.childcontent_inner1.getStyle ('max-height') || 400);
					}
				}

				//show direction
				if (this.options.direction == 'up') {
					if (li.level0) {
						li.childcontent.setStyle ('top', -li.childcontent.offsetHeight); //ajust top position
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
				li.fx = new Fx.Styles(li.childcontent_inner, {duration: this.options.duration, transition: Fx.Transitions.linear, onComplete: this.itemAnimDone.bind(this, li)});
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
			
			if (this.options.action=='click' && li.childcontent) {
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
					event.stopPropagation();
				}.bind (this));		
			}

			if (this.options.action == 'mouseover' || this.options.action == 'mouseenter') {
				li.addEvent('mouseenter', function(e) {
					if (li.hasClass ('group')) return;
					$clear (li.timer);
					this.itemShow (li);
					e.stopPropagation();
				}.bind (this));
				
				li.addEvent('mouseleave', function(e) {
					if (li.hasClass ('group')) return;
					$clear (li.timer);
					if (li.childcontent) li.timer = this.itemHide.delay(this.options.delayHide, this, [li, e]);
					else this.itemHide (li, e);
					if (!e.stopped) {
						e.stopPropagation();
						e.stopped = true; //make sure the stop function is call only once
					}
				}.bind (this));
				
				//if has childcontent, don't goto link before open childcontent - fix for touch screen
				if (li.a && li.childcontent) {
					li.clickable = false;
					li.a.addEvent ('click',function (e){
						if (!li.clickable) {
							new Event(e).stop();
						}
					}.bind (this));
				}
				
				//stop if click on menu item - prevent raise event to container => hide all open submenu
				li.addEvent ('click', function (e) {new Event(e).stopPropagation()});
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
					new Event (e).stopPropagation();
				}.bind (this));
			}
			
			if (li.childcontent) this.positionSubmenu (li);
		},this);
		
		//click on windows will close all submenus
		var container = $('ja-wrapper');
		if (!container) container = document.body;
		container.addEvent ('click',function (e) {
			this.itemHideOthers(null);
		}.bind(this));				

		//stop if click on menu
		this.menu.addEvent ('click', function (e) {new Event(e).stopPropagation()});
		
		
		if (this.options.slide || this.options.fading) {
			//hide all content child
			this.menu.getElements('.childcontent').setStyle ('display', 'none');
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
		//Setup the class
		this.itemOver (li);
		//push to show queue
		li.status = 'open';
		this.enableclick.delay (100, this, li);
		this.childopen.push (li);
		//hide other
		this.itemHideOthers (li);
		if (li.childcontent) {
			//reposition the submenu
			this.positionSubmenu (li);
		}
		

		if (!$defined(li.fx) || !$defined(li.childcontent)) return;
		
		li.childcontent.setStyle ('display', 'block');
		
		li.childcontent.setStyles ({'overflow': 'hidden'});		
		if (li.childcontent_inner1.ol) li.childcontent_inner1.setStyles ({'overflow': 'hidden'});
		li.fx.stop();
		li.fx.start (li.eff_on);
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
				//li.fx.options.duration = 300;
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
			li.childcontent.setStyles ({'display': 'none'});
			this.disableclick.delay (100, this, li);
		}
		
		//show done
		if (li.status == 'open'){
			li.childcontent.setStyles ({'overflow': ''});
			if (li.childcontent_inner1.ol) li.childcontent_inner1.setStyles ({'overflow-y': 'auto'});
			li.childcontent_inner.setStyle ('opacity', 1);
			li.childcontent.setStyles ({'display': 'block'});
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

	enableclick: function (li) {
		if (li.a && li.childcontent) li.clickable = true;
	},
	disableclick: function (li) {
		if (li.a && li.childcontent) li.clickable = false;
	},
	
	positionSubmenu: function (li) {
		if (li.level0) {
			if (!window.isRTL) {
				//check position
				var lcor = li.getCoordinates();
				var ccor = li.childcontent.getCoordinates();
				if(!ccor.width)
				{
					li.childcontent.setStyle ('display', 'block');
					ccor = li.childcontent.getCoordinates();
					li.childcontent.setStyle ('display', 'none');
				}

				var ml = 0;
				var l = lcor.left;
				var r = l + ccor.width;
				if (this.wrapper) {
					var wcor = this.wrapper.getCoordinates();
					l = l - wcor.left;
					r = wcor.right - r + 10;
				} else {
					r = window.getWidth() - r + 10;
				}
				if (l < 0 || l+r < 0) {
					ml = - l;
				} else if (r < 0) {
					ml = r;
				}
				if (ml != 0) li.childcontent.setStyle ('margin-left', ml);					
			} else {
				//check position
				var lcor = li.getCoordinates();						
				var ccor = li.childcontent.getCoordinates();
				if(!ccor.width)
				{
					li.childcontent.setStyle ('display', 'block');
					ccor = li.childcontent.getCoordinates();
					li.childcontent.setStyle ('display', 'none');
				}
				var mr = 0;
				var r = lcor.right;
				var l = r - ccor.width;
				if (this.wrapper) {
					var wcor = this.wrapper.getCoordinates();
					l = l - wcor.left;
					r = wcor.right - r + 10;
				} else {
					r = window.getWidth() - r + 10;
				}
				if (r < 0 || l+r < 0) {
					mr = - r;
				} else if (l < 0) {
					mr = l;
				}
				if (mr != 0) li.childcontent.setStyle ('margin-right', mr);
			}
		} else {
			//check if it's out of view-port
			var lcor = li.getCoordinates();
			var ccor = li.childcontent.getCoordinates();
			if(!ccor.width)
			{
				li.childcontent.setStyle ('display', 'block');
				ccor = li.childcontent.getCoordinates();
				li.childcontent.setStyle ('display', 'none');
			}
			var ml = 0;
			var l = ccor.left;
			var r = l + ccor.width;
			if (this.wrapper) {
				var wcor = this.wrapper.getCoordinates();
				l = l - wcor.left;
				r = wcor.right - r + 10;
			} else {
				r = window.getWidth() - r + 10;
			}
			if (r < 0) {
				//change the direction and position for submenu
				li.childcontent.setStyle ('margin-left', -ccor.width + 20);
				if (li.eff_on) li.eff_on['margin-left'] = 0;
				if (li.eff_off) {
					li.eff_off['margin-left'] = li._w + 20;
					li.childcontent_inner.setStyle ('margin-left', li.eff_off['margin-left']);
				}
			}
		}		
	}
});

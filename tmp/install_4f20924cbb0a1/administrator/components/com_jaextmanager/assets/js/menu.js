/*------------------------------------------------------------------------
# $JA#PRODUCT_NAME$ - Version $JA#VERSION$ - Licence Owner $JA#OWNER$
# ------------------------------------------------------------------------
# Copyright (C) 2004-2008 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
# @license - Copyrighted Commercial Software
# Author: J.O.O.M Solutions Co., Ltd
# Websites:  http://www.joomlart.com -  http://www.joomlancers.com
# This file may not be redistributed in whole or significant part.
-------------------------------------------------------------------------*/
var JATreeMenu = new function() {
	this.menuid = 'jacom-mainnav';
	this.openedcls = 'opened';
	this.closedcls = 'closed';
	this.initmenu = function () {
		var mainnav = document.getElementById (this.menuid);
		if (!mainnav) return;
		var uls = mainnav.getElementsByTagName ('ul');
		var menustatus = Cookie.read('menustatus');
		
		open_obj = document.getElementById('menu_open');
		close_obj = document.getElementById('menu_close');
		
		if(menustatus==this.closedcls){
			close_obj.className = 'closeall';
			open_obj.className = 'openall opened';
		}
		else{
			open_obj.className = 'openall';
			close_obj.className = 'closeall closed';
		}
		
		for (var i=1; i<uls.length; i++) {
			var li = uls[i].parentNode;
			if (li.tagName.toLowerCase() != 'li') continue;
			
			if (li.className.indexOf('opened') == -1) {
				
				if (menustatus == "" || menustatus == null) {
					menustatus = this.openedcls;
				}				
				li.className += " "+menustatus;
			}
			var a = li.getElementsByTagName ('a')[0];
			a._p = li;
			a._o = this.openedcls;
			a._c = this.closedcls;
			a.onclick = function () {
				var _p = this._p;
				if(_p.className.indexOf(this._o) == -1) {
					_p.className=_p.className.replace(new RegExp(" "+this._c+"\\b"), " "+this._o);
				} else {
					_p.className=_p.className.replace(new RegExp(" "+this._o+"\\b"), " "+this._c);
				}
			}
			a.href = 'javascript:;';
		}
	};
	
	this.openall = function () {
		open_obj = document.getElementById('menu_open');
		open_obj.className = 'openall';
		close_obj = document.getElementById('menu_close');
		close_obj.className = 'closeall closed';
		Cookie.write('menustatus',this.openedcls);
		var mainnav = document.getElementById (this.menuid);
		if (!mainnav) return;
		var uls = mainnav.getElementsByTagName ('ul');
		for (var i=1; i<uls.length; i++) {
			var li = uls[i].parentNode;
			if (li.tagName.toLowerCase() != 'li') continue;
			li.className=li.className.replace(new RegExp(" "+this.closedcls+"\\b"), " "+this.openedcls);
		}
		
	};
	this.closeall = function () {
		close_obj = document.getElementById('menu_close');
		close_obj.className ='closeall';
		open_obj = document.getElementById('menu_open');
		open_obj.className = 'openall opened';
		Cookie.write('menustatus',this.closedcls);
		var mainnav = document.getElementById (this.menuid);
		if (!mainnav) return;
		var uls = mainnav.getElementsByTagName ('ul');
		for (var i=1; i<uls.length; i++) {
			var li = uls[i].parentNode;
			if (li.tagName.toLowerCase() != 'li') continue;
			li.className=li.className.replace(new RegExp(" "+this.openedcls+"\\b"), " "+this.closedcls);
		}
	};
}
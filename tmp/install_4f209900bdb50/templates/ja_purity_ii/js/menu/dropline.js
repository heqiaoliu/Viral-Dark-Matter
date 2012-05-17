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


var jasdl_delay = 1000
var jasdl_current = null
var jasdl_recover = null
var jasdl_timeoutid = null
var jasdl_timetorecover = null
var jasdl_timeoutid2 = 0
function jasdl_initJAScriptDLMenu() {
	jasdl_current = jasdl_activemenu[0]
	mainlis = document.getElementById("jasdl-mainnav").getElementsByTagName("li")
	for (i=0; i<mainlis.length; ++i) {
		x = mainlis[i]
		jasdl_menuindex = x.id.substr(13)

		x._id = parseInt(jasdl_menuindex)
		x.onmouseover = jasdl_mouseOver
		
		x.onmouseout = jasdl_mouseOut

		subx = document.getElementById("jasdl-subnav"+jasdl_menuindex)
		if (subx)
		{
			if (jasdl_activemenu[0] && jasdl_menuindex == jasdl_activemenu[0]) {
				subx.style.display = "block"
				subx.className = 'active';
			}else{
				subx.style.display = "none"
			}
			subx._id = jasdl_menuindex


			subx.onmouseover = jasdl_mouseOver

			subx.onmouseout = jasdl_mouseOut
		}
		
		document.getElementById("jasdl-subnav").style.display = "block";

	}

	//Set active item
	if (jasdl_activemenu[0])
	{
		actitem = document.getElementById("jasdl-mainnav"+jasdl_activemenu[0].toString())
		if (actitem)
		{
			if (actitem.className) actitem.className += " active"; else actitem.className = "active";
		}	
		jasdl_recover = jasdl_activemenu[0]
	}
	if (jasdl_activemenu[1]) {
		actitem = document.getElementById("jasdl-subnavitem"+jasdl_activemenu[1].toString())
		if (actitem)
		{
			if (actitem.className) actitem.className += " active"; else actitem.className = "active";
		}	
	}

	//Hover on sub item
	var subnav = document.getElementById ('jasdl-subnav');
	if (subnav) {
		var sublis = subnav.getElementsByTagName("li");
		for (i=0; i<sublis.length; ++i) {
			objs = sublis[i];
			var child = objs.getElementsByTagName ('ul');
			if (child && child.length) {
				objs.className += " hasChild";
				objs.onmouseover=function() {
					this.className+=" hover";
				}
				objs.onmouseout=function() {
					//this.className=this.className.replace(new RegExp("hover\\b"), "");
					this.timer = setTimeout(jasdl_sub_mouseOut.bind(this), 100);
				}
			}
		}
	}
}

function jasdl_sub_mouseOut () {
	this.className=this.className.replace(new RegExp("hover\\b"), "");
}

function jasdl_mouseOver () {
	jasdl_hide()
	jasdl_current = this._id
	jasdl_show()
	jasdl_clearTimeOut(jasdl_timeoutid)
}
function jasdl_mouseOut () {
	if (this._id != jasdl_current) return

	jasdl_timeoutid = setTimeout('jasdl_restore()', jasdl_delay)
}

function jasdl_restore () {
	jasdl_clearTimeOut(jasdl_timeoutid)
	jasdl_hide()
	if (jasdl_recover)
	{
		jasdl_current = jasdl_recover
		jasdl_show()
	}
}

function jasdl_setHover () {
	if (jasdl_current == jasdl_recover) return
	mainx = document.getElementById("jasdl-mainnav"+jasdl_current.toString())
	if (mainx)
		mainx.className += ' hover';
}

function jasdl_clearHover () {
	if (jasdl_current == jasdl_recover) return
	mainx = document.getElementById("jasdl-mainnav"+jasdl_current.toString())
	if (mainx)
		mainx.className = mainx.className.replace(/[ ]?hover/, '');
}

function jasdl_hide () {
	subx = document.getElementById("jasdl-subnav"+jasdl_current.toString())
	if (subx)
		subx.style.display = "none"
	jasdl_clearHover ()
}

function jasdl_show () {
	subx = document.getElementById("jasdl-subnav"+jasdl_current.toString())
	if (subx)
		subx.style.display = "block"
	jasdl_setHover ()
}

function jasdl_clearTimeOut(timeoutid){
	clearTimeout(timeoutid)
	timeoutid = 0
}

jaAddEvent(window, 'load', jasdl_initJAScriptDLMenu)

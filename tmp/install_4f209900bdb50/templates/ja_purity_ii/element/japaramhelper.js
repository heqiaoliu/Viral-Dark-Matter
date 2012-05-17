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


JAFormController = new Class( { 
	initialize : function( control, options ){
		// options 
		this.options =  Object.extend({ hideRow:true }, options||{ } );
		this.groups = [];	
		var _default = '';
		var groups = this.getGroup( control );
		this._control = control;

		if( $defined(groups) ) {
			groups._parent = this;
			groups.addEvents({'click': function(){
					if (this.tagName.toLowerCase() == 'select') return;					
					groups._parent.update(this.value);
				},
				'change': function() {
					if (this.tagName.toLowerCase() != 'select') return;
					groups._parent.update(this.value);
				}}
			);			
		}
		this.update(this._default);		
	},
	
	update: function(_default){
		if (!this.items) return;
		this.items.each( function( item ) {
			if( item.tagName.toLowerCase() == 'label' ) return;
			if (!_default || (item.id && item.id.test ('-'+_default+'-'))){
				display = '';
				disabled = false;
			}else{
				display = 'none';
				disabled = true;
			}
			
			
			if( this.options.hideRow == true ) { 
				var parent = this.getParentByTagName(item, "tr" );
				if( $defined(parent) ){
					parent.setStyles( {"display":display} );
				}
			}else {
				item.disabled = disabled;
			}
		}.bind(this) );
		
		this.updateHeight ();
	},
	
	getGroup: function (control) {
		var frm = document.forms['adminForm'];
		var obj = frm['params['+control+']'];
		if (!obj) return null;
		var objs;
		if (obj.tagName == 'SELECT') {
			objs = $(obj).getElements('option');
			this._tparent = this.getParentByTagName(obj, 'table');
			this._dparent = this.getParentByTagName(obj, 'div');
		} else {
			if (obj.length < 1) return null;			
			this._tparent = this.getParentByTagName(obj[0], 'table');
			this._dparent = this.getParentByTagName(obj[0], 'div');
			objs = obj = $$(obj);
		}
		objs.each (function(group){
			this.groups.push(group.value);
			if( group.selected || group.checked){ 
				this._default = group.value;
			}
		}.bind(this));
		
		this.items = $( document.adminForm ).getElements("*[id^=params"+control+"-"+"]");
		return obj;
	},
	
	updateHeight: function () {
		if (this._tparent && this._dparent && this._dparent.hasClass('content')) this._dparent.setStyle('height', this._tparent.offsetHeight);
	},
	
	getParentByTagName: function (el, tag) {
		var parent = $(el).getParent();
		while (!parent || parent.tagName.toLowerCase() != tag.toLowerCase()) {
			parent = parent.getParent();
		}
		return parent;
	}
});

var japaramhelpergroups = new Array();

function initjapramhelpergroup(control, options) {
	japaramhelpergroups.push (new JAFormController (control, options));
}

window.addEvent('load', function() {
	document.adminForm.onsubmit = function(){
		japaramhelpergroups.each (function(group){
			if (!group.options.hideRow)	group.update();
		})
	};
	setTimeout(function() {
		//alert('hupdate height');
		japaramhelpergroups.each (function(group){			
			if (group.options.hideRow)	group.updateHeight();
		});
	},400);
});

//window.addEvent ('load', function(){alert('hehe');this.updateHeight ();});
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

var jSonRequest = null;
var JAT3_ADMIN = new Class({
	initialize: function(options) {
		this.options = $extend({
			activePopIn: 0
		}, options || {});
		
		$(document.body).addEvent( 'click', function() {
			this.clearData();
		}.bind(this));
		this.initProfiles.delay(1000, this);
	},
	
	initProfiles: function () {
		//clone working copy for each profile
		for (name in profiles) {
			profile = profiles[name];
			if (!profile.local && !profile.core) continue;
			profile.working = $extend({},profile.local?profile.local:profile.core);
		};
		
		this.fillData('default', 'params');
		//reupdate
		profiles['default'].working = this.rebuildData('params');
		profiles['generalconfigdata'] = this.rebuildData('general');
		
		//Init profile action
		var ptitles = $$('.ja-profile');
		ptitles.each (function (ptitle) {
			isdefault = ptitle.hasClass('default');
			ptitle.addEvents ({
				'click': this.changeProfile.bind (this, ptitle),
				'mouseenter': function () {/*console.log ('mouse over: '+ptitle.getText())*/}
			});
		}, this);
		
		this.checkModified.periodical(1000, this);		
	}, 
		
	checkModified: function () {
		var tab = $E('#ja-tabswrap .ja-tabs-title .active');
		if (!tab) return;
		if (tab.hasClass ('profiles')) {
			working = this.rebuildData('params');
			var profile = profiles[this.active_profile];
			if(!$type(profile) || (!$type(profile.local) && !$type(profile.core))) return;
			
			var saved = profile.local?profile.local:profile.core;
			var changed = false;
			var els = this.serializeArray('params');
			
			var working_temp = null;
			var pro_temp = null;
			
			els.each(function(el){
				var name = this.getName(el, 'params');
				working_temp = working[name];
				pro_temp = saved[name];
				
				if( working[name]!=undefined){
					working_temp = working[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');					
				}
				if( saved[name]!=undefined){
					pro_temp = saved[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');					
				}
				if ( (saved[name] != undefined || working[name] != undefined) && pro_temp != working_temp) {
					el.getParent().getParent().addClass('changed');
					changed = true;
				}
				else{
					el.getParent().getParent().removeClass('changed');
				}
			},this);
			
			var li = $E('.ja-profile-titles .active');
			if($type(li)){
				if (changed) {
					li.addClass ('changed');
					tab.addClass ('changed');
				
				} else {
					li.removeClass ('changed');
					if (!$E('.ja-profile-titles .changed')) tab.removeClass ('changed');
					
				}	
			}
		}

		if (tab.hasClass ('general')) {

			//check change for general tab
			var working = this.rebuildData('general');
			var saved = profiles['generalconfigdata'];
			var changed = false;
			var els = this.serializeArray('general');
			
			var working_temp = null;
			var pro_temp = null;
			
			els.each(function(el){
				var name = this.getName(el, 'general');
				if( working[name]!=undefined){
					working_temp = working[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');					
				}
				if( saved[name]!=undefined){
					pro_temp = saved[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');			
				}
				if ((saved[name] != undefined || working[name] != undefined) && working_temp != pro_temp) {
					el.getParent().getParent().addClass('changed');
					changed = true;
				}
				else{
					el.getParent().getParent().removeClass('changed');
				}
			},this);
			if (changed) {
				tab.addClass ('changed');
			} else {
				tab.removeClass ('changed');
			}				
		}				
	},
	
	checkModifiedAll: function () {
		//check general
		//check change for general tab
		var tab = $E('#ja-tabswrap .ja-tabs-title .general');
		var working = this.rebuildData('general');
		var saved = profiles['generalconfigdata'];
		var changed = false;
		var els = this.serializeArray('general');
		
		var working_temp = null;
		var pro_temp = null;
		
		els.each(function(el){
			var name = this.getName(el, 'general');
			if( working[name]!=undefined){
				working_temp = working[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');					
			}
			if( saved[name]!=undefined){
				pro_temp = saved[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');					
			}
			if ((saved[name] != undefined || working[name] != undefined) && working_temp != pro_temp) {
				changed = true;
				el.getParent().getParent().addClass('changed');
			}
			else{
				el.getParent().getParent().removeClass('changed');
			}
		},this);
		if (changed) {					
			tab.addClass ('changed');
		} else {
			tab.removeClass ('changed');
		}				

		//Check profiles
		var pname = $$('#ja-tabswrap .ja-profile-titles li.ja-profile');
		var els = this.serializeArray('params');
		var tab = $E('#ja-tabswrap .ja-tabs-title .profiles');		
		pname.each (function(li) {
			var profile = profiles[li.getElement('.ja-profile-title').getText().toLowerCase().clean()];
			var working = profile.working?profile.working:null;
			var saved = profile.local?profile.local:profile.core;
			var changed = false;
			
			els.each(function(el){
				var name = this.getName(el, 'params');
				
				if( working[name]!=undefined){
					working_temp = working[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');					
				}
				if( saved[name]!=undefined){
					pro_temp = saved[name].clean().toString().replace (/\\n/g, '').replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '').replace (/amp;amp;amp;amp;/g, '&');				
				}
				
				if ( (saved[name] != undefined || working[name] != undefined) && working_temp != pro_temp ) {
					el.getParent().getParent().addClass('changed');
					changed = true;
				}
				else{
					el.getParent().getParent().removeClass('changed');
				}
			},this);
						
			if (changed) {
				li.addClass ('changed');
				
			} else {
				li.removeClass ('changed');
				
			}			
		},this);
		if (!$E('.ja-profile-titles .changed')) tab.removeClass ('changed');
		else tab.addClass ('changed');				
	},
	
	saveData: function (obj){
		obj = $(obj);
		/* Rebuild data */
		
		var url = 'index.php?jat3action=saveData&jat3type=plugin&template='+template;
		
		if($type(document.adminForm['default'])){
			url += '&default='+document.adminForm['default'].value;
		}
		else{
			url += '&default=0';
		}
		if($type($('selections'))){
			url += '&selections='+$('selections').getValue();
		}
		var json = {};
		//save profiles & general: send changed data only
		var tab = $E('#ja-tabswrap .ja-tabs-title .general');
		if (tab.hasClass ('changed')) {
			json['generalconfigdata'] = this.rebuildData('general');
		}
		var tab = $E('#ja-tabswrap .ja-tabs-title .profiles');
		var name = null;
		if (tab.hasClass ('changed')) {
			profiles[this.active_profile].working = this.rebuildData('params');
			var pnames = $$('#ja-profiles-content .ja-profile-titles li.changed');
			if (pnames) {
				json['profiles'] = {};
				pnames.each (function (pname) {
					name = pname.getElement('.ja-profile-title').getText().toLowerCase();
					json['profiles'][name] = profiles[name].working;
				},this);
			}
		}
		this.submitForm(url, json, obj);				
	},
	
	
	saveGeneral: function (obj){
		obj = $(obj);
		/* Rebuild data */
		profiles['general'] = this.rebuildData('general');
		//data = profiles['general'].replace (/\n/g, '\\n').replace (/\t/g, '\\t');
		var url = 'index.php?jat3action=saveGeneral&jat3type=plugin&template='+template;
		this.submitForm(url, profiles['general'], obj);		
	},
		
	
	submitForm: function(url, request, obj, type) {		
		if(!requesting){
			requesting = true;
		}
		else{
			jSonRequest.cancel();
		}
		
		obj = $(obj);
		if($type(obj))	obj.addClass('jat3-loading');
		jSonRequest = new Json.Remote(url, {
			onComplete: function(result){
				requesting = false;
				
				if($type(obj))	obj.removeClass('jat3-loading');
				var contentHTML = '';
				if (result.successful) {
					contentHTML += "<div class=\"success-message\"><span class=\"success-icon\">"+result.successful+"</span></div>";
				}
				if (result.error) {
					contentHTML += "<div class=\"error-message\"><span class=\"error-icon\">"+result.error+"</span></div>";
				}
				
				if($type($('toolbar-box'))){
					if(!$type($('system-message'))){
						var msgobj = new Element('div', {'id': 'system-message', 'class':'clearfix'});
						msgobj.injectAfter($('toolbar-box'));
					}
					$('system-message').innerHTML = contentHTML;
					if (!this.msgslider) {
						this.msgslider = new Fx.Slide('system-message');
					}
					$clear(this.timer);
					this.msgslider.hide ();
					this.msgslider.slideIn.delay (100, this.msgslider);
					this.timer = this.msgslider.slideOut.delay (10000, this.msgslider);
				}
				
				//Update status
				if (result.generalconfigdata) {
					profiles.generalconfigdata = request.generalconfigdata;
					//$E('#ja-tabswrap .ja-tabs-title .general').removeClass ('changed');
					var rows = $E('#pages_profile-ja-list-pageids').rows;
					for(var i=0; i<rows.length; i++){
						$(rows[i]).removeClass('changed');
					}
				}
				
				if(result.profile){
					switch (result.type){						
						case 'new':{
							profilename = result.profile;
							var item = null;
							var lis = $$('#ja-profiles-content li.ja-profile');
							for(var i=0; i<lis.length; i++){
								item = lis[i];
								if(item.getElement('.ja-profile-title').getText().toLowerCase().trim()==profilename){
									alert(lg_profile_name_exist.replace('%s', profilename));
									if(!this.saveas){
										return this.newProfile(obj, this.saveas);
									}
									else{
										$E('ul.ja-profile-titles li.default').addClass('active');
									}
									return ;
								}
								else if(item.className.indexOf('active')>-1){
									item.removeClass('active');
								}
							}						
							
							/* add new tab */
							var tab = new Element('li', {
														'class': 'ja-profile',
														'events': {
																	'click': function (){
																		this.changeProfile(tab);
																						
																	}.bind(this)}
														});						
							tab.addClass('active');
							tab.injectBefore($E('ul.ja-profile-titles li.ja-profile-new').getPrevious());
							
							var span = new Element('span', {'class':'ja-profile-title'});
							span.setText(profilename);
							span.injectInside(tab);			
							
							var span = $E('#ja-profiles-content span.ja-profile-action').clone();
							span.setStyle('display', 'inline');			
							span.injectInside(tab);
							
							span.addEvent ('click', function (event){
								this.showProfileAction(span);
								event = new Event(event);
								$('ja-profile-action').setStyles ({
									'top': event.page.y,
									'left': event.page.x,
									'display': 'inline'
								});
								event.stop();
							}.bind(this));
							
							this.fillData (profilename, 'params');
							
							/* add new tab */
							li = new Element('li');
							li.injectInside($E('ul.ja-popup-profiles'));
							li.innerHTML = '<a onclick="jaclass_pages_profile.select_profile(this);" href="javascript:void(0)">'+result.profile+'</a>'							
						}break;
						
						case 'rename':{
							var lis = $E('ul.ja-popup-profiles').getChildren();
							lis.each( function (li) {
								if(li.getFirst().getText().clean()==result.profileolder){
									li.getFirst().setText(result.profile);							
								}
							});
							
							var span = $E('#ja-profiles-content li.active span.ja-profile-title');
							if($type(span)){
								span.setText(result.profile);
								this.active_profile = result.profile;
							}	
							
							
							var lis = $E('table.ja-list-pageids').rows;
							var item = null;
							for(var i=1; i<lis.length; i++){
								item = $(lis[i])
								if($E('span.profile_text', item).getText().clean()==result.profileolder){
									$E('span.profile_text', item).setText(result.profile);
									item.addClass('changed');
								}
							}
							jaclass_pages_profile.buildData_of_param();
							
						}break;
						
						case 'delete':{
							$E('#ja-profiles-content li.active').remove();
							profiles[result.profile] = null;
							var firstitem = $E('#ja-profiles-content .ja-profile');
							firstitem.addClass('active');
							this.active_profile = firstitem.getText().trim().toLowerCase();
							this.fillData (this.active_profile, 'params');
							
							var lis = $E('ul.ja-popup-profiles').getChildren();
							lis.each( function (li) {
								if(li.getFirst().getText().clean()==result.profile){
									li.remove();									
								}
							});
														
							var lis = $E('table.ja-list-pageids').rows;
							var item = null;
							for(var i=1; i<lis.length; i++){
								item = $(lis[i]);
								if($E('span.profile_text', item).getText().clean()==result.profile){
									$E('span.profile_text', item).setText('default');
									item.addClass('changed');
								}
							}
							jaclass_pages_profile.buildData_of_param();							
							$('ja-profile-action').hide();
						}break;
						
						case 'reset':{
							profiles[result.profile].local = null;
							profiles[result.profile].working = profiles[result.profile].core;
							this.fillData (result.profile, 'params');
							$E('#ja-tabswrap li.profiles').removeClass('changed');
						}break;
						
						default:
							//nothing
					}
					
				}
				
				else if(result.layout){	
					$('ja-layout-container').hide();
					
					if($type(layouts[this.layout])){
						layouts[result.layout] = layouts[this.layout];
					}
					if(layouts[result.layout].local!=null && layouts[result.layout].core!=null && !this.isnew){
						var spanexist = $E('#layout_' + result.layout + ' span.reset');
						if(!$type(spanexist)){
							var span = new Element('span', {
								'class': 'reset'
							});							
							var args = new Array(span, result.layout);
							span.addEvent('click', this.resetLayout.pass(args, this));
							span.setText('Reset to default');
							if($type($('layout_' +result.layout))){
								span.injectInside($('layout_' +result.layout).getLast());
							}
							span.show();
						}
						else{
							spanexist.show();
						}
						
					}
					
					this.layout = result.layout;
					
					switch (result.type){						
						case 'new':{
							/* add new tab */
							var lis = $E('#ja-layouts-content .ja-layout-titles').rows;
							var tr = $(lis[1]).clone();
							tr.setProperty('id', 'layout_' + result.layout);
							if(lis.length%2!=0) tr.className = 'row0';
							else tr.className = 'row1';
							tds = tr.getChildren();
							tds[0].setText(lis.length);
							tds[1].setText(result.layout);
							
							tr.injectAfter(lis[lis.length-1]);
							tds[2].setText('');
							contentHTML = '<span class="edit" onclick="jat3admin.editLayout(\''+ result.layout +'\')">Edit</span> ';
							contentHTML += '<span class="clone" onclick="jat3admin.saveasLayout(this, \''+ result.layout +'\')">Clone</span> ';
							contentHTML += '<span class="rename" onclick="jat3admin.renameLayout(this, \''+ result.layout +'\')">Rename</span> ';
							contentHTML += '<span class="delete" onclick="jat3admin.deleteLayout(this, \''+ result.layout +'\')">Delete</span>';
							tds[2].innerHTML = contentHTML;
							
							/* Add item in profile page */
							var selectors = $$('select.jat3-el-layouts');
							selectors.each(function (select){
								select.options[select.length] = new Option(result.layout, result.layout);
							});
							
							jatabs.resize();							
						}break;
						
						case 'rename':{
							/*var tr = $('layout_'+result.layoutolder);
							tr.setProperty('id', 'layout_'+result.layout);							
							tr.getChildren()[1].setText(result.layout);
							
							contentHTML = '<span class="edit" onclick="jat3admin.editLayout(\''+ result.layout +'\')">Edit</span> ';
							contentHTML += '<span class="clone" onclick="jat3admin.saveasLayout(this, \''+ result.layout +'\')">Clone</span> ';
							contentHTML += '<span class="rename" onclick="jat3admin.renameLayout(this, \''+ result.layout +'\')">Rename</span> ';
							contentHTML += '<span class="delete" onclick="jat3admin.deleteLayout(this, \''+ result.layout +'\')">Delete</span>';
							
							tr.getChildren()[2].innerHTML = contentHTML;
							
							 Remove item in profile page 
							var selectors = $$('select.jat3-el-layouts');
							selectors.getChildren().each(function (select, i){
								select.each(function (op, k){
									if(op.value.clean()==result.layoutolder){																				
										op.value = result.layout;
										op.text = result.layout;
									}
								})
							});*/
							if(window.location.href.indexOf('#')){
								window.location.href = window.location.href.replace('#', '') + '&tab=layout';
							}
							else{
								window.location.href = window.location.href + '&tab=layout';
							}
						}break;
						
						case 'delete':{
							/* Remove this row on Layout table*/
							/*layouts[result.layout].core = null;
							layouts[result.layout].local = null;
							$('layout_' + result.layout).remove();
							jatabs.resize();
							
							 Remove item in profile page 
							var selectors = $$('select.jat3-el-layouts');
							selectors.getChildren().each(function (select, i){
								select.each(function (op, k){
									if(op.value.clean()==result.layout){					
										selectors[i].remove(k);																														
										return;
									}
								});
								
							});*/
							if(window.location.href.indexOf('#')){
								window.location.href = window.location.href.replace('#', '') + '&tab=layout';
							}
							else{
								window.location.href = window.location.href + '&tab=layout';
							}
						}break;
					
					}
					
				}
				
				if(result.reset && $type(obj)){
					obj.hide();
				}
				
				if (result.profiles) {
					for(p in result.profiles) {
						if (result.profiles[p]) {
							profiles[p].local = request['profiles'][p];
						}
					}
				}
				
				
				
				/* Remove class "changed" for all element*/
				var rows = $E('#jat3-profile-params table.paramlist').rows;
				for(var i=0; i<rows.length; i++){
					$(rows[i]).removeClass('changed');
				}
				
				this.checkModifiedAll ();
			}.bind(this)
		}).send(request);
	},
	
	hideMessage: function(){
		var slider = new Fx.Slide('system-message');
		slider.toggle();
	},
	
	/****  Functions of Profile  ----------------------------------------------   ****/
	resetProfile: function(profile){
		if(confirm(lg_confirm_reset_profile)){
			profiles[profile].local = null;
			var url = 'index.php?jat3action=resetProfile&jat3type=plugin&template='+template+'&profile='+profile;		
			this.submitForm(url, profiles[profile], null, 'profile');
		}
	},
	
	deleteProfile: function (profile){		
		if(confirm(lg_confirm_delete_profile)){			
			var url = 'index.php?jat3action=deleteProfile&jat3type=plugin&template='+template+'&profile='+profile;		
			this.submitForm(url, Json.evaluate('{}'), null, 'profile');
		}
	},
	
	renameProfile: function (current_profile){
		var profilename = prompt(lg_confirm_rename_profile + '\n\n' + lg_enter_profile_name , current_profile);
		var item = null;
		if($type(profilename)){
			profilename = profilename.clean().replace(' ', '').toLowerCase().trim();
			if(profilename==''){
				alert(lg_please_enter_profile_name);
				return this.renameProfile(current_profile);
			}		
			else if(current_profile==profilename){
				//nothing
				return;
			}
			
			var lis = $$('#ja-profiles-content li.ja-profile');
			for(var i=0; i<lis.length; i++){
				item = lis[i];
				if(item.getElement('.ja-profile-title').getText().toLowerCase().trim()==profilename){
					alert(lg_profile_name_exist.replace('%s', profilename));
					return this.renameProfile(current_profile);
				}
			}
			
			profiles[profilename] =  profiles[current_profile];		
			profiles[current_profile] = null;
			var url = 'index.php?jat3action=renameProfile&jat3type=plugin&template='+template+'&current_profile='+current_profile+'&new_profile='+profilename;		
			this.submitForm(url, profiles[profilename], null, 'profile');
		}
	},
				
	saveasProfile: function(oldprofilename){
		this.newProfile($E('#ja-profiles-content li.ja-profile-new'), true, oldprofilename+'-copy');
	},
	
	newProfile: function(obj, saveas, oldprofilename){
		obj = $(obj);
		if(oldprofilename==null) oldprofilename = '';
		var profilename = prompt(lg_enter_profile_name, oldprofilename);
		
		if($type(profilename)){	
			if(profilename.clean()==''){
				alert(lg_please_enter_profile_name);
				return this.newProfile(obj, saveas);
			}
			profilename = profilename.clean().replace(' ', '').toLowerCase().trim();
			
			var lis = $$('#ja-profiles-content li.ja-profile');
			var item = null;
			for(var i=0; i<lis.length; i++){
				item = lis[i];
				if(item.getElement('.ja-profile-title').getText().toLowerCase().trim()==profilename){
					alert(lg_profile_name_exist.replace('%s', profilename));
					return this.newProfile(obj, saveas, oldprofilename);
				}				
			}
			
			var url = 'index.php?jat3action=saveProfile&jat3type=plugin&template='+template+'&profile='+profilename;
			
			if($type(document.adminForm['default'])){
				url += '&default='+document.adminForm['default'].value;
			}
			else{
				url += '&default=0';
			}
			
			if(saveas){
				this.saveas = true;
				profiles[profilename] = Json.evaluate('{}');
				profiles[profilename].local = this.rebuildData('params');
				profiles[profilename].working = profiles[profilename].local;			
			}
			else{
				this.saveas = false;
				profiles[profilename] = Json.evaluate('{}');
				profiles[profilename].local = Json.evaluate('{}');
				profiles[profilename].working = Json.evaluate('{}');
			}								
			
			this.submitForm(url, profiles[profilename].working, $('jat3-loading'), 'profile');
		}
		
	},
	
	saveProfile: function (obj){
		/* Rebuild data */
		obj = $(obj);
		var lis = $$('#ja-profiles-content .ja-profile-titles')[0].getChildren();
		var pre_Obj = null;
		for(var i=0; i<lis.length; i++){
			item = lis[i];
			if(item.className.indexOf('active')>-1){				
				pre_Obj = item;
				break;
			}
		}
		var profile = '';
		if($type(pre_Obj) && $type(pre_Obj.getFirst())){
			profile = pre_Obj.getFirst().getText().trim().toLowerCase();
			profiles[profile] = this.rebuildData('params');				
		}
		if(profile==''){
			alert(lg_select_profile);
			return;
		}
				
		var url = 'index.php?jat3action=saveProfile&jat3type=plugin&template='+template+'&profile='+profile;
		
		if($type(document.adminForm['default'])){
			url += '&default='+document.adminForm['default'].value;
		}
		else{
			url += '&default=0';
		}
		if($type($('selections'))){
			url += '&selections[]='+$('selections').getValue();
		}
		
		this.submitForm(url, profiles[profile], obj, 'profile');
	},
	
	
	showProfileAction: function(el){
		var profilename = el.getPrevious().getText().toLowerCase().trim();
		var profile = profiles[profilename];
		
		$E('#ja-profile-action li.rename').hide();
		$E('#ja-profile-action li.reset').hide();
		$E('#ja-profile-action li.delete').hide();
		
		if(profile.local){
			if(profile.core){
				$E('#ja-profile-action li.reset').show();
			}
			else{
				$E('#ja-profile-action li.rename').show();
				$E('#ja-profile-action li.delete').show();
			}
		}
		
		$E('#ja-profile-action li.saveas').onclick = function (){
			$('ja-profile-action').hide();
			this.saveasProfile(profilename);
		}.bind(this);
		$E('#ja-profile-action li.rename').onclick = function (){
			$('ja-profile-action').hide();
			this.renameProfile(profilename)
		}.bind(this);
		$E('#ja-profile-action li.reset').onclick = function (){
			$('ja-profile-action').hide();
			this.resetProfile(profilename)
		}.bind(this);
		$E('#ja-profile-action li.delete').onclick = function (){
			$('ja-profile-action').hide();
			this.deleteProfile(profilename)
		}.bind(this);
		
		this.options.activePopIn = 1;		
	},
	
	changeProfile: function (obj){
		obj = $(obj);
		/* Set tab activity */
		var lis = $$('#ja-profiles-content .ja-profile-titles')[0].getChildren();
		var pre_Obj = null;
		var item = null;
		for(var i=0; i<lis.length; i++){
			item = lis[i];
			if(item.className.indexOf('active')>-1){
				item.removeClass('active');
				pre_Obj = item;
				break;
			}
		}
		obj.addClass('active');
		/* Rebuild data */
		if($type(pre_Obj) && $type(pre_Obj.getFirst())){
			profiles[pre_Obj.getElement('.ja-profile-title').getText().trim().toLowerCase()].working = this.rebuildData('params');
		}
		
		this.fillData (obj.getElement('.ja-profile-title').getText().trim().toLowerCase(), 'params');
	},
	
	/****  Functions of Layout  ----------------------------------------------   ****/
	newLayout: function(obj){
		obj = $(obj);
		$E('#ja-layout-container .layout-name').show();
		$('ja-layout-container').setStyles ({
			'top': window.getHeight()/2 + window.getSize().scroll.y -$('ja-layout-container').getStyle('height').toInt()/2,
			'left': window.getWidth()/2-$('ja-layout-container').getStyle('width').toInt()/2,
			'display': 'block'
		});
		$('content_layout').value = '';
		$('name_layout').value = '';
		$('name_layout').focus();
		this.isnew = true;		
	},
	
	editLayout: function(layout){		
		$E('#ja-layout-container .layout-name').hide();
		$('ja-layout-container').setStyles ({
			'top': window.getHeight()/2 + window.getSize().scroll.y -$('ja-layout-container').getStyle('height').toInt()/2,
			'left': window.getWidth()/2-$('ja-layout-container').getStyle('width').toInt()/2,
			'display': 'block'
		});
		$('content_layout').value = layouts[layout].local!=null?layouts[layout].local:layouts[layout].core;
		$('name_layout').value = layout;
		$('content_layout').focus();
		this.layout = layout;
		this.isnew = false;
		this.contentLayout =  $('content_layout').value.clean().toString().replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '');
	},
	
	cancelLayout: function(){		
		layout = this.layout;
		var new_content = $('content_layout').value.clean().toString().replace (/\n/g, '').replace (/\t/g, '').replace (/\r/g, '');
		
		if( (!this.isnew && new_content!=this.contentLayout.trim()) || (this.isnew && new_content!='')){
			if(confirm(lg_confirm_to_cancel)){
				$('ja-layout-container').hide();
			}
		}
		else{
			$('ja-layout-container').hide();
		}
	},
	
	resetLayout: function(obj, layout){
		obj = $(obj);
		if(confirm(lg_confirm_reset_layout)){
			layouts[layout].local = null;
			var url = 'index.php?jat3action=resetLayout&jat3type=plugin&template='+template+'&layout='+layout;		
			this.submitForm(url, layouts[layout], obj, 'layout');
		}
	},
	
	deleteLayout: function (obj, layout){		
		obj = $(obj);
		if(confirm(lg_confirm_delete_layout)){
			this.layout = layout;
			var url = 'index.php?jat3action=deleteLayout&jat3type=plugin&template='+template+'&layout='+layout;		
			this.submitForm(url, layouts[layout], obj, 'layout');
		}
	},
	
	renameLayout: function (obj, current_layout){
		obj = $(obj);
		var layoutname = prompt( lg_confirm_rename_layout + '\n\n' + lg_enter_layout_name, current_layout);
		var item = null;
		if($type(layoutname)){
			layoutname = layoutname.clean().replace(' ', '').toLowerCase();			
			if(layoutname==''){
				alert(lg_please_enter_layout_name);
				return this.renameLayout(obj, current_layout);
			}
			else if(current_layout==layoutname){
				//nothing
				return;
			}
			
			var lis = $E('#ja-layouts-content .ja-layout-titles').rows;			
			for(var i=1; i<lis.length; i++){
				item = $(lis[i]);
				if(item.id.toLowerCase().trim()=='layout_'+layoutname){
					alert(lg_layout_name_exist.replace('%s', layoutname));
					return this.renameLayout(obj, current_layout);
				}
			}
			layouts[layoutname] = layouts[current_layout];
			
			var url = 'index.php?jat3action=renameLayout&jat3type=plugin&template='+template+'&current_layout='+current_layout+'&new_layout='+layoutname;		
			this.submitForm(url, Json.evaluate('{}'), obj, 'layout');
		}
	},
	
	saveasLayout: function (obj, current_layout){
		obj = $(obj);
		new_layout = current_layout+'-copy'		
		var layoutname = prompt(lg_enter_layout_name, new_layout);
		this.isnew = false;
		var item = null;
		
		if($type(layoutname)){
			if(layoutname==''){
				alert(lg_please_enter_layout_name);
				return this.saveasLayout(obj, current_layout);
			}
			layoutname = layoutname.clean().replace(' ', '').toLowerCase();
			
			var lis = $E('#ja-layouts-content .ja-layout-titles').rows;			
			for(var i=1; i<lis.length; i++){
				item = $(lis[i]);
				if(item.id.toLowerCase().trim()=='layout_'+layoutname){
					alert(lg_layout_name_exist.replace('%s', layoutname));
					return this.saveasLayout(obj, current_layout);
				}
			}
			
			layouts[layoutname] = Json.evaluate('{}');
			layouts[layoutname].core = null;
			
			layoutindex = obj.getParent().getParent().id.substr(7);
			
			var obj_layout = layouts[layoutindex];
			$('content_layout').value = obj_layout.local!=null?obj_layout.local:obj_layout.core;
			
			layouts[layoutname].local = $('content_layout').value;
			
			this.layout = layoutname;
			this.saveLayout(obj);						
		}
		
	},
	
	saveLayout: function (obj){		
		obj = $(obj);		
		
		if(!this.isnew){			
			var layout = this.layout;
		}
		else{
			var layout = $('name_layout').value;
		}
		layout = layout.clean().replace(' ', '').toLowerCase();
		
		if(layout==''){
			if(this.isnew){
				alert(lg_please_enter_layout_name);
				$('name_layout').focus();
			}
			else{
				alert(lg_select_layout);
			}
			return;
		}
		else if(this.isnew){
			var item = null;
			var lis = $E('#ja-layouts-content .ja-layout-titles').rows;			
			for(var i=1; i<lis.length; i++){
				item = $(lis[i]);
				if(item.id.toLowerCase().trim()=='layout_'+layout){
					alert(lg_layout_name_exist.replace('%s', layout));
					$('name_layout').focus();
					return ;
				}
			}
		}		
		/*if(!confirm(lg_confirm_save_layout.replace('%s', layout))){
			return;
		}*/
		
		if(this.isnew){
			this.layout = layout;
			layouts[layout] = Json.evaluate('{}');
			layouts[layout].core = null;
			layouts[layout].local = ' ';
		}
		
		var content = $('content_layout').value.trim();
		layouts[layout].local = content;
		var json = {xml: content.replace (/\n/g, '\\n').replace (/\t/g, '\\t').replace (/\r/g, '')};
		
		var url = 'index.php?jat3action=saveLayout&jat3type=plugin&template='+template+'&layout='+layout;		
		this.submitForm(url, json, obj, 'layout');
	},
		
	updateGfont: function(obj, msg) {
		if(!requesting){
			requesting = true;
		} else {
			jSonRequest.cancel();
		}
		
		if (!confirm(msg)) return;
		
		obj = $(obj);
		
		var json = {};
		var url = 'index.php?jat3action=updateGfont&jat3type=plugin&template='+template;
		
		if ($type(obj)) obj.addClass('jat3-loading');
		jSonRequest = new Json.Remote(url, {
			onComplete: function(result){
				requesting = false;
				if ($type(obj)) obj.removeClass('jat3-loading');
				
				if (result.successful) {
					isReload = confirm(result.successful);
					location.reload(isReload);
				}
				else if (result.error) {
					alert(result.error);
				}
			}.bind(this)
		}).send(json);
	},		
	
	
	rebuildData: function (group){
		var els = this.serializeArray(group);
		var json = {};
		els.each(function(el){
			var rel = el.getProperty('rel');
			var name = this.getName(el, group);
			
			if( name!='' && ( !$type($('cb_'+name)) || ( $type($('cb_'+name)) &&  $('cb_'+name).checked==true )) ){
				json[name] = el.getValue(rel).toString().replace (/\n/g, '\\n').replace (/\t/g, '\\t').replace (/\r/g, '').replace (/&/g, 'amp;amp;amp;amp;');
			}
			
		}, this);
		return json;
	},
	
	fillData: function (profile, group){
		this.active_profile = profile;
		var els = this.serializeArray(group);
		
		if(els.length==0) return;				
		
		if (profiles[profile] == undefined) return;
		
		var cprofile = profiles[profile].working;
		var dprofile = profiles['default'].working;
		
		els.each( function(el){	
			var name = this.getName(el, group);
			var rel = el.getProperty('rel');
			var el_tr = this.getParentofelement(el);
			
			if(profile != 'default'){
				/* add checkbox if not default */				
				if(!$('cb_' + name) && el_tr){
					var checkbox = new Element('span', {
															'id'	: 'cb_' + name,
															'value'	: '1',
															'class' : 'cb-span',
															'events': {
																	'click': function (){
																		if(!this.checked){
																			el_tr.removeClass('disabled');
																			el.enable(rel);
																			this.checked = true;
																			this.addClass ('cb-span-checked');
																		}
																		else{
																			el_tr.addClass('disabled');										
																			el.disable(rel);
																			this.checked = false;
																			this.removeClass ('cb-span-checked');
																		}
																	}
															}
														});
					checkbox.inject(el_tr.getLast());
					checkbox.checked = false;
				}
				if ($('cb_' + name)) $('cb_' + name).show();
			} else {
				if ($('cb_' + name)) {
					$('cb_' + name).hide();
					$('cb_' + name).checked = true;
				}
			}
			var value = (cprofile[name] != undefined)?cprofile[name]:((dprofile[name] != undefined)?dprofile[name]:'');
			el.setValue(value, rel);
			if (profile == 'default' || cprofile[name] != undefined) {
				el_tr.removeClass('disabled');
				el.enable (rel);
				if ($('cb_' + name)) {
					$('cb_' + name).checked = true;
					$('cb_' + name).addClass ('cb-span-checked');
				}
			} else {
				el_tr.addClass('disabled');
				el.disable (rel);
				if ($('cb_' + name)) {
					$('cb_' + name).checked = false;
					$('cb_' + name).removeClass ('cb-span-checked');
				}
			}			
		}, this);
		
/*		if(this.isfireevent == undefined){
			els.each( function(el){
				el.addEvent('change', this.checkModified.bind(this));
			}.bind(this));
			this.isfireevent = true;
		}
*/	},
	
	serializeArray: function(group){
		var els = new Array();
		var allelements = $(document.adminForm).elements;
		
		var k = 0;
		for (i=0;i<allelements.length;i++) {
		    var el = $(allelements[i]);
		    if (el.name && ( el.name.test (group+'\\[.*\\]' || el.name.test (group+'\\[.*\\]\\[\\]'))) ){
		    	els[k] = $(el);
		    	k++;
		    }
		}
		return els;
	},
		
	getName: function (el, group){
		if (matches = el.name.match(group+'\\[([^\\]]*)\\]')) return matches[1];
		return '';
	},
	
	getParentofelement: function(el){
		var parent = $(el).getParent();
		if(parent.tagName!='TR'){
			return this.getParentofelement(parent);
		}
		else{
			return parent;
		}
	},
	removeTheme: function (obj, theme, template){
		obj = $(obj);
		this.theme_active = theme;
		
		if(theme=='' || template==''){
			alert(lg_invalid_info);
			return;
		}
		if(confirm(lg_confirm_delete_theme)){
			this.row_active = obj;			
			obj.getFirst().src = imgloading;
			
			var url = 'index.php?jat3action=removeTheme&jat3type=plugin&template='+template+'&theme='+theme;
			new Ajax(url, {method:'get', onComplete:this.updateTheme.bind(this)}).request();
		}
	},
	
	updateTheme: function (text){
		if(text!=''){
			alert(text);
			this.row_active.getFirst().src = imgdelete;
		}
		else{
			if(window.location.href.indexOf('#')){
				window.location.href = window.location.href.replace('#', '') + '&tab=theme';
			}
			else{
				window.location.href = window.location.href + '&tab=theme';
			}
			/*var els_themepopup = $$('ul.ja-popup-themes');
			els_themepopup.each(function (el){
				lis = el.getChildren();
				lis.each(function(li){					
					if($type(li.getFirst()) && li.getFirst().getText().trim().toLowerCase()==this.theme_active.toLowerCase()){
						li.remove();
					}
				}, this)
			}, this);
			$(this.row_active.getParent().getParent()).remove();*/
		}
	},
	
	clearData: function(){
		if (this.options.activePopIn == 1) {
			$('ja-profile-action').hide();
			this.options.activePopIn = 0;			
		}	
	},
	
	closeHelp: function(obj, close){
		obj = $(obj);
		obj.getParent().hide();
		Cookie.set(obj.getParent().id, 'true', {duration: 365});
		jatabs.resize();
	},
	showHelp: function(obj){
		obj = $(obj);
		if(obj.getStyle('display')=='none'){		
			obj.show();
		}
		else{
			obj.hide();
		}
		jatabs.resize();
	}
});

if (MooTools.version >= '1.2') {
	Element._extend = Element.implement;
} else {
	Element._extend = Element.extend;
}

Element._extend ({
	getType: function() {
		var tag = this.tagName.toLowerCase();
		switch (tag) {
			case 'select':
			case 'textarea':
				return tag;	
			case 'input':
				if($type(this.type) && ( this.type=='text' || this.type=='password' || this.type=='hidden')){
					return this.type;
				}
				else{
					return  document.getElementsByName(this.name)[0].type;
				}
			default:
				return '';
		}
	},
	show: function(){
		this.setStyle('display', 'block');
	},
	hide: function(){
		this.setStyle('display', 'none');
	},
	disable: function (rel){
		if(rel!='null' && $type(window[rel+'_disable'])=='function'){
			window[rel+'_disable'](this.id);
		}
		else{
			switch (this.getType().toLowerCase()) {
				case 'submit':
				case 'hidden':
				case 'password':
				case 'text':
				case 'textarea':
				case 'select':
					this.disabled = true;
					break;
				case 'checkbox':
				case 'radio':
					fields = document.getElementsByName(this.name);		
					$each(fields, function(option){
						option.disabled = true;
					});
				
			}
		}
	},
		
	enable: function (rel){
		if(rel!='null' && $type(window[rel+'_enable'])=='function'){
			window[rel+'_enable'](this.id);
		}
		else{
			switch (this.getType().toLowerCase()) {
				case 'submit':
				case 'hidden':
				case 'password':
				case 'text':
				case 'textarea':
				case 'select':
					this.disabled = false;
					break;
				case 'checkbox':
				case 'radio':
					fields = document.getElementsByName(this.name);		
					$each(fields, function(option){
						option.disabled = false;						
					});
				
			}
		}
	},
	
	setValue : function(newValue, rel) {
		if(rel!='null' && $type(window[rel+'_setValue'])=='function'){
			window[rel+'_setValue'](this.id, newValue);
		}
		else{
		
			switch (this.getType().toLowerCase()) {
				case 'submit':
				case 'hidden':
				case 'password':
				case 'text':
				case 'textarea':
					this.value=newValue;
					break;
				case 'checkbox':
					this.setInputCheckbox(newValue);
					break;
				case 'radio':
					this.setInputRadio(newValue);
					break;
				case 'select':	
					this.setSelect(newValue);
					break;
			}
			this.fireEvent('change');
			this.fireEvent('click');			
		}
	},
	
	getValue: function (rel){
		if(rel!='null' && $type(window[rel+'_getValue'])=='function'){
			return window[rel+'_getValue'](this.id);
		}
		else{
			
			switch (this.getType().toLowerCase()) {
				case 'submit':
				case 'hidden':
				case 'password':
				case 'text':
				case 'textarea':
					return this.value;
				case 'checkbox':
					return this.getInputCheckbox();
				case 'radio':
					return this.getInputRadio();
				case 'select':	
					return this.getSelect();
			}
			
			return false;
		}
	},
	
	setInputCheckbox : function( newValue) {		
		fields = document.getElementsByName(this.name);
		arr_value = fields.length>1?newValue.split(','):new Array(newValue);
		
		for(var i=0; i<fields.length; i++){
			var option = fields[i];
			option.checked = false;
			if(arr_value.contains(option.value)){
				option.checked = true;
			}
		}		
	},
	
	setInputRadio : function( newValue) {
		fields = document.getElementsByName(this.name);		
		
		for(var i=0; i<fields.length; i++){
			var option = fields[i];
			option.checked = false;
			if(option.value==newValue){
				option.checked = true;
			}
		}			
	},

	setSelect : function(newValue) {
		arr_value = this.multiple? newValue.split(','):new Array(newValue);
		var selected = false;
		
		for(var i=0; i<this.options.length; i++){
			var option = this.options[i];
			option.selected = false;
			if (arr_value.contains (option.value)) {
				option.selected = true;
				selected = true;
			}
		}
		
		if(!selected){
			this.options[0].selected = true;
		}
	},

	getInputCheckbox : function() {
		var values = [];
		fields = document.getElementsByName(this.name);		
		for(var i=0; i<fields.length; i++){
			var option = fields[i];
			if (option.checked) values.push($pick(option.value, option.text));
		}		
		return values;
	},
	
	getInputRadio : function( ) {
		var values = [];
		fields = document.getElementsByName(this.name);		
		$each(fields, function(option){
			if (option.checked) values.push($pick(option.value, option.text));
		});
		return values;
	},

	getSelect : function() {
		var values = [];
		for(var i=0; i<this.options.length; i++){
			var option = this.options[i];
			if (option.selected) values.push($pick(option.value, option.text));
		}				
		return (this.multiple) ? values : values[0];
	}
	
});

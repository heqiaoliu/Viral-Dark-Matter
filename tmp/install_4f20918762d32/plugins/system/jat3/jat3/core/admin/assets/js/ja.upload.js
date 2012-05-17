/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

function startUpload(template){
	if(!checkTypeFile($('install_package').value)){
		$('err_myfile').innerHTML = '<span class="err" style="color:red">Support zip type only.</span>';
		return false;
	}
	var form = document.adminForm;
	form.setAttribute( "autocomplete","off" );
	$(form).setProperty('encoding' , 'multipart/form-data');
	$(form).setProperty('enctype' , 'multipart/form-data');
	form.action = "index.php?jat3action=installTheme&jat3type=plugin&template="+template+'&id='+styleid;
	form.target = "upload_target";

	$('ja_upload_process').style.display='block';
	form.submit();
}
function stopUpload(k, theme, version, date, author, template){
	document.adminForm.target = '_self';
	$('ja_upload_process').setStyle('display', 'none');
	$('err_myfile').innerHTML = '';
	$('install_package').value = '';
    resetUploadInput();
	var length = $('ja-user-themes').rows.length;
	if(length%2==0) classname = 'row0';
	else classname = 'row1';
	var tr = new Element ('tr', {'class':classname});
	tr.injectInside($('ja-user-themes').tBodies[0]);

	var td = new Element ('td', {'width': '15'});
	td.set('text', k);
	td.injectInside(tr);

	var td = new Element ('td', {'width': '35%', 'align':'left'});
	td.set('text', theme);
	td.injectInside(tr);

	var td = new Element ('td', {'width': '15%'});
	td.set('text', version);
	td.injectInside(tr);

	var td = new Element ('td', {'width': '15%'});
	td.set('text', date);
	td.injectInside(tr);

	var td = new Element ('td', {'width': '15%'});
	td.set('text', author);
	td.injectInside(tr);

	var td = new Element ('td', {'width': '15%'});
	td.injectInside(tr);
	var span = new Element('span', {'class': 'ja_close', 'events': {'click': function(){
		jat3admin.removeTheme(this, theme, template);
	}}});
	span.innerHTML = '<img border="0" alt="Remove" src="../plugins/system/jat3/jat3/core/admin/assets/images/icon-16-deny.png"/>';
	span.injectInside(td);

	/* add theme */
	var els_themepopup = $$('ul.ja-popup-themes');
	els_themepopup.each(function (el){
		divid = el.getParent().id
		var objclass = divid.substr(0, divid.length-16)

		var li = new Element('li');
		li.innerHTML = '<span class="theme core">'+theme+'</span><span class="cb-span"></span>';
		li.injectInside(el);
		li.getElement('.cb-span').addEvent ('click', function(e) {
			new Event(e).stop();
			if (this.getParent().hasClass ('default')) return;
			if (!this.checked) {
				this.checked = true;
				this.addClass ('cb-span-checked');
				this.getParent().addClass ('selected');
			} else {
				this.checked = false;
				this.removeClass ('cb-span-checked');
				this.getParent().removeClass ('selected');
			}
		});
	});
	all_themes[all_themes.length] = 'core.' + theme;
	document.adminForm.action = "index.php?option=com_templates&view=styles";
	$('err_myfile').innerHTML = '<span style="color:blue">Upload successfully.</span>';

	if($type(jatabs)){
		jatabs.resize();
	}
}
function errorUpload(text){
	$('err_myfile').innerHTML = text;
	$('ja_upload_process').setStyle('display', 'none');
	$('install_package').value = '';
	if($type(jatabs)){
		jatabs.resize();
	}
}

function checkTypeFile(value){
	var pos = value.lastIndexOf('.');
	var type = value.substr(pos+1, value.length).toLowerCase();
	if(type!='zip'){
		return false;
	}
	return true;
}

function resetUploadInput()
{
    var tmp = document.createElement('input');
    tmp.setAttribute('type', 'file');
    tmp.setAttribute('name', 'install_package');
    tmp.setAttribute('class', 'input_box');
    var uploadinput = document.getElementById('install_package');
    uploadinput.parentNode.replaceChild(tmp, uploadinput);
    tmp.setAttribute('id', 'install_package');
}
function startUpload(template){				
	if(!checkTypeFile($('install_package').value)){
		$('err_myfile').innerHTML = '<span class="err" style="color:red">Support zip type only.</span>';
		return false;
	}	
	var form = document.adminForm;
	form.setAttribute( "autocomplete","off" );
	$(form).setProperty('encoding' , 'multipart/form-data');
	$(form).setProperty('enctype' , 'multipart/form-data');
	form.action = "index.php?jat3action=installTheme&jat3type=plugin&template="+template;		
	form.target = "upload_target";
	
	$('ja_upload_process').style.display='block';
	form.submit();
}
function stopUpload(k, theme, version, date, author, template){
	document.adminForm.target = '_self';
	$('ja_upload_process').setStyle('display', 'none');
	$('err_myfile').innerHTML = '';
	$('install_package').value = '';
	
	var length = $('ja-user-themes').rows.length;
	if(length%2==0) classname = 'row0';
	else classname = 'row1';
	var tr = new Element ('tr', {'class':classname});
	tr.injectInside($('ja-user-themes').tBodies[0]);
	
	var td = new Element ('td', {'width': '15'});
	td.setText(k);
	td.injectInside(tr);
	
	var td = new Element ('td', {'width': '35%'});
	td.setText(theme);
	td.injectInside(tr);
	
	var td = new Element ('td', {'width': '15%'});
	td.setText(version);
	td.injectInside(tr);
	
	var td = new Element ('td', {'width': '15%'});
	td.setText(date);
	td.injectInside(tr);
	
	var td = new Element ('td', {'width': '15%'});
	td.setText(author);
	td.injectInside(tr);
	
	var td = new Element ('td', {'width': '15'});
	td.injectInside(tr);
	var span = new Element('span', {'class': 'ja_close', 'events': {'click': function(){
		jat3admin.removeTheme(this, theme, template);
	}}});
	span.innerHTML = '<img border="0" alt="Remove" src="images/publish_x.png"/>';
	span.injectInside(td);
	
	/* add theme */
	
	
	var els_themepopup = $$('ul.ja-popup-themes');
	els_themepopup.each(function (el){
		divid = el.getParent().id
		var objclass = divid.substr(0, divid.length-16)		
		
		var li = new Element('li');
		li.innerHTML = '<span class="theme local">'+theme+'</span><span class="cb-span"></span>';
		li.injectInside(el);
		$E('.cb-span', li).addEvent ('click', function(e) {
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
	all_themes[all_themes.length] = 'local.' + theme;
	document.adminForm.action = "index.php?option=com_templates&client=0";
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
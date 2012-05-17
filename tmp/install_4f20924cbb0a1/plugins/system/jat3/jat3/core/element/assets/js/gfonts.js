/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 JoomlArt.com. All Rights Reserved.
 * @license GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 * Author: JoomlArt.com
 * Websites: http://www.joomlart.com - http://www.joomlancers.com.
 * ------------------------------------------------------------------------
 */

function gfonts_disable(name){
	$(name+'.font').disabled = 'disabled';
	$(name+'.extra').disabled = 'disabled';
	$(name+'.style').disabled = 'disabled';
}

function gfonts_enable(name){
	$(name+'.font').disabled = '';
	$(name+'.extra').disabled = '';
	$(name+'.style').disabled = '';
}

function gfonts_getValue(name){
	var value=$(name+'.font').getValue() + '|' + ($(name+'.extra').checked?'1':'') + '|' + $(name+'.style').value;
	$(name).value = value;
	return value;
}

function gfonts_setValue(name, data){
	var values = data.split ('|');
	if (values.length) $(name+'.font').setValue(values[0]);
	if (values.length>1 && values[1]) $(name+'.extra').checked = 'checked';
	else $(name+'.extra').checked = '';
	if (values.length>2) $(name+'.style').setValue (values[2]);
	
	gfonts_showhideextra (name) ;
}

function gfonts_showhideextra (name) {
	if ($(name+'.extra') && $(name+'.extra').checked) {
		if ($(name+'.style')) $(name+'.style').setStyle ('display', 'inline');
	} else {
		if ($(name+'.style')) $(name+'.style').setStyle ('display', 'none');
	}
	
	$$('.jpane-slider').each(function(el){
		if(el.offsetHeight>0){
			el.setStyle('height', el.getElement('fieldset.panelform').offsetHeight);
		}
	});
	window.fireEvent ('resize');
}
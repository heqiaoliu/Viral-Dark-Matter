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

/**
 * Show google font popup
 *
 * @param name  Google font element name
 *
 * @return void
 */
function gfonts_popup(name) {
    var edit = $(name+'-edit');
    var info = $(name+'-info');
    var popup = $('ja-popup-gfont');
    var position = edit.getPosition();
    var height   = edit.offsetHeight;
    var variant  = '';
    var subset   = '';
    // Set info for popup
    var font = $(name).value; //info.get('text');
    font = font.split('|');
    $('gfont-family').value = font[0];
    // Set font variant
    if (font.length > 3) variant = font[3];
    // Set font subset
    if (font.length > 4) subset  = font[4];
    // Set custom style
    if (font.length > 1 && font[1]) {
        $('gfont-custom').checked = true;
        $('gfont-style').setStyle('display', 'block');
    } else {
        $('gfont-custom').checked = false;
        $('gfont-style').setStyle('display', 'none');
    }
    if (font.length > 2) {
        $('gfont-style').value = font[2];
    }
    // Fetch variants and subsets of font family
    gfonts_get_properties(variant, subset);
    // Show popup
    popup.setStyles({
        top: position.y + height,
        left: position.x,
        display: 'block'
    });
    // Defined set gfont function
    popup.setGFont = function(family, variant, subset, custom, style) {
        var data = family + '|' + (custom?'1':'') + '|' + style + '|' + variant + '|' + subset;
        gfonts_setValue(name, data);
        gfonts_replace_link();
    };
}

/**
 * Split variant data to array
 *
 * @param variant  Variant string of webfont
 *
 * @return array
 */
function gfonts_split_variant(variant) {
    var fontweight = ['normal' , 'bold' , 'bolder' , 'lighter' , '100' , '200' , '300' , '400' , '500' , '600' , '700' , '800' , '900'];
    var fw = '400', fs = '';
    for (var j = 0, m = fontweight.length; j < m; j++) {
        if (variant.indexOf(fontweight[j]) != -1) {
            fs = variant.replace(fontweight[j], '');
            fw = fontweight[j];
            break;
        }
    }
    return [fw, fs];
}

/**
 * Close google font popup
 *
 * @return void
 */
function gfont_close_popup() {
    var popup = $('ja-popup-gfont');
    var display = popup.getStyle('display');
    if (display == 'block') {
        popup.setStyle('display', 'none');
    }
}

/**
 * Initialize google font popup
 *
 * @param family_obj     Family element
 * @param variant_obj    Variant element
 * @param subset_obj     Subset element
 * @param custom_obj     Custom element
 * @param style_obj      Custom style element
 * @param apply_button   Apply button element
 * @param cancel_button  Cancel button elemtn
 *
 * @return void
 */
function gfonts_init(family_obj, variant_obj, subset_obj, custom_obj, style_obj, apply_button, cancel_button) {
    // Setup blur event when leave family input
    family_obj.addEvent('blur', function(e) {
        gfonts_get_properties(null, null);
    });

    // Setup click event for checkbox custom
    custom_obj.addEvent('click', function(e) {
        var display = style_obj.getStyle('display');
        if (display == 'none') {
            style_obj.setStyle('display', 'block');
        } else {
            style_obj.setStyle('display', 'none');
        }
    });

    // Setup click event for apply button
    apply_button.addEvent('click', function(e) {
        var popup = $('ja-popup-gfont');
        var family  = family_obj.value;
        var variant = variant_obj.value;
        var subset  = subset_obj.value;
        var custom  = custom_obj.checked;
        var style   = style_obj.value;
        popup.setGFont(family, variant, subset, custom, style);
        popup.setStyle('display', 'none');
    });

    // Setup click event for cancel button
    cancel_button.addEvent('click', function(e) {
        var popup = $('ja-popup-gfont');
        popup.setStyle('display', 'none');
    });

    // Setup autocompleter
    gfonts_setup_autocomplete(family_obj);

    // Prevent fire body click event when click autocompleter
    $$('ul.autocompleter-choices')[0].addEvent('click', function(e) {
        new Event(e).stopPropagation();
    });
}
/**
 * Disable google field
 *
 * @param name  Google font element name
 *
 * @return void
 */
function gfonts_disable(name) {
	$(name+'-edit').onclick = null;
}

/**
 * Enable google font field
 *
 * @param name  Google font element name
 *
 * @return void
 */
function gfonts_enable(name) {
	$(name+'-edit').onclick = function(e) {
	    gfonts_popup(name);
	    new Event(e).stopPropagation();
	};
	$('ja-popup-gfont').onclick = function(e) {
	    new Event(e).stopPropagation();
	};
}

/**
 * Get value of google font field
 *
 * @param name  Google font element name
 *
 * @return value
 */
function gfonts_getValue(name) {
	var value = $(name).value;

	return value;
}
/**
 * Set value of google font field
 *
 * @param name  Google font element name
 * @param data  Google font data element, each element separate by '|' mark.
 *
 * @return void
 */
function gfonts_setValue(name, data) {
	var values = data.split('|');
	// Set font family
	if (values.length > 0) {
	    if (values[0].length > 0) {
	        $(name+'-family').set('text', values[0]);
	    } else {
	        $(name+'-family').set('text', '-- Not applied --');
	    }
	}
	// Set font info
	if (values.length > 3) {
	    var font_info = [];
	    if (values[4].length > 0) {
	        font_info.push('<strong>Variant:</strong> ' + values[3]);
	        // Set style
	        var variant = gfonts_split_variant(values[3]);
	        $(name+'-family').setStyle('font-family', values[0]);
	        $(name+'-family').setStyle('font-weight', variant[0]);
	        if (variant[1] != '') {
	            $(name+'-family').setStyle('font-style', variant[1]);
	        }

	    }
	    if (values.length > 4 && values[4].length > 0) {
	        font_info.push('<strong>Subset:</strong> ' + values[4]);
	    }
	    font_info = font_info.join(', ');
        if (font_info.length > 0) {
            $(name+'-info').innerHTML = font_info;
            $(name+'-info').setStyle('display', 'block');
        } else {
            $(name+'-info').setStyle('display', 'none');
        }
	} else {
	    $(name+'-info').setStyle('display', 'none');
	}
	// Set font custom
	if (values.length > 2 && values[1] && values[2].length > 0) {
	    var custom = '<strong>Custom:</strong> <br />' + values[2].replace(/\n/g, '<br />');
	    $(name+'-custom').innerHTML = custom;
	    $(name+'-custom').setStyle('display', 'block');
	} else {
	    $(name+'-custom').innerHTML = '';
	    $(name+'-custom').setStyle('display', 'none');
	}
	// Store data
	$(name).value = data;
	// Replace link fetch font from gogole
	if (gfonts_replace_link._run == undefined) {
	    gfonts_replace_link._run = true;
	    gfonts_replace_link.delay(1000);
	}
}
/**
 * Get font variant & font subset by webfont name.
 * After that, fetch data to selectbox of variant & subset
 *
 * @param variant  Font variant
 * @param subset   Font subset
 *
 * @return void
 */
function gfonts_get_properties(variant, subset) {
    var fontname = $('gfont-family').getValue();
    var link = 'index.php?jat3action=getFontProperties&jat3type=plugin&template='+template+'&fontname='+fontname;
    var req = new Request.JSON({
        url: link,
        onComplete: function(response) {
            if (response != undefined && response.kind == 'webfonts#webfont') {
                // Fetch variants to select box
                var option = null;
                var fv  = response.variants;
                var efv = $('gfont-variant');
                efv.innerHTML = '';
                for (var i = 0, n = fv.length; i < n; i++) {
                    option = new Element('option');
                    option.value = fv[i];
                    option.set('text', fv[i]);
                    if (fv[i] == variant) {
                        option.selected = 'selected';
                    }
                    option.inject(efv);
                }
                // Fetch subset to select box
                var subsets = response.subsets;
                var esubsets = $('gfont-subset');
                esubsets.innerHTML = '';
                for (var i = 0, n = subsets.length; i < n; i++) {
                    option = new Element('option');
                    option.value = subsets[i];
                    option.set('text', subsets[i]);
                    if (subsets[i] == subset) {
                        option.selected = 'selected';
                    }
                    option.inject(esubsets);
                }
            } else {
                // Reset font-variant & font subset
                $('gfont-variant').innerHTML = '';
                $('gfont-subset').innerHTML = '';
            }
        }
    }).send();
}

/**
 * Setup auto complete for input field
 *
 * @param input  Input element
 *
 * @return void
 */
function gfonts_setup_autocomplete(input) {
    // Not process if this isn't input
    if (input == null) return;
    // Setup ajax request for input field
    var link = 'index.php?jat3action=getFontList&jat3type=plugin&template='+template;
    new Autocompleter.Request.JSON(input, link, {
        onSelection: function(e) {
            gfonts_get_properties(null, null)
        }
    });
}
/**
 * Replace link tag to load font from google web font site
 *
 * @return void
 */
function gfonts_replace_link() {
    // Get information webfonts
    var info = $$('.gfont-panel').getNext('input').getValue().clean();
    var tmp, fonts = [], subsets = [];
    // Process data to build link
    for (var i = 0, n = info.length; i < n; i++) {
        tmp = info[i].split('|');
        if (tmp.length > 3 && tmp[0].length > 0 && tmp[3].length > 0) {
            fonts.push(tmp[0] + ':' + tmp[3]);
        }
        if (tmp.length > 4 && tmp[4].length > 0) {
            subsets.push(tmp[4]);
        }
    }

    // Add/change link in head
    var wf = document.createElement('link');
    wf.href = ('https:' == document.location.protocol ? 'https' : 'http')
        + '://fonts.googleapis.com/css?family=' + fonts.join('|') + '&subset=' + subsets.join(',');
    wf.type = 'text/css';
    wf.rel = 'stylesheet';

    var s = document.getElementsByTagName('link')[0];
    if (s.href.indexOf('://fonts.googleapis.com/css?') == -1) {
        s.parentNode.insertBefore(wf, s);
    } else {
        s.parentNode.replaceChild(wf, s);
    }
}
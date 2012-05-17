/**
 * ------------------------------------------------------------------------
 * JA Extenstion Manager Component j17
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */
// JavaScript Document
// Must re-initialize window position

function jaCreatePopup(target, jaWidth, jaHeight, title, dsave, titlesave, location) {
	if (!jaWidth) jaWidth = 700;
	if (!jaHeight) jaHeight = 500;
	if (!location) location = '';
	if (!titlesave) titlesave = 'Save';

	//message holder
	if (jQuery('#system-message').size() == 0) {
		jQuery('<div>').attr({
			'id': 'system-message',
			'style': ''
		}).html(' ').appendTo('#toolbar-box');
	}
	//
	var Obj = document.getElementById('jaForm');
	if (!Obj) {
		var content = jQuery('<div>').attr({
			'id': 'ja-wrap-content'
		}).appendTo(document.body);
		var jaForm = jQuery('<div>').attr({
			'id': 'jaForm',
			'style': 'top: 0px;display:none;'
		});
		jaForm.appendTo(content);
		jQuery('<div>').attr({
			'id': 'japopup_tl'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'japopup_tm'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'japopup_tr'
		}).appendTo(jaForm);

		jQuery('<a>').attr({
			'id': 'japopup_ar',
			'style': 'top:0px',
			'href': 'javascript:void(0);'
		}).appendTo(jQuery('#japopup_tr'));
		jQuery("#japopup_ar").bind('click', jaFormHide);

		jQuery('<div>').attr({
			'style': 'clear:both'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'japopup_ml'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'jaFormContentOuter'
		}).appendTo(jaForm);

		if (title) {
			jQuery('<div>').attr({
				'id': 'jaFormContentTop',
				'style': 'font-weight: bold;font-size:10pt;'
			}).appendTo(jQuery('#jaFormContentOuter'));

			jQuery('#jaFormContentTop').html(title);
		}
		if (title) {
			jQuery('<div>').attr({
				'id': 'japopup-wait',
				'width': jaWidth
			}).appendTo(jQuery('#jaFormContentOuter'));

			jQuery('#jaFormContentTop').html(title);
		}
		jQuery('<div>').attr({
			'id': 'jaFormContent',
			'style': 'position:relative',
			'class': ''
		}).appendTo(jQuery('#jaFormContentOuter'));
		jQuery('<div>').attr({
			'id': 'japopup_mr'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'style': 'clear: both;'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'jaFormContentBottom',
			'style': 'bottom:0px;',
			'style': 'font-weight: bold;font-size:10pt;'
		}).appendTo(jQuery('#jaFormContentOuter'));
		if (!dsave) {
			jQuery('<button>').attr({
				'id': 'japopup_as',
				'style': 'width:60px;'
			}).html(titlesave).appendTo(jQuery('#jaFormContentBottom'));
			jQuery("#japopup_as").bind('click', submitbuttonAdmin);
		}
		jQuery('<button>').attr({
			'id': 'japopup_ac',
			'style': 'width:60px;'
		}).html('Cancel').appendTo(jQuery('#jaFormContentBottom'));
		jQuery("#japopup_ac").bind('click', jaFormHide);

		jQuery('<div>').attr({
			'id': 'japopup_bl'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'japopup_bm'
		}).appendTo(jaForm);
		jQuery('<div>').attr({
			'id': 'japopup_br'
		}).appendTo(jaForm);

		jQuery('<div>').attr({
			'style': 'clear: both;'
		}).appendTo(jaForm);

	}

	// Set jaFormWidth + 40
	jQuery('#jaForm').width(jaWidth);
	if (title) jQuery('#jaFormContentTop').width(jaWidth - 20);
	jQuery('#jaFormContentBottom').width(jaWidth);
	jQuery('#jaFormContentOuter').width(jaWidth);

	jQuery('#jaFormContent').width(jaWidth);
	jQuery('#japopup_bm').width(jaWidth);
	jQuery('#japopup_tm').width(jaWidth);

	var myWidth = 0,
		myHeight = 0;

	myWidth = jQuery(window).width();
	myHeight = jQuery(window).height();

	//set frame to center
	var wrapTop = Math.floor((myHeight - jaHeight) / 2);
	jQuery('#ja-wrap-content').css('top', wrapTop);
	//
	var yPos;

	if (jQuery.browser.opera && jQuery.browser.version > "9.5" && jQuery.fn.jquery <= "1.2.6") {
		yPos = document.documentElement['clientHeight'] - 20;
	} else {
		yPos = jQuery(window).height() - 20;
	}

	var leftPos = (myWidth - jaWidth) / 2;

	jQuery('#jaForm').css('zIndex', cGetZIndexMax() + 1);

/*
	 * jQuery.ajax({ url: jatask, cache: false, success: function(html){
	 * jQuery("#jaFormContent").append(html); } });
	 */
/*var aException = ['tmpl', 'option', 'view'];
	var aParams = jaGetUrlParams(target);
	var url = siteurl;
	
	jQuery.each(aParams, function(n, val) {
		if(jQuery.inArray(n, aException) == -1) {
			url = url + '&' + n + '=' + val;
		}
	});
	*/
	var url = target;

	url = url.replace(/&amp;/gi, '&');
	if (jQuery('#iContent').length > 0) {
		jQuery('#iContent').attr('src', url);
		jQuery('#jaFormContentTop').html(title);
	} else {
		jQuery('<iframe>').attr({
			'id': 'iContent',
			'src': url,
			'width': jaWidth,
			'height': jaHeight - 80
		}).appendTo(jQuery('#jaFormContent'));
		jQuery("#iContent").load(function () {
			loadIFrameComplete();
		});
	}
/*
	 * Set editor position, center it in screen regardless of the scroll
	 * position
	 */
	if (location) {
		var pos = jQuery(location).offset();
		var topPos = pos.top - 30 - jQuery(window).scrollTop();
		var height = jQuery(window).height();
		var absTop = eval(eval(height) - eval(topPos) - eval(jaHeight));
		if (absTop < 0) {
			topPos = pos.top - jaHeight - 55 - jQuery(window).scrollTop();
		}
		var leftPos = pos.left - (jaWidth / 2) + 10;
		jQuery("#jaForm").css({
			'top': topPos,
			'left': leftPos
		});

	} else {
		jQuery("#jaForm").css('marginTop', '5px');
		jQuery('#jaForm').css('left', leftPos);
	}
/*
	 * Set height and width for transparent window
	 */
	jQuery('#jaForm').css('height', jaHeight);


	jQuery('#japopup-wait').css({
		'top': jaHeight / 2 - 10,
		'left': jaWidth / 2 - 10
	})
	jQuery('#iContent').css('border', '0px');
	jQuery('#jaFormContentOuter').css('height', jaHeight - 20);
	jQuery('#jaFormContent').css('height', jaHeight - 60);
	jQuery('#japopup_ml').css('height', jaHeight);
	jQuery('#japopup_mr').css('height', jaHeight);

	jQuery('#jaForm').fadeIn();

	/**
	 * add drag handle
	 */
	jQuery('#jaForm').css('cursor', 'move');
	jQuery('#preview').css('overflow', 'hidden');
	jQuery('#ja-wrap-content').bind('drag', function (event) {
		jQuery(this).css({
			//top: event.offsetY,
			left: event.offsetX
		});
	});


}

function hiddenMessage() {
	jQuery('#system-message', window.parent.document).html('');
}

function jaGetUrlParams(url) {
	var vars = {},
		hash;
	url = url.replace(/&amp;/gi, '&');

	var parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
		vars[key] = value;
	});
	return vars;
}

function jaFormHide() {

	if (jQuery('#japopup_ar').get().length > 0) jQuery('#japopup_ar').animate({
		top: "-20px"
	}, 200, '');
	if (jQuery('#jaFormContentBottom').get().length > 0) jQuery('#jaFormContentBottom').animate({
		bottom: "0px",
		height: "0px"
	}, 200);
	jQuery('#ja-wrap-content').fadeOut('fast', function () {
		jQuery(this).remove();
	});

}

function jaFormHideIFrame() {
	var jaForm = jQuery("#ja-wrap-content", window.parent.document);
	if (jQuery('#japopup_ar').get().length > 0) jQuery('#japopup_ar').animate({
		top: "-20px"
	}, 200, '');

	jaForm.fadeOut('slow', function () {
		jaForm.remove();
	});

}

function loadIFrameComplete() {
	jQuery('#japopup-wait', window.parent.document).css('display', 'none');
	jQuery('#japopup_as', window.parent.document).css('display', 'block');
	jQuery('#japopup_ac', window.parent.document).css('display', 'block');
	jaFormActions();
}

function jaFormActions() {
	if (jQuery('#jaFormContentBottom').get().length > 0) jQuery('#jaFormContentBottom').animate({
		bottom: "0px",
		left: "0px",
		height: "30px"
	}, 200);

	jQuery('#ja-wrap-content').fadeIn('fast');
}

function jaFormResize(newheight) {
	jQuery("#jaFormContentOuter").animate({
		"left": "+=50px"
	}, "slow");

	jQuery("#jaFormContent").animate({
		"left": "+=50px"
	}, "slow");
	jQuery("#iContent").animate({
		"left": "+=50px"
	}, "slow");
/*
	 * jQuery('#iContent', window.parent.document).animate( { height:
	 * jQuery(this).height()+30 });
	 */
}

function cGetZIndexMax() {
	var allElems = document.getElementsByTagName ? document.getElementsByTagName("*") : document.all; // or test for that too
	var maxZIndex = 0;

	for (var i = 0; i < allElems.length; i++) {
		var elem = allElems[i];
		var cStyle = null;
		if (elem.currentStyle) {
			cStyle = elem.currentStyle;
		} else if (document.defaultView && document.defaultView.getComputedStyle) {
			cStyle = document.defaultView.getComputedStyle(elem, "");
		}

		var sNum;
		if (cStyle) {
			sNum = Number(cStyle.zIndex);
		} else {
			sNum = Number(elem.style.zIndex);
		}
		if (!isNaN(sNum)) {
			maxZIndex = Math.max(maxZIndex, sNum);
		}
	}
	return maxZIndex;
} /************************************************************************/

function checkError() {
	var requireds = jQuery('#iContent').contents().find('input.required');
	jQuery.each(requireds, function (i, item) {
		if (jQuery(item).attr('value') == '') {
			var li_parent = jQuery(item.parentNode.parentNode);
			li_parent.addClass('error');
		}
	});
	var errors = jQuery('#iContent').contents().find('li.error');
	return (errors.size() > 0) ? false : true;
}

function submitbuttonAdmin() {
	var flag = checkError();
	if (flag) {
		jQuery('#japopup-wait').css({
			'display': ''
		});

		var iframe = jQuery("#iContent").contents();
		if (iframe.find("#adminForm").find("#hasFileUpload").length > 0) {
			iframe.find("#adminForm").submit();
			return false;
		}

		jQuery.post("index.php", iframe.find("#adminForm").serialize(), function (res) {
			jaFormHideIFrame();
			//window.parent.document.location.reload();
			parseData_admin(res);
		}, 'json');
	} else {
		alert("Invalid data! Please insert information again!");
	}
}

function parseData_admin(response) {
	//jQuery(document, window.parent.document).ready(function(){
	var reload = 0;
	jQuery.each(response.data, function (i, item) {
		var divId = item.id;
		var type = item.type;
		var value = item.value;
		if (jQuery(divId, window.parent.document) != undefined) {
			if (type == 'html') {
				if (jQuery(divId, window.parent.document)) jQuery(divId, window.parent.document).html(value);
				else
				alert('not fount element');
			} else {
				if (type == 'reload') {
					if (value == 1) reload = 1;
				} else {
					if (type == 'val') {
						jQuery(divId, window.parent.document).val(value);
					} else {
						jQuery(divId, window.parent.document).attr(type, value);
					}
				}
			}
		}
	});
	if (reload == 1) parent.window.document.adminForm.submit();
	else
	setTimeout("hiddenMessage()", 5000);
	//});
}
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

function jaDiffEncodeEntities(value) {
	var encoded = jQuery('#diffViewSrc').text(value).html();
	return encoded;
}

function jaDiffDecodeEntities(value) {
	var decoded = jQuery('#diffViewSrc').html(value).val();
	return decoded;
}

function jaDiffGetSource(side, mode) {
	var content = '';
	var id = '#diffviewer-side-' + side;
	var newLine = (mode == 'edit') ? "\r\n" : "<br />";

	var cnt = 0;
	jQuery(id + ' pre[class!=noexists]').each(function () {
		cnt++;
		if (cnt > 1) {
			content += newLine;
		}
		content += jQuery(this).find('span.content').html();
	});
	return content;
}

function jaDiffSaveCompareContent() {
	var totalLine = jQuery('#diffviewer-side-left pre').size();
	var sameLine = jQuery('#diffviewer-side-left pre[class=nochange]').size();
	var equal = (sameLine == totalLine) ? 1 : 0;
	return equal;
}

function jaDiffSaveSource(side) {
	if (!confirm("Do you really want to save file content?\r\nPlease backup your file before you press Yes button.")) {
		return false;
	}
	jQuery('#frmDiffViewer').attr('action', 'index.php?option=com_jaextmanager&tmpl=component&view=default&task=save_file&side=' + side);
	jQuery('#sameContent').val(jaDiffSaveCompareContent());

	var content = jaDiffGetSource(side, 'edit');
	if (side == 'left') {
		jQuery('#srcLeft').html(content);
	} else {
		jQuery('#srcRight').html(content);
	}
	jQuery('#frmDiffViewer').submit();
}

function jaDiffViewSource(side, mode) {
	var content = jaDiffGetSource(side, mode);
	var title = (mode == 'edit') ? "Edit Source" : "View Source";

	jaCreatePopup('index.php?option=com_jaextmanager&tmpl=component&view=default&layout=files_source', 800, 600, title);
	jQuery("#iContent").load(function () {
		var context = jQuery('#iContent').contents();
		if (mode == 'edit') {
			jQuery('#diff-edit-mode', context).show();
			jQuery("#txtSource", context).html(content);
			//
			jQuery('#japopup_as').unbind('click');
			//save
			jQuery('#japopup_as').click(function () {
				var contentModified = jaDiffEncodeEntities(jQuery("#txtSource", context).val());
				if (side == 'left') {
					jQuery('#srcLeft').html(contentModified);
					jQuery('#srcRight').html(jaDiffGetSource('right', mode));
				} else {
					jQuery('#srcRight').html(contentModified);
					jQuery('#srcLeft').html(jaDiffGetSource('left', mode));
				}
				jaFormHide();
				jQuery('#frmDiffViewer').submit();
			});
		} else {
			jQuery('#diff-view-mode', context).show();
			jQuery('#diff-view-mode', context).find("pre").find("code").html(content);
			//
			jQuery('#japopup_as').hide();
			jQuery('#japopup_ac').html('Close');
		}
	});
}

function jaDiffActiveGroup(from, to) {
	for (var i = from; i <= to; i++) {
		var idLeft = '#line-left-' + i;
		var idRight = '#line-right-' + i;
		jQuery(idLeft).addClass('active');
		jQuery(idRight).addClass('active');
	}
}

function jaDiffInactiveGroup(from, to) {
	for (var i = from; i <= to; i++) {
		var idLeft = '#line-left-' + i;
		var idRight = '#line-right-' + i;
		jQuery(idLeft).removeClass('active');
		jQuery(idRight).removeClass('active');
	}
}

function jaDiffCopyAllToLeft() {
	var total = jQuery('#diffviewer-side-left pre').size();
	jaDiffCopyToLeft(1, total);
}

function jaDiffCopyAllToRight() {
	var total = jQuery('#diffviewer-side-right pre').size();
	jaDiffCopyToRight(1, total);
}

function jaDiffCopyToLeft(start, end) {
	for (var line = start; line <= end; line++) {
		var idLeft = jQuery('#line-left-' + line);
		var idRight = jQuery('#line-right-' + line);
		jaDiffCopyLine(idRight, idLeft);
	}
}

function jaDiffCopyToRight(start, end) {
	for (var line = start; line <= end; line++) {
		var idLeft = jQuery('#line-left-' + line);
		var idRight = jQuery('#line-right-' + line);
		jaDiffCopyLine(idLeft, idRight);
	}
}

function jaDiffCopyLine(objSrc, objDst) {
	var newClass = objSrc.hasClass('noexists') ? 'noexists' : 'nochange';
	if (newClass == 'noexists') {
		objDst.remove();
		objSrc.remove();
	} else {
		objDst.find('span.content').html(objSrc.find('span.content').html());
		objDst.removeClass().addClass(newClass);
		objSrc.removeClass().addClass(newClass);
	}
}


function jaDiffScroll() {
	jQuery('#diffviewer-side-left').scroll(function () {
		var offset = jQuery(this).scrollTop();
		jQuery('#diffviewer-side-right').scrollTop(offset);
	});
	jQuery('#diffviewer-side-right').scroll(function () {
		var offset = jQuery(this).scrollTop();
		jQuery('#diffviewer-side-left').scrollTop(offset);
	});

	jQuery('#ja-diff-viewer pre').mouseover(function () {
		var id = '#' + jQuery(this).attr('id');
		var idLeft = id.replace('right', 'left');
		var idRight = id.replace('left', 'right');
		jQuery(idLeft).addClass('active');
		jQuery(idRight).addClass('active');
	}).mouseout(function () {
		var id = '#' + jQuery(this).attr('id');
		var idLeft = id.replace('right', 'left');
		var idRight = id.replace('left', 'right');
		jQuery(idLeft).removeClass('active');
		jQuery(idRight).removeClass('active');
	});
}

function scrollEditor(e) {
	var offset = jQuery(e).scrollTop();
	offset = offset * -1;
	offset = '0 ' + offset + 'px';
	jQuery(e).css('background-position', offset);

}
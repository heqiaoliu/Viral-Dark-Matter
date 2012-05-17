/**
* Toggles the check state of a group of boxes
*
* Checkboxes must have an id attribute in the form cb0, cb1...
* @param The number of box to 'check'
* @param An alternative field name
*
*/

function checkAlle( n, formid, fldName) {
  if (!fldName) {
     fldName = 'cb';
  }
    var formname = 'down'+ formid;
    var f = document.forms[formname];
	var c = f.toggle.checked;
	var n2 = 0;
	for (i=0; i < n; i++) {
		cb = eval( 'f.' + fldName + '' + i );
		if (cb) {
			cb.checked = c;
			n2++;
		}
	}
	if (c) {
		document.forms[formname].boxchecked.value = n2;
	} else {
		document.forms[formname].boxchecked.value = 0;
	}
}

function istChecked(isitchecked,formid){
    var formname = 'down'+ formid;
    if (isitchecked == true){
		document.forms[formname].boxchecked.value++;
	}
	else {
		document.forms[formname].boxchecked.value--;
	}
}

function pruefen(formid,text){
   var formname = 'down'+ formid;
   var f = document.forms[formname];
   if (f.boxchecked.value < 1) {
      alert(text);
      return false;
   }
   return true;
}

function gocat(root_url, url){
     var id = document.getElementById("cat_list").value;
     var url_list = url.split(",");
     if (id > 0) {
        var link = url_list[id-1];
     } else {
        var link = root_url;
     }
     top.location.href=link;
} 

function CheckSearch(error_msg_to_short, error_msg_no_option){
  var search        = document.jdsearch.jdsearchtext.value;
  var searchintitle = document.jdsearch.jdsearchintitle.checked;
  var searchindesc  = document.jdsearch.jdsearchindesc.checked;  
      if (!searchintitle && !searchindesc){
          alert(error_msg_no_option);
          document.jdsearch.jdsearchintitle.focus();
          return false;
      } else if (search == '' || search.length < 3){
                 alert(error_msg_to_short);
                 document.jdsearch.jdsearchtext.focus();
                 return false;
      } else {
        return true;
      }
}

function checkUploadFieldExtern(extern_file){
    if (extern_file.value != ''){
		document.uploadForm.file_upload.value = '';
		document.uploadForm.file_upload.disabled = 'disabled';
	}
	else {
		document.uploadForm.file_upload.removeAttribute("disabled", 0);
	}
}
function checkUploadFieldFile(file_upload){
    if (file_upload.value != ''){
		document.uploadForm.extern_file.value = '';
		document.uploadForm.extern_file.disabled = 'disabled';
	}
	else {
		document.uploadForm.extern_file.removeAttribute("disabled", 0);
	}
}

function CheckForm(error_msg, allowed_file_types, error_msg_ext){
  var name = document.uploadForm.name.value;
  var mail = document.uploadForm.mail.value;
  var title = document.uploadForm.filetitle.value;
  var catlist = document.uploadForm.catlist.value;
  var allowed_types = allowed_file_types.split(",");  
  
  if (document.uploadForm.file_upload ) var file_upload = document.uploadForm.file_upload.value.toLowerCase();
  if (document.uploadForm.extern_file ) var extern_file = document.uploadForm.extern_file.value;
  if (document.uploadForm.description) var description = document.uploadForm.description.value;
  if (document.uploadForm.description) var description2 = tinyMCE.activeEditor.getContent({format : 'raw'});

  var nameRegex = /^[a-zA-Z]+(([\'\,\.\- ][a-zA-Z ])?[a-zA-Z]*)*$/;
  var emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
  var messageRegex = new RegExp(/<\/?\w+((\s+\w+(\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/?>/gim);

  if(name == "") {
    alert(error_msg);
    document.uploadForm.name.focus();
    return false;
  }
  if(!mail.match(emailRegex)){
    alert(error_msg);
    document.uploadForm.mail.focus();
    return false;
  }
  if(title == "") {
    alert(error_msg);
    document.uploadForm.filetitle.focus();
    return false;
  }
  if(catlist == "" || catlist == 0) {
    alert(error_msg);
    document.uploadForm.catlist.focus();
    return false;
  } 

  if ( typeof file_upload != "undefined"){
    if (document.uploadForm.extern_file){
        if (file_upload == '' && extern_file == ''){
            alert(error_msg);
            document.uploadForm.file_upload.focus();
            return false;
        }
    } else {
        if (file_upload == ''){
            alert(error_msg);
            document.uploadForm.file_upload.focus();
            return false;
       } 
    }
  }

  if ( typeof description != "undefined"){
    if(description == "" || description == '<p><br mce_bogus="1"></p>') {
        if (description2 == '' || description2 == '<p><br mce_bogus="1"></p>'){ 
            alert(error_msg);
            document.uploadForm.description.focus();
            return false;
        }
    }
  }    

  if ( typeof file_upload != "undefined"){
    if (file_upload != ''){
        // code to get File Extension..
        var arr1 = new Array;
        arr1 = file_upload.split("\\");
        var len = arr1.length;
        var img1 = arr1[len-1];
        var filext = img1.substring(img1.lastIndexOf(".")+1);
        if (!is_in_array(allowed_types, filext)){
            alert(error_msg_ext);
            document.uploadForm.file_upload.focus();
            return false;
        }
    }
  }
  return true;
} 

function is_in_array(arr,str) {
    for(x in arr) {if (arr[x] == str) return true;}
    return false;
}

function enableDownloadButton(elem) { 
    var obj = document.getElementById('jd_license_submit'); 
    obj.disabled = !elem.checked; 
}


function sprintf()
{
   if (!arguments || arguments.length < 1 || !RegExp)
   {
      return;
   }
   var str = arguments[0];
   var re = /([^%]*)%('.|0|\x20)?(-)?(\d+)?(\.\d+)?(%|b|c|d|u|f|o|s|x|X)(.*)/;
   var a = b = [], numSubstitutions = 0, numMatches = 0;
   while (a = re.exec(str))
   {
      var leftpart = a[1], pPad = a[2], pJustify = a[3], pMinLength = a[4];
      var pPrecision = a[5], pType = a[6], rightPart = a[7];

      numMatches++;
      if (pType == '%')
      {
         subst = '%';
      }
      else
      {
         numSubstitutions++;
         if (numSubstitutions >= arguments.length)
         {
            alert('Error! Not enough function arguments (' + (arguments.length - 1)
               + ', excluding the string)\n'
               + 'for the number of substitution parameters in string ('
               + numSubstitutions + ' so far).');
         }
         var param = arguments[numSubstitutions];
         var pad = '';
                if (pPad && pPad.substr(0,1) == "'") pad = leftpart.substr(1,1);
           else if (pPad) pad = pPad;
         var justifyRight = true;
                if (pJustify && pJustify === "-") justifyRight = false;
         var minLength = -1;
                if (pMinLength) minLength = parseInt(pMinLength);
         var precision = -1;
                if (pPrecision && pType == 'f')
                   precision = parseInt(pPrecision.substring(1));
         var subst = param;
         switch (pType)
         {
         case 'b':
            subst = parseInt(param).toString(2);
            break;
         case 'c':
            subst = String.fromCharCode(parseInt(param));
            break;
         case 'd':
            subst = parseInt(param) ? parseInt(param) : 0;
            break;
         case 'u':
            subst = Math.abs(param);
            break;
         case 'f':
            subst = (precision > -1)
             ? Math.round(parseFloat(param) * Math.pow(10, precision))
              / Math.pow(10, precision)
             : parseFloat(param);
            break;
         case 'o':
            subst = parseInt(param).toString(8);
            break;
         case 's':
            subst = param;
            break;
         case 'x':
            subst = ('' + parseInt(param).toString(16)).toLowerCase();
            break;
         case 'X':
            subst = ('' + parseInt(param).toString(16)).toUpperCase();
            break;
         }
         var padLeft = minLength - subst.toString().length;
         if (padLeft > 0)
         {
            var arrTmp = new Array(padLeft+1);
            var padding = arrTmp.join(pad?pad:" ");
         }
         else
         {
            var padding = "";
         }
      }
      str = leftpart + padding + subst + rightPart;
   }
   return str;
}

// JS Calendar
var calendar = null; // remember the calendar object so that we reuse
// it and avoid creating another

// This function gets called when an end-user clicks on some date
function selected(cal, date) {
	cal.sel.value = date; // just update the value of the input field
}

// And this gets called when the end-user clicks on the _selected_ date,
// or clicks the "Close" (X) button.  It just hides the calendar without
// destroying it.
function closeHandler(cal) {
	cal.hide();			// hide the calendar

	// don't check mousedown on document anymore (used to be able to hide the
	// calendar when someone clicks outside it, see the showCalendar function).
	Calendar.removeEvent(document, "mousedown", checkCalendar);
}

// This gets called when the user presses a mouse button anywhere in the
// document, if the calendar is shown.  If the click was outside the open
// calendar this function closes it.
function checkCalendar(ev) {
	var el = Calendar.is_ie ? Calendar.getElement(ev) : Calendar.getTargetElement(ev);
	for (; el != null; el = el.parentNode)
	// FIXME: allow end-user to click some link without closing the
	// calendar.  Good to see real-time stylesheet change :)
	if (el == calendar.element || el.tagName == "A") break;
	if (el == null) {
		// calls closeHandler which should hide the calendar.
		calendar.callCloseHandler(); Calendar.stopEvent(ev);
	}
}

// This function shows the calendar under the element having the given id.
// It takes care of catching "mousedown" signals on document and hiding the
// calendar if the click was outside.
function showCalendar(id, dateFormat) {
	var el = document.getElementById(id);
	if (calendar != null) {
		// we already have one created, so just update it.
		calendar.hide();		// hide the existing calendar
		calendar.parseDate(el.value); // set it to a new date
	} else {
		// first-time call, create the calendar
		var cal = new Calendar(true, null, selected, closeHandler);
		calendar = cal;		// remember the calendar in the global
		cal.setRange(1900, 2070);	// min/max year allowed

		if ( dateFormat )	// optional date format
		{
			cal.setDateFormat(dateFormat);
		}

		calendar.create();		// create a popup calendar
		calendar.parseDate(el.value); // set it to a new date
	}
	calendar.sel = el;		// inform it about the input field in use
	calendar.showAtElement(el);	// show the calendar next to the input field

	// catch mousedown on the document
	Calendar.addEvent(document, "mousedown", checkCalendar);
	return false;
}
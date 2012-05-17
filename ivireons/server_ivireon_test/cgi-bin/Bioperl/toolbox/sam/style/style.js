/// Utility javascript for rendering HTML documents for sam
/// Copyright 2008-2010 The MathWorks, Inc.

///////////////////////////////////////////////////////////////////////////////
/// LOAD/UNLOAD PAGE

window.onunload = function () {
	// execute unload routine of page, if present
	if (self.exit)
		exit();
}

window.onload = function () {
	// write last modified info in appropriate element */
	// document.getElementById('var_lastModified').innerHTML = lastMod();
	// call back on scroll to set menu position */
	window.onscroll = document.documentElement.onscroll = setMenuOffset;
	// create MENU */
	var divMenu = document.getElementById('FloatingMenu');
	divMenu.appendChild( createMenu() );
}

///////////////////////////////////////////////////////////////////////////////
/// FLOATING MENU -- contains the control buttons for
/// + Table-Of-Content
/// + Search
/// + Verbosity
/// + ...
var SEARCHstate = 'none';
var TOCstate = 'none';
var MEDIAstate = 'screen';
var VERBOSITYstate = 'none';

function setMediaButton(elt) {
	state = (MEDIAstate == 'screen') ? 'printer' : 'click here for screen mode';
	elt.innerHTML = state;
	elt.className = 'floatCmd ' + MEDIAstate;
	elt.onclick = toggleMedia;
}

function setScreenButton(elt, name, state, cmd, baseclass ) 
{
	elt.innerHTML = name;
	if (MEDIAstate == 'screen') {
		elt.className = baseclass  + ' ' + state;
 		elt.onclick = cmd;
	}
	else {
		elt.className = baseclass  + ' ' + MEDIAstate;
		elt.onclick = '';
	}
}

function setSearchButton( elt )
{
    setScreenButton( elt, 'search', SEARCHstate, showhideSEARCH, 'floatCmd' );
}

function setVerbosityButton( elt )
{
    setScreenButton( elt, 'verbose', VERBOSITYstate, showhideVERBOSITY, 'floatCmd' );
}

function setContentButton( elt )
{
    setScreenButton( elt, 'content', TOCstate, showhideTOC, 'floatCmd' );
}

function setBaseButton( elt, name, cmd ) 
{
	elt.innerHTML = name;
    elt.className = 'button';
    elt.onclick = cmd;
}

// http://www.quirksmode.org/dom/toc.html
function createMenu() {
	var y = document.createElement('div');
	y.id = 'FloatingMenuContent';

    // table of content
	var a = y.appendChild(document.createElement('span'));
	a.id = 'contentheader';
	setContentButton(a);
    y.appendChild( createContentPage() );

    // verbosity
	var a = y.appendChild(document.createElement('span'));
	a.id = 'verbosityButton';
	setVerbosityButton(a);
    y.appendChild( createVerbosityPage() );

    // menu search	
	var a = y.appendChild(document.createElement('span'));
	a.id = 'searchButton';
    setSearchButton( a );
	y.appendChild( createSearchPage() );

    // menu print
    /*	disabled
	var a = y.appendChild(document.createElement('span'));
	a.id = 'printButton';
	setMediaButton(a);
	*/
    
    // finished
	return y;
}

/// call-back on change media screen/printer
function toggleMedia() 
{
	var header = document.getElementById('FloatingMenu');
	if (!header) return;
	
	MEDIAstate = (MEDIAstate == 'screen') ? 'printer' : 'screen';
	elt = document.getElementById('printButton');
	setMediaButton(elt);
	elt = document.getElementById('contentheader');
	setContentButton(elt);
	
	if (MEDIAstate == 'printer') {
		if (TOCstate == 'none')
			showhideTOC();
		header.style.position = 'relative';
	}
	else {
		showhideTOC();
		header.style.position = 'absolute';
	}
}

/// call-back on scroll to set menu position
function setMenuOffset() 
{ 
	var header = document.getElementById('FloatingMenu');
	if (!header) return;
	if (MEDIAstate == 'screen') {
		var currentOffset = document.documentElement.scrollTop 
		header.style.top = currentOffset + 'px';
	}
}

///////////////////////////////////////////////////////////////////////////////
/// CONTROL TABLE-OF-CONTENT

/// Creates the floating page for displaying the table-of-content
function createContentPage()
{
	var z = document.createElement('div');
    z.id = 'innertocContent';
	z.style.display = TOCstate;
	
	var toBeTOCced = getElementsByTagNames('h1,h2,h3,h4,h5');
	if (toBeTOCced.length < 2) return false;

	for (var i=0;i<toBeTOCced.length;i++) {
        addHyperlink( z, toBeTOCced[i], i );
	}
    return z;
}

function addHyperlink( container, element, idx ) 
{
		var tmp = document.createElement('a');
		tmp.innerHTML = element.innerHTML;
		tmp.className = 'page';
		container.appendChild(tmp);
		tmp.className += ' ' + element.nodeName;
		var headerId = element.id || 'link' + idx;
		tmp.href = '#' + headerId;
		element.id = headerId;
}

function addMessage( container, aMessageText ) 
{
		var tmp = document.createElement('span');
		tmp.innerHTML = aMessageText;
		container.appendChild(tmp);
}

function showhideTOC() 
{
	TOCstate = (TOCstate == 'none') ? 'block' : 'none';
	elt = document.getElementById('contentheader');
	setContentButton(elt);
	document.getElementById('innertocContent').style.display = TOCstate;
}

///////////////////////////////////////////////////////////////////////////////
/// CONTROL SEARCH (GREP like)
/// Adds search facilities in the current HTML page, based on regular-expression

/// Creates the floating page for searching inputs  via grep
/// <input id="grepRegexArea" type="text"></input>
/// <input type="button" name="button1" value="Search" onClick="javascript:grep()" />
/// <div id = "grepResultArea">
function createSearchPage()
{
	var z = document.createElement('div');
    z.id = 'innersearch';
	z.style.display = SEARCHstate;

    var txt = z.appendChild(document.createElement('span'));
    txt.innerHTML = 'Regexp:';
    
    var grepRegexArea = z.appendChild(document.createElement('input'));
    grepRegexArea.id="grepRegexArea";
    grepRegexArea.type="text";

    var grepBtn = z.appendChild( document.createElement('span') );
    grepBtn.id="grepBtn";
    setBaseButton( grepBtn, 'search', grep );

    var grepBtnCase = z.appendChild( document.createElement('span') );
    grepBtnCase.id="grepBtnCase";
    setBaseButton( grepBtnCase, 'case', grepToggleCase );
    
    var grepClearBtn = z.appendChild( document.createElement('span') );
    grepClearBtn.id="grepClearBtn";
    setBaseButton( grepClearBtn, 'clear', grepClear  );

    var grepResultArea = z.appendChild(document.createElement('div'));
    grepResultArea.id="grepResultArea";
    return z;
}

// searches
function grep()
{
	var lines = getElementsByTagNames('h1');
    var grepResult = document.getElementById("grepResultArea");
    var regexText = document.getElementById("grepRegexArea").value;
    var regex;
    var ignorecase = grepIsIgnoreCase();
    if ( ignorecase ) {
        regex = new RegExp( regexText, "i" );
    }
    else {
        regex = new RegExp( regexText );
    }
    // clears up
    grepClear();
    // display result
    var nbMatches = 0;
    for (var i = 0; i < lines.length; i++) {
        var text = lines[i].innerHTML;
        matches = regex.exec(text);
        if (matches != null) {
            addHyperlink( grepResult, lines[i], i );
            nbMatches += 1;
        }
    }
    if ( nbMatches == 0 ) {
        addMessage( grepResult, 'No match.' ); 
    }
}

// clears up
function grepClear()
{
    var grepResult = document.getElementById("grepResultArea");
    if ( grepResult.hasChildNodes() ) {
        while ( grepResult.childNodes.length >= 1 ) {
            grepResult.removeChild( grepResult.firstChild );       
        } 
    }
}

// toggle ignore-case on/off
function grepToggleCase() 
{
    var grepCase = document.getElementById("grepBtnCase");
    var val = grepCase.innerHTML;
    grepCase.innerHTML =  ( val == 'case' ) ? 'ignore&nbsp;case' : 'case';
}

// toggle ignore-case on/off
function grepIsIgnoreCase() 
{
    var grepCase = document.getElementById("grepBtnCase");
    if ( grepCase.innerHTML == 'case' ) {
        return false;
    }
    else {
        return true;
    }
}

function showhideSEARCH() {
	SEARCHstate = (SEARCHstate == 'none') ? 'block' : 'none';
	elt = document.getElementById('searchButton');
	setSearchButton(elt);
	x = document.getElementById('innersearch');
    x.style.display = SEARCHstate;
}

///////////////////////////////////////////////////////////////////////////////
/// CONTROL VERBOSITY

/// Creates verbosity page
function createVerbosityPage()
{
	var z = document.createElement('div');
    z.id = 'innerverbosity';
	z.style.display = VERBOSITYstate;
	
    var txt = z.appendChild( document.createElement('span') );
    txt.innerHTML = 'Show or hide:';
        
    var showVerboseBtn1 = z.appendChild( document.createElement('span') );
    showVerboseBtn1.id='showVerboseBtn'+'derived';
    setBaseButton( showVerboseBtn1, 'derived', verbosityToggleDerived  );
    DisplayFilter.display( 'derived', false );
    
    var showVerboseBtn2 = z.appendChild( document.createElement('span') );
    showVerboseBtn2.id='showVerboseBtn'+'empty';
    setBaseButton( showVerboseBtn2, 'empty', verbosityToggleEmpty  );
    DisplayFilter.display( 'empty', false );

    var showVerboseBtn3 = z.appendChild( document.createElement('span') );
    showVerboseBtn3.id='showVerboseBtn'+'error';
    setBaseButton( showVerboseBtn3, 'error', verbosityToggleError  );
    DisplayFilter.display( 'error', false );

    return z;
}

/// vebosity toggle logic
function verbosityToggleDerived()
{
    verbosityToggle('derived');
}
function verbosityToggleEmpty()
{
    verbosityToggle('empty');
}
function verbosityToggleError()
{
    verbosityToggle('error');
}
function verbosityToggle( filterName )
{
    var btn = document.getElementById("showVerboseBtn" + filterName);
    var val = btn.innerHTML;
    var show = !( val == filterName ); // current
    show = !show; // reverse
    DisplayFilter.display( filterName, show );
    btn.innerHTML =  ( show ) ? 'hide&nbsp;'+filterName : filterName;
}
function showhideVERBOSITY() {
	VERBOSITYstate = (VERBOSITYstate == 'none') ? 'block' : 'none';
	elt = document.getElementById('verbosityButton');
	setVerbosityButton(elt);
	x = document.getElementById('innerverbosity');
    x.style.display = VERBOSITYstate;
}

///////////////////////////////////////////////////////////////////////////////
/// Utilities to display dates
/// LAST MODIFIED see: http://www.quirksmode.org/quirksmode.js
function lastMod(date) {
	var x = date || new Date (document.lastModified);
	Modif = new Date(x.toGMTString());
	Year = takeYear(Modif);
	Month = Modif.getMonth();
	Day = Modif.getDate();
	Mod = (Date.UTC(Year,Month,Day,0,0,0))/86400000;
	x = new Date();
	today = new Date(x.toGMTString());
	Year2 = takeYear(today);
	Month2 = today.getMonth();
	Day2 = today.getDate();
	now = (Date.UTC(Year2,Month2,Day2,0,0,0))/86400000;
	daysago = now - Mod;
	if (daysago < 0) return '';
	unit = 'days';
	if (daysago > 730) {
		daysago = Math.floor(daysago/365);
		unit = 'years';
	}
	else if (daysago > 60) {
		daysago = Math.floor(daysago/30);
		unit = 'months';
	}
	else if (daysago > 14) {
		daysago = Math.floor(daysago/7);
		unit = 'weeks'
	}
	var towrite = '';
	if (daysago == 0) towrite += 'today';
	else if (daysago == 1) towrite += 'yesterday';
	else towrite += daysago + ' ' + unit + ' ago';
	return towrite;
}

function takeYear(theDate) {
	var x = theDate.getYear();
	var y = x % 100;
	y += (y < 38) ? 2000 : 1900;
	return y;
}

///////////////////////////////////////////////////////////////////////////////
/// Utilities to hide or show elements controlled by checkboxes users

Event = {
    observe: function(element, eventName, handler) {
        if (element.addEventListener) {
            element.addEventListener(eventName, handler, false);
        } else {
            element.attachEvent("on" + eventName, handler);
        }
        return element;
    }
};

Event.observe( window, 'load', function(loadEvent) 
    {
        DisplayFilter.initialize();
    } 
);

function setDisplay( checkbox ) {
    DisplayFilter.display( checkbox.name, checkbox.checked );
}

DisplayFilter = {
    initialize: function() {
        /* deprecated
        var filters = $('DisplayFilterCheckboxes').getElementsByTagName('input');
        for (var i=0; i<filters.length; i++) {
            setDisplay( filters[i] );
        }
        */
    },
    display: function(className, doDisplay) {
        var allElements = getElementsByClassName( className );
        for (var i = 0; i < allElements.length; i++) {
            allElements[i].style.display = doDisplay ? '' : 'none';
        }
    }
};

///////////////////////////////////////////////////////////////////////////////
/// BASIC UTILITIES

// ----------------------------------------------------------------------------
// A critical utility function for retrieving elements
function $(element) {
    if (typeof element == "string") element = document.getElementById(element);
    return element;
}

// ----------------------------------------------------------------------------
// Unfortunately getElementsByClassName is not implemented in all browser
// Works well with FF but does not work awith IE7.
// I am using here a script that is:
// Developed by Robert Nyman, http://www.robertnyman.com
// Code/licensing: http://code.google.com/p/getelementsbyclassname/
// The script should support basically any web browser being used today, 
// and also has support back till IE 5.5. 
var getElementsByClassName = function (className, tag, elm){
	if (document.getElementsByClassName) {
		getElementsByClassName = function (className, tag, elm) {
			elm = elm || document;
			var elements = elm.getElementsByClassName(className),
				nodeName = (tag)? new RegExp("\\b" + tag + "\\b", "i") : null,
				returnElements = [],
				current;
			for(var i=0, il=elements.length; i<il; i+=1){
				current = elements[i];
				if(!nodeName || nodeName.test(current.nodeName)) {
					returnElements.push(current);
				}
			}
			return returnElements;
		};
	}
	else if (document.evaluate) {
		getElementsByClassName = function (className, tag, elm) {
			tag = tag || "*";
			elm = elm || document;
			var classes = className.split(" "),
				classesToCheck = "",
				xhtmlNamespace = "http://www.w3.org/1999/xhtml",
				namespaceResolver = (document.documentElement.namespaceURI === xhtmlNamespace)? xhtmlNamespace : null,
				returnElements = [],
				elements,
				node;
			for(var j=0, jl=classes.length; j<jl; j+=1){
				classesToCheck += "[contains(concat(' ', @class, ' '), ' " + classes[j] + " ')]";
			}
			try	{
				elements = document.evaluate(".//" + tag + classesToCheck, elm, namespaceResolver, 0, null);
			}
			catch (e) {
				elements = document.evaluate(".//" + tag + classesToCheck, elm, null, 0, null);
			}
			while ((node = elements.iterateNext())) {
				returnElements.push(node);
			}
			return returnElements;
		};
	}
	else {
		getElementsByClassName = function (className, tag, elm) {
			tag = tag || "*";
			elm = elm || document;
			var classes = className.split(" "),
				classesToCheck = [],
				elements = (tag === "*" && elm.all)? elm.all : elm.getElementsByTagName(tag),
				current,
				returnElements = [],
				match;
			for(var k=0, kl=classes.length; k<kl; k+=1){
				classesToCheck.push(new RegExp("(^|\\s)" + classes[k] + "(\\s|$)"));
			}
			for(var l=0, ll=elements.length; l<ll; l+=1){
				current = elements[l];
				match = false;
				for(var m=0, ml=classesToCheck.length; m<ml; m+=1){
					match = classesToCheck[m].test(current.className);
					if (!match) {
						break;
					}
				}
				if (match) {
					returnElements.push(current);
				}
			}
			return returnElements;
		};
	}
	return getElementsByClassName(className, tag, elm);
};

// ----------------------------------------------------------------------------
// http://www.quirksmode.org/dom/getElementsByTagNames.html
// see also: http://fr.selfhtml.org/javascript/objets/index.htm
function getElementsByTagNames(list,obj) {
	if (!obj) var obj = document;
	var tagNames = list.split(',');
	var resultArray = new Array();
	for (var i=0;i<tagNames.length;i++) {
		var tags = obj.getElementsByTagName(tagNames[i]);
		for (var j=0;j<tags.length;j++) {
			resultArray.push(tags[j]);
		}
	}
	var testNode = resultArray[0];
	if (!testNode) return [];
	if (testNode.sourceIndex) {
		resultArray.sort(function (a,b) {
				return a.sourceIndex - b.sourceIndex;
		});
	}
	else if (testNode.compareDocumentPosition) {
		resultArray.sort(function (a,b) {
				return 3 - (a.compareDocumentPosition(b) & 6);
		});
	}
	return resultArray;
}

<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nl "&#10;">
  <!ENTITY nbsp "&#160;">
  ]>

<!-- 
   Copyright 2006-2010 The MathWorks, Inc.
   $Revision: 1.1.6.23 $
-->

<!-- Use this stylesheet when there are multiple MDLDepSet instances.
     The "root" model is assumed to be the first in the array. -->

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dependencies="http://www.mathworks.com/manifest">
    <xsl:output method="html" encoding="utf-8"
        media-type="text/html" indent="yes" />

    <xsl:key name="distinct-toolboxname" match="Toolboxes/ToolboxDetails" use="."/>

    <xsl:param name="language">en</xsl:param>
    <xsl:param name="strings"
        select="document(concat($language,'/','strings.xml'))/strings"/>

    <!--xsl:strip-space elements="*"/-->

    <!-- Function which determines whether the specified file name is of a type
         which MATLAB might be able to open. -->
    <xsl:function name="dependencies:canopenfile">
        <xsl:param name="filename"/>
        <xsl:value-of select="
            not(ends-with($filename,'.p'))
            and not(ends-with($filename,'.mat'))
            and not(ends-with($filename,'.fig'))
            and not(ends-with($filename,'.dll'))
            and not(ends-with($filename,'.mexw32'))
            and not(ends-with($filename,'.mexw64'))
            and not(ends-with($filename,'.mexa64'))
            and not(ends-with($filename,'.mexmaci'))
            and not(ends-with($filename,'.mexmaci64'))
            and not(ends-with($filename,'.mexglx'))
            and not(ends-with($filename,'.mexs64'))
            and not(ends-with($filename,'.mdlp'))
            "/>
    </xsl:function> 

    <xsl:function name="dependencies:analysis_option_value">
        <xsl:param name="option_name"/>
        <xsl:choose>
            <xsl:when test="$option_name='true'">
                &nbsp;<b><xsl:value-of select="$strings/true"/></b>
            </xsl:when>
            <xsl:when test="$option_name='false'">
                &nbsp;<b><xsl:value-of select="$strings/false"/></b>
            </xsl:when>
            <xsl:otherwise>
                <!-- empty, since the only allowed values are true and false -->
                &nbsp;<i><xsl:value-of select="$strings/not_specified"/></i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="dependencies:exportable_value">
        <xsl:param name="option_name"/>
        <xsl:choose>
            <xsl:when test="$option_name='true'">
                <xsl:value-of select="$strings/true"/>
            </xsl:when>
            <xsl:when test="$option_name='false'">
                <xsl:value-of select="$strings/false"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- empty, since the only allowed values are true and false -->
                <i><xsl:value-of select="$strings/not_specified"/></i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:template match="DependencyReport">
        <html><head>
                <!--link rel="stylesheet" type="text/css" href="mcss.css"/-->
                <script>
<![CDATA[
                    
// The following JavaScript is a slightly modified version of "SortTable", version 2
// by Stuart Langridge, http://www.kryogenix.org/code/browser/sorttable/
// Licenced as X11: http://www.kryogenix.org/code/browser/licence.html
 
var stIsIE = /*@cc_on!@*/false;

sorttable = {
  init: function() {
    // quit if this function has already been called
    if (arguments.callee.done) return;
    // flag this function so we don't do the same thing twice
    arguments.callee.done = true;

    // The table sorting code doesn't work the version of ICEBrowser that
    // ships with 64-bit MATLAB.  Hide the text that says "Click to sort".
    if (navigator.appName=="ICEbrowser") {
        var element = document.getElementsByTagName('em');
        var index=0;
        for (index=0;index<element.length;index=index+1) {
            element.item(index).style.display='none';
        }
        return;
    }
    
    // kill the timer
    if (_timer) clearInterval(_timer);
    
    if (!document.createElement || !document.getElementsByTagName) return;
    
    sorttable.DATE_RE = /^(\d\d?)[\/\.-](\d\d?)[\/\.-]((\d\d)?\d\d)$/;
    
    forEach(document.getElementsByTagName('table'), function(table) {
      if (table.className.search(/\bsortable\b/) != -1) {
        sorttable.makeSortable(table);
      }
    });
    
  },
  
  makeSortable: function(table) {
    if (table.getElementsByTagName('thead').length == 0) {
      // table doesn't have a tHead. Since it should have, create one and
      // put the first table row in it.
      the = document.createElement('thead');
      the.appendChild(table.rows[0]);
      table.insertBefore(the,table.firstChild);
    }
    // Safari doesn't support table.tHead, sigh
    if (table.tHead == null) table.tHead = table.getElementsByTagName('thead')[0];
    
    if (table.tHead.rows.length != 1) return; // can't cope with two header rows
    
    // Sorttable v1 put rows with a class of "sortbottom" at the bottom (as
    // "total" rows, for example). This is B&R, since what you're supposed
    // to do is put them in a tfoot. So, if there are sortbottom rows,
    // for backwards compatibility, move them to tfoot (creating it if needed).
    sortbottomrows = [];
    for (var i=0; i<table.rows.length; i++) {
      if (table.rows[i].className.search(/\bsortbottom\b/) != -1) {
        sortbottomrows[sortbottomrows.length] = table.rows[i];
      }
    }
    if (sortbottomrows) {
      if (table.tFoot == null) {
        // table doesn't have a tfoot. Create one.
        tfo = document.createElement('tfoot');
        table.appendChild(tfo);
      }
      for (var i=0; i<sortbottomrows.length; i++) {
        tfo.appendChild(sortbottomrows[i]);
      }
      delete sortbottomrows;
    }
    
    // work through each column and calculate its type
    headrow = table.tHead.rows[0].cells;
    for (var i=0; i<headrow.length; i++) {
      // manually override the type with a sorttable_type attribute
      if (!headrow[i].className.match(/\bsorttable_nosort\b/)) { // skip this col
        mtch = headrow[i].className.match(/\bsorttable_([a-z0-9]+)\b/);
        if (mtch) { override = mtch[1]; }
	      if (mtch && typeof sorttable["sort_"+override] == 'function') {
	        headrow[i].sorttable_sortfunction = sorttable["sort_"+override];
	      } else {
	        headrow[i].sorttable_sortfunction = sorttable.guessType(table,i);
	      }
	      // make it clickable to sort
	      headrow[i].sorttable_columnindex = i;
	      headrow[i].sorttable_tbody = table.tBodies[0];
	      dean_addEvent(headrow[i],"click", function(e) {

          if (this.className.search(/\bsorttable_sorted\b/) != -1) {
            // if we're already sorted by this column, just 
            // reverse the table, which is quicker
            sorttable.reverse(this.sorttable_tbody);
            this.className = this.className.replace('sorttable_sorted',
                                                    'sorttable_sorted_reverse');
            this.removeChild(document.getElementById('sorttable_sortfwdind'));
            sortrevind = document.createElement('span');
            sortrevind.id = "sorttable_sortrevind";
            sortrevind.innerHTML = stIsIE ? '&nbsp<font face="webdings">5</font>' : '&nbsp;&#x25B4;';
            this.appendChild(sortrevind);
            return;
          }
          if (this.className.search(/\bsorttable_sorted_reverse\b/) != -1) {
            // if we're already sorted by this column in reverse, just 
            // re-reverse the table, which is quicker
            sorttable.reverse(this.sorttable_tbody);
            this.className = this.className.replace('sorttable_sorted_reverse',
                                                    'sorttable_sorted');
            this.removeChild(document.getElementById('sorttable_sortrevind'));
            sortfwdind = document.createElement('span');
            sortfwdind.id = "sorttable_sortfwdind";
            sortfwdind.innerHTML = stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;';
            this.appendChild(sortfwdind);
            return;
          }
          
          // remove sorttable_sorted classes
          theadrow = this.parentNode;
          forEach(theadrow.childNodes, function(cell) {
            if (cell.nodeType == 1) { // an element
              cell.className = cell.className.replace('sorttable_sorted_reverse','');
              cell.className = cell.className.replace('sorttable_sorted','');
            }
          });
          sortfwdind = document.getElementById('sorttable_sortfwdind');
          if (sortfwdind) { sortfwdind.parentNode.removeChild(sortfwdind); }
          sortrevind = document.getElementById('sorttable_sortrevind');
          if (sortrevind) { sortrevind.parentNode.removeChild(sortrevind); }
          
          this.className += ' sorttable_sorted';
          sortfwdind = document.createElement('span');
          sortfwdind.id = "sorttable_sortfwdind";
          sortfwdind.innerHTML = stIsIE ? '&nbsp<font face="webdings">6</font>' : '&nbsp;&#x25BE;';
          this.appendChild(sortfwdind);

	        // build an array to sort. This is a Schwartzian transform thing,
	        // i.e., we "decorate" each row with the actual sort key,
	        // sort based on the sort keys, and then put the rows back in order
	        // which is a lot faster because you only do getInnerText once per row
	        row_array = [];
	        col = this.sorttable_columnindex;
	        rows = this.sorttable_tbody.rows;
	        for (var j=0; j<rows.length; j++) {
	          row_array[row_array.length] = [sorttable.getInnerText(rows[j].cells[col]), rows[j]];
	        }
	        /* If you want a stable sort, uncomment the following line */
	        sorttable.shaker_sort(row_array, this.sorttable_sortfunction);
	        /* and comment out this one */
	        //row_array.sort(this.sorttable_sortfunction);
	        
	        tb = this.sorttable_tbody;
	        for (var j=0; j<row_array.length; j++) {
	          tb.appendChild(row_array[j][1]);
	        }
	        
	        delete row_array;
	      });
	    }
    }
  },
  
  guessType: function(table, column) {
    // guess the type of a column based on its first non-blank row
    sortfn = sorttable.sort_alpha;
    for (var i=0; i<table.tBodies[0].rows.length; i++) {
      text = sorttable.getInnerText(table.tBodies[0].rows[i].cells[column]);
      if (text != '') {
          // Only the "Size" column in the manifest report is numeric.  Everything
          // else is plain text and can be sorted alphabetically.
        if (text.match(/^\d* bytes/)) {
          return sorttable.sort_numeric;
        }
      }
    }
    return sortfn;
  },
  
  getInnerText: function(node) {
    // gets the text we want to use for sorting for a cell.
    // strips leading and trailing whitespace.
    // this is *not* a generic getInnerText function; it's special to sorttable.
    // for example, you can override the cell text with a customkey attribute.
    // it also gets .value for <input> fields.
    
    hasInputs = (typeof node.getElementsByTagName == 'function') &&
                 node.getElementsByTagName('input').length;
    
    if (node.getAttribute("sorttable_customkey") != null) {
      return node.getAttribute("sorttable_customkey");
    }
    else if (typeof node.textContent != 'undefined' && !hasInputs) {
      return node.textContent.replace(/^\s+|\s+$/g, '');
    }
    else if (typeof node.innerText != 'undefined' && !hasInputs) {
      return node.innerText.replace(/^\s+|\s+$/g, '');
    }
    else if (typeof node.text != 'undefined' && !hasInputs) {
      return node.text.replace(/^\s+|\s+$/g, '');
    }
    else {
      switch (node.nodeType) {
        case 3:
          if (node.nodeName.toLowerCase() == 'input') {
            return node.value.replace(/^\s+|\s+$/g, '');
          }
        case 4:
          return node.nodeValue.replace(/^\s+|\s+$/g, '');
          break;
        case 1:
        case 11:
          var innerText = '';
          for (var i = 0; i < node.childNodes.length; i++) {
            innerText += sorttable.getInnerText(node.childNodes[i]);
          }
          return innerText.replace(/^\s+|\s+$/g, '');
          break;
        default:
          return '';
      }
    }
  },
  
  reverse: function(tbody) {
    // reverse the rows in a tbody
    newrows = [];
    for (var i=0; i<tbody.rows.length; i++) {
      newrows[newrows.length] = tbody.rows[i];
    }
    for (var i=newrows.length-1; i>=0; i--) {
       tbody.appendChild(newrows[i]);
    }
    delete newrows;
  },
  
  /* sort functions
     each sort function takes two parameters, a and b
     you are comparing a[0] and b[0] */
  sort_numeric: function(a,b) {
    aa = parseFloat(a[0].replace(/[^0-9.-]/g,''));
    if (isNaN(aa)) aa = 0;
    bb = parseFloat(b[0].replace(/[^0-9.-]/g,'')); 
    if (isNaN(bb)) bb = 0;
    return aa-bb;
  },
  sort_alpha: function(a,b) {
    if (a[0]==b[0]) return 0;
    if (a[0]<b[0]) return -1;
    return 1;
  },
  
  shaker_sort: function(list, comp_func) {
    // A stable sort function to allow multi-level sorting of data
    // see: http://en.wikipedia.org/wiki/Cocktail_sort
    // thanks to Joseph Nahmias
    var b = 0;
    var t = list.length - 1;
    var swap = true;

    while(swap) {
        swap = false;
        for(var i = b; i < t; ++i) {
            if ( comp_func(list[i], list[i+1]) > 0 ) {
                var q = list[i]; list[i] = list[i+1]; list[i+1] = q;
                swap = true;
            }
        } // for
        t--;

        if (!swap) break;

        for(var i = t; i > b; --i) {
            if ( comp_func(list[i], list[i-1]) < 0 ) {
                var q = list[i]; list[i] = list[i-1]; list[i-1] = q;
                swap = true;
            }
        } // for
        b++;

    } // while(swap)
  }  
}

/* ******************************************************************
   Supporting functions: bundled here to avoid depending on a library
   ****************************************************************** */

// Dean Edwards/Matthias Miller/John Resig

/* for Mozilla/Opera9 */
if (document.addEventListener) {
    document.addEventListener("DOMContentLoaded", sorttable.init, false);
}

/* for Internet Explorer */
/*@cc_on @*/
/*@if (@_win32)
    document.write("<script id=__ie_onload defer src=javascript:void(0)><\/script>");
    var script = document.getElementById("__ie_onload");
    script.onreadystatechange = function() {
        if (this.readyState == "complete") {
            sorttable.init(); // call the onload handler
        }
    };
/*@end @*/

/* for Safari */
if (/WebKit/i.test(navigator.userAgent)) { // sniff
    var _timer = setInterval(function() {
        if (/loaded|complete/.test(document.readyState)) {
            sorttable.init(); // call the onload handler
        }
    }, 10);
}

/* for other browsers */
window.onload = sorttable.init;

// written by Dean Edwards, 2005
// with input from Tino Zijdel, Matthias Miller, Diego Perini

// http://dean.edwards.name/weblog/2005/10/add-event/

function dean_addEvent(element, type, handler) {
	if (element.addEventListener) {
		element.addEventListener(type, handler, false);
	} else {
		// assign each event handler a unique ID
		if (!handler.$$guid) handler.$$guid = dean_addEvent.guid++;
		// create a hash table of event types for the element
		if (!element.events) element.events = {};
		// create a hash table of event handlers for each element/event pair
		var handlers = element.events[type];
		if (!handlers) {
			handlers = element.events[type] = {};
			// store the existing event handler (if there is one)
			if (element["on" + type]) {
				handlers[0] = element["on" + type];
			}
		}
		// store the event handler in the hash table
		handlers[handler.$$guid] = handler;
		// assign a global event handler to do all the work
		element["on" + type] = handleEvent;
	}
};
// a counter used to create unique IDs
dean_addEvent.guid = 1;

function removeEvent(element, type, handler) {
	if (element.removeEventListener) {
		element.removeEventListener(type, handler, false);
	} else {
		// delete the event handler from the hash table
		if (element.events && element.events[type]) {
			delete element.events[type][handler.$$guid];
		}
	}
};

function handleEvent(event) {
	var returnValue = true;
	// grab the event object (IE uses a global event object)
	event = event || fixEvent(((this.ownerDocument || this.document || this).parentWindow || window).event);
	// get a reference to the hash table of event handlers
	var handlers = this.events[event.type];
	// execute each event handler
	for (var i in handlers) {
		this.$$handleEvent = handlers[i];
		if (this.$$handleEvent(event) === false) {
			returnValue = false;
		}
	}
	return returnValue;
};

function fixEvent(event) {
	// add W3C standard event methods
	event.preventDefault = fixEvent.preventDefault;
	event.stopPropagation = fixEvent.stopPropagation;
	return event;
};
fixEvent.preventDefault = function() {
	this.returnValue = false;
};
fixEvent.stopPropagation = function() {
  this.cancelBubble = true;
}

// Dean's forEach: http://dean.edwards.name/base/forEach.js
/*
	forEach, version 1.0
	Copyright 2006, Dean Edwards
	License: http://www.opensource.org/licenses/mit-license.php
*/

// array-like enumeration
if (!Array.forEach) { // mozilla already supports this
	Array.forEach = function(array, block, context) {
		for (var i = 0; i < array.length; i++) {
			block.call(context, array[i], i, array);
		}
	};
}

// generic enumeration
Function.prototype.forEach = function(object, block, context) {
	for (var key in object) {
		if (typeof this.prototype[key] == "undefined") {
			block.call(context, object[key], key, object);
		}
	}
};

// character enumeration
String.forEach = function(string, block, context) {
	Array.forEach(string.split(""), function(chr, index) {
		block.call(context, chr, index, string);
	});
};

// globally resolve forEach enumeration
var forEach = function(object, block, context) {
	if (object) {
		var resolve = Object; // default
		if (object instanceof Function) {
			// functions have a "length" property
			resolve = Function;
		} else if (object.forEach instanceof Function) {
			// the object implements a custom forEach method so use that
			object.forEach(block, context);
			return;
		} else if (typeof object == "string") {
			// the object is a string
			resolve = String;
		} else if (typeof object.length == "number") {
			// the object is array-like
			resolve = Array;
		}
		resolve.forEach(object, block, context);
	}
};
]]>
                </script>
                <style type="text/css">
div.hierarchy {
    width: 60%;
}
p.analysisdate {
    width: 60%;
}
div.actions {
    float: right;
    border: 1px solid black;
}
                </style>
                <title><xsl:value-of select="$strings/title"/>
                    <xsl:value-of select="MDLDepSet[1]/MDLName"/>
                </title>
            </head>
            <body bgcolor="#ffffff">
                <h1><xsl:value-of select="$strings/title"/>
                    <xsl:value-of select="MDLDepSet[1]/MDLName"/>
                </h1>
                
                <!-- Actions (regenerate manifest, etc.) -->
                <xsl:call-template name="actions"/>

                <!-- Analysis date -->
                <p class="analysisdate"><xsl:value-of select="$strings/analysis_performed"/>
                    <xsl:value-of select="MDLDepSet[1]/AnalysisDate"/>
                </p>

                <!-- Block diagram hierarchy -->
                <div class="hierarchy">
                    <h3><xsl:value-of select="$strings/hierarchy"/></h3>
                    <ul>
                        <xsl:apply-templates select="MDLDepSet[1]" mode="tree">
                            <xsl:with-param name="already_processed" select="','"/>
                        </xsl:apply-templates>
                    </ul>
                </div>

                <!-- Files in the manifest -->
                <h2><xsl:value-of select="$strings/files_used"/></h2>
                <p><b><xsl:value-of select="$strings/root_directory"/></b>:
                    <xsl:choose>
                        <xsl:when test="FileList/@ProjectRoot=''">
                            <em><xsl:value-of select="$strings/no_project_root"/></em>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="FileList/@ProjectRoot"/>
                        </xsl:otherwise>
                    </xsl:choose></p>

                <xsl:choose>
                    <xsl:when test="count(FileList/FileState)=0">
                        <!-- This is the only likely reason for an empty file list -->
                        <xsl:value-of select="$strings/all_in_toolboxes"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <em class="clicktosort"><xsl:value-of select="$strings/click_to_sort"/></em>
                        <table class="sortable" border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/filename"/></th>
                                <th><xsl:value-of select="$strings/filesize"/></th>
                                <th><xsl:value-of select="$strings/lastmodified"/></th>
                                <th><xsl:value-of select="$strings/exportable"/></th>
                            </tr>
                            <!-- Manifests in R2008b and earlier do not have FileList sections.
                                 But since we always resave the manifest before creating the
                                 report, we can assume here that all manifests have this section. --> 
                            <xsl:for-each select="./FileList/FileState">
                                <tr>
                                    <td>
                                        <xsl:call-template name="absname_display"/>&nbsp;
                                        <xsl:choose>
                                          <!-- This is fragile, because it depends on the value of
                                               the LastModifiedDate for a missing file being
                                               exactly "<file not found>". -->
                                            <xsl:when test="LastModifiedDate!='&lt;file not found&gt;'">
                                              <xsl:call-template name="openref_file"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </td>
                                    <td><xsl:value-of select="Size"/><xsl:value-of select="$strings/bytes"/></td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="LastModifiedDate!='&lt;file not found&gt;'">
                                                <xsl:value-of select="LastModifiedDate"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$strings/file_not_found"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <td><xsl:value-of select="dependencies:exportable_value(Exportable)"/></td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- Toolboxes -->
                <h2><xsl:value-of select="$strings/toolboxes"/></h2>
                <ul>
                    <xsl:choose>
                        <xsl:when test="count(MDLDepSet/Toolboxes/ToolboxDetails)=0">
                            <xsl:value-of select="$strings/no_toolboxes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Show each toolbox once only.
                                generate-id() returns the ID of this node.
                                key('distinct-toolboxname',.) returns all nodes with the same content as this one,
                                so key(...)[1] returns the first node in that set
                                generate-id(...) returns the ID of that node, so the '=' operation is true only
                                  if the current node is the first in the set of nodes which have the content as it
                                so the for-each loop rejects nodes which have the same content as an earlier node,
                                 i.e. it selects a unique set of nodes
                            -->
                            <xsl:for-each select="./MDLDepSet/Toolboxes/ToolboxDetails[generate-id()=generate-id(key('distinct-toolboxname',.)[1])]">
                                <li><xsl:value-of select="Name"/> (<xsl:value-of select="Version"/>)</li>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
                
                
                <!-- References -->
                <h2><xsl:value-of select="$strings/references_in_model"/></h2>
                <xsl:choose>
                    <xsl:when test="MDLDepSet[1]/AnalysisOptions/StoreReferences='true'">                        
                        <p><xsl:value-of select="$strings/references_table_description"/></p>
                        
                        <xsl:choose>
                            <xsl:when test="count(./MDLDepSet/AllReferences/FileReference)>0">
                                <em class="clicktosort"><xsl:value-of select="$strings/click_to_sort"/></em>
                                <table class="sortable" border="1">
                                    <tr>
                                        <th><xsl:value-of select="$strings/reference_type"/></th>
                                        <th><xsl:value-of select="$strings/reference_location"/></th>
                                        <th><xsl:value-of select="$strings/filename"/></th>
                                        <th><xsl:value-of select="$strings/toolbox"/></th>
                                    </tr>
                                    <xsl:apply-templates select="./MDLDepSet/AllReferences/FileReference"/>
                                </table>
                            </xsl:when>
                            <xsl:otherwise>
                                <h3><xsl:value-of select="$strings/references"/></h3>
                                <p><xsl:value-of select="$strings/no_references"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>  
                    <xsl:otherwise>
                        <p><xsl:value-of select="$strings/references_not_stored"/></p>
                    </xsl:otherwise>    
                </xsl:choose>
                

                <!-- Folders -->
                <h2><xsl:value-of select="$strings/directories"/></h2>
                <xsl:choose>
                    <xsl:when test="count(./MDLDepSet/AllIncludeDirs/DirReference)>0">
                        <em class="clicktosort"><xsl:value-of select="$strings/click_to_sort"/></em>
                        <table class="sortable" border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/reference_type"/></th>
                                <th><xsl:value-of select="$strings/reference_location"/></th>
                                <th><xsl:value-of select="$strings/directory_name"/></th>
                            </tr>
                            <xsl:apply-templates select="./MDLDepSet/AllIncludeDirs/DirReference"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <p><xsl:value-of select="$strings/no_directories"/></p>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Orphaned Data -->
                <h2><xsl:value-of select="$strings/orphaneddata"/></h2>
                <p><xsl:value-of select="$strings/orphaneddata_description"/></p>
                <xsl:choose>
                    <xsl:when test="count(./OrphanedData/Orphan)>0">
                        <em class="clicktosort"><xsl:value-of select="$strings/click_to_sort"/></em>
                        <table class="sortable" border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/variable_name"/></th>
                                <th><xsl:value-of select="$strings/variable_type"/></th>
                                <th><xsl:value-of select="$strings/reference_location"/></th>
                            </tr>
                            <xsl:apply-templates select="./OrphanedData/Orphan"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="MDLDepSet[1]/AnalysisOptions/FindWorkspaceVars[.!='true']">
                                <p><xsl:value-of select="$strings/orphans_not_stored"/></p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p><xsl:value-of select="$strings/no_orphans"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- Warnings -->
                <h2><xsl:value-of select="$strings/warnings"/></h2>
                <xsl:choose>
                    <xsl:when test="count(./Warnings/Warning)>0">
                        <em class="clicktosort"><xsl:value-of select="$strings/click_to_sort"/></em>
                        <table class="sortable" border="1">
                            <tr>
                                <th><xsl:value-of select="$strings/reference_type"/></th>
                                <th><xsl:value-of select="$strings/reference_location"/></th>
                                <th><xsl:value-of select="$strings/warning_message"/></th>
                            </tr>
                            <xsl:apply-templates select="./Warnings/Warning"/>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="MDLDepSet[1]/AnalysisOptions/StoreWarnings[.!='true']">
                                <p><xsl:value-of select="$strings/warnings_not_stored"/></p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p><xsl:value-of select="$strings/no_warnings"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                               
                <!-- Analysis options -->
                <h3><xsl:value-of select="$strings/settings"/></h3>
                <xsl:apply-templates select="MDLDepSet[1]/AnalysisOptions"/>
            </body>
        </html>
    </xsl:template>
                
    <!-- Actions hyperlinks: renegerate manifest, etc. -->
    <xsl:template name="actions">
        <div class="actions">
            <div style="width: 100%; background-color: #CCC;">&nbsp;<b><xsl:value-of select="$strings/actions"/></b></div>
            <ul>
                <li>
                    <a>
<xsl:attribute name="href">matlab:dependencies.manifestcallback('generate','<xsl:value-of select="MDLDepSet[1]/MDLName"/>')</xsl:attribute>
                        <xsl:value-of select="$strings/regenerate"/>
                    </a> <xsl:value-of select="$strings/this_manifest"/>
                </li>
                <li><a>
<xsl:attribute name="href">matlab:dependencies.manifestcallback('additionalfiles','<xsl:value-of select="MDLDepSet[1]/MDLName"/>')</xsl:attribute>
                <xsl:value-of select="$strings/edit"/></a> <xsl:value-of select="$strings/this_manifest"/></li>
                <li><a>
<xsl:attribute name="href">matlab:dependencies.manifestcallback('compare','<xsl:value-of select="MDLDepSet[1]/MDLName"/>')</xsl:attribute>
                <xsl:value-of select="$strings/compare"/></a><xsl:value-of select="$strings/this_manifest_with"/></li>
                <li><a>
<xsl:attribute name="href">matlab:dependencies.manifestcallback('export','<xsl:value-of select="MDLDepSet[1]/MDLName"/>')</xsl:attribute>
                <xsl:value-of select="$strings/export"/></a><xsl:value-of select="$strings/files_to_zip"/></li>
        </ul></div>
    </xsl:template>

    <xsl:template match="MDLDepSet" mode="tree">
        <xsl:param name="already_processed"/>
        <xsl:choose>
            <!-- If this MDL has already been processed, skip it now to avoid
                 infinite recursion.  Search for the name with leading and trailing
                 commas just incase this MDL has a name which is a subset of
                 another MDL's name -->
            <xsl:when test="contains($already_processed,concat(',',MDLName,','))">
                <xsl:value-of select="MDLName"/> <xsl:value-of select="$strings/recurses"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="now_processed"><xsl:value-of select="$already_processed"/><xsl:value-of select="MDLName"/>,</xsl:variable>
                <li>
                    <a>
                        <xsl:attribute name="href">matlab:open_system('<xsl:value-of select="MDLName"/>')</xsl:attribute>
                        <xsl:value-of select="MDLName"/>
                    </a>
                    <xsl:if test="count(LinkedLibraries/MDLFile)>0 or count(ReferencedModels/MDLFile)>0">
                        <ul>
                            <xsl:for-each select="ReferencedModels/MDLFile">
                                <xsl:apply-templates select="." mode="tree">
                                    <xsl:with-param name="already_processed" select="$now_processed"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                            <xsl:for-each select="LinkedLibraries/MDLFile">
                                <xsl:apply-templates select="." mode="tree">
                                    <xsl:with-param name="already_processed" select="$now_processed"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="MDLFile" mode="tree">
        <xsl:param name="already_processed"/>
        <!-- temporary variable for the name of this file -->
        <xsl:variable name="tempname">
            <xsl:value-of select="MDLName"/>
        </xsl:variable>
        <!-- find the matching MDLDepSet node -->
        <xsl:for-each select="/DependencyReport/MDLDepSet">
            <xsl:if test="MDLName=$tempname">
                <!-- got it.  Call the template on it -->
                <xsl:apply-templates select="." mode="tree">
                    <xsl:with-param name="already_processed"><xsl:value-of select="$already_processed"/></xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="AllFiles">
        <xsl:param name="current_mdl_name"/>
        <a>
            <xsl:attribute name="name"><xsl:value-of select="$current_mdl_name"/>_AllFiles</xsl:attribute>
        </a>
    </xsl:template>

    <xsl:template match="ToolboxDetails" mode="unique">
        <xsl:param name="already_processed"/>
        <xsl:choose>
            <xsl:when test="contains($already_processed,Name)">
                <!-- nothing -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="now_processed"><xsl:value-of select="$already_processed"/><xsl:value-of select="Name"/>,</xsl:variable>
                <li>
                    <xsl:value-of select="Name"/>
                    (<xsl:value-of select="Version"/>)
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- FileReference in the "References in this model" table -->
    <xsl:template match="FileReference">
        <tr>
            <td><xsl:value-of select="ReferenceType"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="ReferenceLocation[.!='']">
                        <xsl:value-of select="ReferenceLocation"/>&nbsp;
                        <xsl:call-template name="openref_location">
                            <xsl:with-param name="loc"><xsl:value-of select="ReferenceLocation"/></xsl:with-param>
                            <xsl:with-param name="type"><xsl:value-of select="ReferenceType"/></xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>&nbsp;</xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:call-template name="absname_display"/>&nbsp;
                <xsl:choose>
                    <xsl:when test="Resolved='true'">
                        <xsl:call-template name="openref_file"/>
                    </xsl:when>
                    <xsl:otherwise> <xsl:value-of select="$strings/not_found"/> </xsl:otherwise>
                </xsl:choose>
            </td>
            <td><xsl:apply-templates select="ToolboxDetails" mode="fileref"/></td>
        </tr>
    </xsl:template>

    <!-- ToolboxDetails inside a FileReference, shown in the final column
         of the "References in this model" table. -->
    <xsl:template match="ToolboxDetails" mode="fileref">
        <xsl:choose>
            <xsl:when test="count(./Name)=0">
                <xsl:value-of select="$strings/not_in_toolbox"/>
            </xsl:when>
            <xsl:otherwise>
            <xsl:value-of select="Name"/>
            (<xsl:value-of select="Version"/>)
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="DirReference">
        <tr>
            <td><xsl:value-of select="ReferenceType"/></td>
            <td><xsl:value-of select="ReferenceLocation"/></td>
            <!-- This is an equivalent of the "absname_display" template, but for
                 DirName elements. -->
             <td><xsl:choose>
                <xsl:when test="DirName/@RelativeTo='matlabroot'">$matlabroot/<xsl:value-of select="DirName"/></xsl:when>
                <xsl:when test="DirName/@RelativeTo='projectroot'">$projectroot/<xsl:value-of select="DirName"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="DirName"/></xsl:otherwise>
            </xsl:choose></td>
       </tr>
    </xsl:template>

    <xsl:template match="Warning">
        <tr>
            <td><xsl:value-of select="@ReferenceType"/></td>
            <td>
                <xsl:value-of select="ReferenceLocation"/>&nbsp;
                <xsl:choose>
                    <xsl:when test="@ReferenceType[.='MATLABFile'] and ReferenceLocation/@Line[.!='']">
                        (<xsl:value-of select="$strings/line_number"/>&nbsp;
                        <xsl:value-of select="ReferenceLocation/@Line"/>)&nbsp;
                        <xsl:call-template name="openref_location">
                            <xsl:with-param name="loc"><xsl:value-of select="ReferenceLocation"/>:<xsl:value-of select="ReferenceLocation/@Line"/></xsl:with-param>
                            <xsl:with-param name="type">MATLABFileLine</xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="openref_location">
                            <xsl:with-param name="loc"><xsl:value-of select="ReferenceLocation"/></xsl:with-param>
                            <xsl:with-param name="type"><xsl:value-of select="@ReferenceType"/></xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
             <td><xsl:value-of select="Message"/></td>
       </tr>
    </xsl:template>
    
    <xsl:template match="Orphan">
        <tr>
            <td><xsl:value-of select="@VariableName"/></td>
            <td><xsl:value-of select="VariableType"/></td>
            <td>
                <xsl:value-of select="ReferenceLocation"/>&nbsp;
                <xsl:call-template name="openref_location">
                    <xsl:with-param name="loc"><xsl:value-of select="ReferenceLocation"/></xsl:with-param>
                    <xsl:with-param name="type">Block</xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>
    

    <!-- For any element that contains a "FileName" element -->
    <xsl:template name="openref_location">
      <xsl:param name="loc"/>
      <xsl:param name="type"/>
      <a>
        <xsl:attribute name="href">matlab:dependencies.openref('<xsl:value-of select="$type"/>','<xsl:value-of select="$loc"/>');</xsl:attribute>
        <xsl:value-of select="$strings/show"/>
      </a>
    </xsl:template>
    
    <!-- For any element that contains a "FileName" element -->
    <xsl:template name="openref_file">
      <xsl:choose>
        <xsl:when test="dependencies:canopenfile(FileName)='true'">
           <a>
            <xsl:attribute name="href">matlab:dependencies.openref('OpenFile',<xsl:call-template name="absname_matlab"/>);</xsl:attribute>
            <xsl:value-of select="$strings/open"/>
          </a>
         </xsl:when>
      </xsl:choose>
    </xsl:template>
    
    <!-- For any element that contains a FileName element, returns the
         absolute file name in a form that can be evaluated by MATLAB -->
    <xsl:template name="absname_matlab">
        <xsl:choose>
            <xsl:when test="FileName/@RelativeTo='matlabroot'">fullfile(matlabroot,'<xsl:value-of select="FileName"/>')</xsl:when>
            <xsl:when test="FileName/@RelativeTo='projectroot'">'<xsl:value-of select="replace(/DependencyReport/FileList/@ProjectRoot, '''', '''''')"/>/<xsl:value-of select="FileName"/>'</xsl:when>
            <xsl:otherwise>'<xsl:value-of select="FileName"/>'</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- For any element that contains a FileName element, returns the
         file name in a form that can be displayed to the user -->
    <xsl:template name="absname_display">
        <xsl:choose>
            <xsl:when test="FileName/@RelativeTo='matlabroot'">$matlabroot/<xsl:value-of select="FileName"/></xsl:when>
            <xsl:when test="FileName/@RelativeTo='projectroot'">$projectroot/<xsl:value-of select="FileName"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="FileName"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="AnalysisOptions">
        <ul>
            <li>
                <xsl:value-of select="$strings/find_orphans"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindWorkspaceVars)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_mdlrefs"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindModelRefs)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_liblinks"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindLibraryLinks)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/unsaved_changes"/>
                <xsl:sequence select="dependencies:analysis_option_value(AllowUnsavedChanges)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_sfcns"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindSFunctions)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_callbacks"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindCallbackFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_codegen"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindCodeGenFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_datafiles"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindDataFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_stateflow"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeStateflow)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_eml"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeEML)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/find_reqs"/>
                <xsl:sequence select="dependencies:analysis_option_value(FindRequirementsDocs)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/analyze_user"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeUserToolboxFiles)"/>
            </li>            
            <li>
                <xsl:value-of select="$strings/analyze_mfiles"/>
                <xsl:sequence select="dependencies:analysis_option_value(AnalyzeMFiles)"/>
            </li>
            <li>
                <xsl:value-of select="$strings/report_dependency_locations"/>:
                <xsl:choose>
                    <xsl:when test="StoreReferences='true'">
                        <xsl:choose>
                            <xsl:when test="StoreMathWorksReferences='true'">
                                &nbsp;<b><xsl:value-of select="$strings/all_files"/></b>
                            </xsl:when>
                            <xsl:otherwise>
                                &nbsp;<b><xsl:value-of select="$strings/user_files"/></b>
                            </xsl:otherwise>    
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        &nbsp;<b><xsl:value-of select="$strings/none"/></b>
                    </xsl:otherwise>   
                </xsl:choose> 
            </li>
            <li>
                <xsl:value-of select="$strings/store_warnings"/>
                <xsl:sequence select="dependencies:analysis_option_value(StoreWarnings)"/>
            </li>
        </ul>
    </xsl:template>

</xsl:stylesheet>

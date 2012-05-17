//Copyright 2010 The MathWorks, Inc.

function rtwannotate(filename) {
  var xmlDoc;
  var supportXML = false;
  if (window.XMLHttpRequest) {
      try {
          xhttp=new XMLHttpRequest();
          supportXML = true;
          xhttp.open("GET",filename,false);
          xhttp.send("");
          xmlDoc=xhttp.responseXML;
      } catch(e) {}
  }
  if (typeof xmlDoc == "undefined" &&  navigator.appName == "Microsoft Internet Explorer") {
      // Internet Explorer 5/6 
      try {
          xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
          xmlDoc.async = false;
          supportXML = true;
          xmlDoc.load(filename);
      } catch(e) {}
  }
  var rtwCode = document.getElementById("RTWcode");
  if (xmlDoc) {
    // style
    var style = xmlDoc.getElementsByTagName("style");
    if (style) {
      for (i=0;i<style.length;++i) {
        var cssCode = style[i].firstChild.nodeValue;
        var styleElement = document.createElement("style");
        styleElement.type = "text/css";
        if (styleElement.styleSheet) {
          styleElement.styleSheet.cssText = cssCode;
        } else {
          styleElement.appendChild(document.createTextNode(cssCode));
        }
        document.getElementsByTagName("head")[0].appendChild(styleElement);
      }
    }
    // summary
    var summary = xmlDoc.getElementsByTagName("summary")[0];
    if (summary) {
      var summaryAnnotation = summary.getElementsByTagName("annotation")[0];
      if (summaryAnnotation) {
        var span = document.createElement("span");
        span.innerHTML = summaryAnnotation.firstChild.nodeValue;
        rtwCode.parentNode.insertBefore(span,rtwCode);
      }
    }
    // line
    var data = xmlDoc.getElementsByTagName("line");
    var annotationsTable = new Array();
    var defaultAnnotation;
    for (i=0;i<data.length;++i) {
      var id = data[i].getAttribute("id");
      if (id == "default") {
        defaultAnnotation = data[i].getElementsByTagName("annotation")[0];
      } else {
        annotationsTable[parseInt(id)] = data[i].getElementsByTagName("annotation");
      }
    }
    var lines = rtwCode.childNodes;
    for (i=0;i<lines.length;++i) {
      var annotations = annotationsTable[i+1];
      if (annotations && annotations.length > 0) {  
        // first annotation
        var span = document.createElement("span");
        span.innerHTML = annotations[0].firstChild.nodeValue;
        lines[i].insertBefore(span,lines[i].firstChild);
        // more annotations
        for (j=1;j<annotations.length;++j) {
          span = document.createElement("span");
          span.innerHTML = annotations[j].firstChild.nodeValue + "<br />";
          // how to handle nl?
          lines[i].appendChild(span);
        }
      } else if (defaultAnnotation) {
        // default annotation
        var newElement = document.createElement("span");
        newElement.innerHTML = defaultAnnotation.firstChild.nodeValue;
        lines[i].insertBefore(newElement,lines[i].firstChild);
      }
    }
  } else if (!supportXML && navigator.appName != "ICEbrowser" ) {
      var span = document.createElement("span");
      span.innerHTML = "<SPAN>  Warning: Code coverage data is not loaded due to a web browser compatibility issue.</SPAN>";
      rtwCode.parentNode.insertBefore(span,rtwCode);
  }
}


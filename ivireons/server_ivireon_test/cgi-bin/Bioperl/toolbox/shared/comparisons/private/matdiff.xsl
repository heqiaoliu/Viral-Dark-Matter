<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY nl "&#10;">
  <!ENTITY nbsp "&#160;">
  ]>

<!-- 
   Copyright 2010 The MathWorks, Inc.
   $Revision: 1.1.6.4 $
-->

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:matfilecomparison="http://www.mathworks.com/matfilecomparison"
    xmlns:msg="http://www.mathworks.com/comparisonmessages"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:messageformat="java:com.mathworks.comparisons.util.ResourceManager">
    <xsl:output method="html" encoding="utf-8"
        media-type="text/html" indent="yes" />

    <!-- Default language is "en". -->
    <xsl:param name="language">en</xsl:param>
    <!-- This needs to be supplied in URL format, including the trailing separator -->
    <xsl:param name="matlabroot"/>
    <!-- Load the message catalogue for the current language -->
    <xsl:param name="catalogue"
        select="document(concat($matlabroot,'resources','/','MATLAB','/',$language,'/','Comparisons.xml'))"/>

    <!-- Colours to be used for variables in various states -->
    <xsl:param name="leftvarcolor">#BBF</xsl:param>
    <xsl:param name="rightvarcolor">#BFB</xsl:param>
    <xsl:param name="modifiedvarcolor">#FBB</xsl:param>
    <xsl:param name="identicalvarcolor">#FFF</xsl:param>

    <!--xsl:strip-space elements="*"/-->

    <!-- Converts the "contentsMatch" attribute value to an appropriate
         colour specification.  Different functions for files and folders -->
    <xsl:function name="matfilecomparison:getvarcolor">
        <xsl:param name="contentsMatch"/>
        <xsl:choose>
            <xsl:when test="$contentsMatch='yes'"><xsl:value-of select="$identicalvarcolor"/></xsl:when>
            <xsl:when test="$contentsMatch='no'"><xsl:value-of select="$modifiedvarcolor"/></xsl:when>
            <!-- When only the classes differ we highlight only the "Class" column. -->
            <xsl:when test="$contentsMatch='classesdiffer'"><xsl:value-of select="$identicalvarcolor"/></xsl:when>
        </xsl:choose>
    </xsl:function> 

    <!-- Extracts the resource string with the specified key from the 
         message catalogue -->
    <xsl:function name="msg:messagecatalogue">
        <xsl:param name="key"/>
        <xsl:variable name="fullkey"><xsl:value-of select="concat('MatDiff',$key)"/></xsl:variable>
        <xsl:value-of select="$catalogue/rsccat/message/entry[@key=$fullkey]"/>
    </xsl:function> 

    <!-- Returns the resource string with the specified key. -->
    <xsl:function name="msg:format0">
        <xsl:param name="key"/>
        <xsl:value-of select="msg:messagecatalogue($key)"/>
    </xsl:function> 

    <!-- Returns the resource string with the specified key, substituting a
         single argument, specified in the string as {0}. -->
    <xsl:function name="msg:format1">
        <xsl:param name="key"/>
        <xsl:param name="arg"/>
        <xsl:variable name="fmt"><xsl:apply-templates select="msg:messagecatalogue($key)"/></xsl:variable>
        <xsl:value-of select="messageformat:formatMessage1($fmt,$arg)"/>
    </xsl:function> 
    
    <!-- Root element. -->
    <xsl:template match="MatFileEditScript">        
        <script type="text/javascript">
            <xsl:attribute name="src"><xsl:value-of select="$matlabroot"/>toolbox/shared/comparisons/private/sorttable.js</xsl:attribute>
        </script>
        <script language="javascript">
            var LEFT_FILE = &quot;<xsl:value-of select="fn:encode-for-uri(LeftLocation/@Readable)"/>&quot;;
            var RIGHT_FILE = &quot;<xsl:value-of select="fn:encode-for-uri(RightLocation/@Readable)"/>&quot;;
            // Getting the root window is browser dependent.  On some platforms the
            // parent of root is the window, and window.window is window.
            // On other browsers, parent can be undefined.
            function getRootWindow() {
              if (parent) {return parent.window;} else {return window;}
            }
            function openvar(side,varname) {
              var rootWindow=getRootWindow();
              if (side=="left") {
                rootWindow.location="matlab:comparisons_private('matview','"+LEFT_FILE+"','"+varname+"','_left')";
              } else {
                rootWindow.location="matlab:comparisons_private('matview','"+RIGHT_FILE+"','"+varname+"','_right')";
              }
            }
            window.onload=function() {
              // The table sorting code doesn't work the version of ICEBrowser that
              // ships with 64-bit MATLAB.  Hide the text that says "Click to sort".
              if (navigator.appName=="ICEbrowser") {
                // There's only one "em" tag on this page
                var element = document.getElementsByTagName('em');
                var index=0;
                for (index=0;index&lt;element.length;index=index+1) {
                  element.item(index).style.display='none';
                }
              }
            }
        </script>
        <style type="text/css">
            td, th {
                padding-left: 5px;
                padding-right: 5px;
                padding-top: 2px;
                padding-bottom: 2px;
                border-right: 1px;
                border-top: #777777 1px solid;
                border-left: #777777 1px solid;
                border-bottom: 1px;
            }
            table {
                border-spacing: 0px;
                border-right: #777777 1px solid;
                border-bottom: #777777 1px solid;
            }
        </style>
        <!-- Title, file names and header text -->
        <h2><xsl:value-of select="Title" disable-output-escaping="yes"/></h2>
        <table id="files" cellspacing="0">
            <tr>
                <td><b><xsl:value-of select="msg:format0('LeftFile')"/></b>&nbsp;</td>
                <td><code><xsl:value-of select="LeftLocation"/></code></td>
            </tr>
            <tr>
                <td><b><xsl:value-of select="msg:format0('RightFile')"/></b>&nbsp;</td>
                <td><code><xsl:value-of select="RightLocation"/></code></td>
            </tr>
        </table>
        <p/>
        <xsl:value-of select="msg:format0('ReportHeader')" disable-output-escaping="yes"/>
        
        <!-- Table of variables -->
        <em id="clicktosort"><xsl:value-of select="msg:format0('ClickToSort')"/></em>
        
        <table class="sortable" id="varlist" cellspacing="0">
            <thead>
                <tr>
                    <th colspan="3"><xsl:value-of select="msg:format1('VariablesIn',LeftLocation/@ShortName)" disable-output-escaping="yes"/></th>
                    <th colspan="3"><xsl:value-of select="msg:format1('VariablesIn',RightLocation/@ShortName)" disable-output-escaping="yes"/></th>
                    <th>&nbsp;</th>
                </tr>
            <tr style="background: #EEE">
                <th>
                  <xsl:attribute name="class">sorttable_alpha</xsl:attribute>
                  <xsl:value-of select="msg:format0('VarName')"/>
                </th>
                <th>
                  <xsl:attribute name="class">sorttable_numeric</xsl:attribute>
                  <xsl:value-of select="msg:format0('Size')"/>
                </th>
                <th>
                  <xsl:attribute name="class">sorttable_alpha</xsl:attribute>
                  <xsl:value-of select="msg:format0('Class')"/>
                </th>
                <th>
                  <xsl:attribute name="class">sorttable_alpha</xsl:attribute>
                  <xsl:value-of select="msg:format0('VarName')"/>
                </th>
                <th>
                  <xsl:attribute name="class">sorttable_numeric</xsl:attribute>
                  <xsl:value-of select="msg:format0('Size')"/>
                </th>
                <th>
                  <xsl:attribute name="class">sorttable_alpha</xsl:attribute>
                  <xsl:value-of select="msg:format0('Class')"/>
                </th>
                <th>
                  <xsl:attribute name="class">sorttable_alpha</xsl:attribute>
                  <xsl:value-of select="msg:format0('Status')"/>
                </th>
            </tr>
            </thead>
            <xsl:apply-templates mode="full"/>
        </table>
        <p/>
        <!-- Hyperlinks for loading the file contents -->
        <a>
          <xsl:attribute name="href">matlab:uiopen('<xsl:value-of select="LeftLocation"/>',1)</xsl:attribute>
          <xsl:value-of select="msg:format1('Load',LeftLocation/@ShortName)" disable-output-escaping="yes"/>
        </a>
        <br/>
        <a>
          <xsl:attribute name="href">matlab:uiopen('<xsl:value-of select="RightLocation"/>',1)</xsl:attribute>
          <xsl:value-of select="msg:format1('Load',RightLocation/@ShortName)" disable-output-escaping="yes"/>
        </a>
    </xsl:template>

    <xsl:template match="LeftLocation" mode="full">
        <!-- This information was already printed in the EditScript template above-->
    </xsl:template>

    <xsl:template match="RightLocation" mode="full">
        <!-- This information was already printed in the EditScript template above-->
    </xsl:template>

    <xsl:template match="Title" mode="full">
        <!-- This information was already printed in the EditScript template above-->
    </xsl:template>

    <!-- Generate hyperlinks for opening or comparing files and folders -->
    <xsl:template name="openhyperlink">
        <xsl:param name="side">must be specified!</xsl:param>
        <xsl:param name="name">must be specified!</xsl:param>
        <a>
            <xsl:attribute name="href">javascript:openvar('<xsl:value-of select="$side"/>','<xsl:value-of select="$name"/>');</xsl:attribute>
            <xsl:value-of select="$name"/>
        </a>
    </xsl:template>
    
    <!-- A file which appears in the left list only -->
    <xsl:template match="LeftVariable" mode="full">
        <tr>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$leftvarcolor"/></xsl:attribute>
                <xsl:call-template name="openhyperlink">
                    <xsl:with-param name="side">left</xsl:with-param>
                    <xsl:with-param name="name"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
            </td>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$leftvarcolor"/></xsl:attribute>
                <xsl:value-of select="@size"/></td>
            <td>
                <xsl:attribute name="class">var</xsl:attribute>
                <xsl:attribute name="style">background: <xsl:value-of select="$leftvarcolor"/></xsl:attribute>
                <xsl:value-of select="@class"/></td>
            <td colspan="3" class="var"><xsl:value-of select="msg:format0('NotInList')" disable-output-escaping="yes"/></td>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$leftvarcolor"/></xsl:attribute>
                <xsl:value-of select="msg:format0('Removed')" disable-output-escaping="yes"/>
            </td>
        </tr>
    </xsl:template>

    <!-- A file which appears in the right list only -->
    <xsl:template match="RightVariable" mode="full">
        <tr>
            <td colspan="3" class="var"><xsl:value-of select="msg:format0('NotInList')" disable-output-escaping="yes"/></td>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$rightvarcolor"/></xsl:attribute>
                <xsl:call-template name="openhyperlink"> 
                  <xsl:with-param name="side">right</xsl:with-param>
                  <xsl:with-param name="name"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
            </td>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$rightvarcolor"/></xsl:attribute>
                <xsl:value-of select="@size"/></td>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$rightvarcolor"/></xsl:attribute>
                <xsl:value-of select="@class"/></td>
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$rightvarcolor"/></xsl:attribute>
                <xsl:value-of select="msg:format0('Added')" disable-output-escaping="yes"/>
            </td>
        </tr>
    </xsl:template>
    
    <!-- A variable which appears in both columns.  The value of the "contentsMatch"
         attribute determines what we need to display. -->
    <xsl:template match="Variable" mode="full">
        <xsl:variable name="color"><xsl:value-of select="matfilecomparison:getvarcolor(@contentsMatch)"/></xsl:variable>
        <tr>
            <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
            <!-- Name -->
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                <xsl:call-template name="openhyperlink"> 
                  <xsl:with-param name="side">left</xsl:with-param>
                  <xsl:with-param name="name"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
            </td>
            <!-- Left size -->
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                <xsl:value-of select="@leftsize"/>
            </td>
            <!-- Left class -->
            <td class="var">
                <xsl:choose>
                    <xsl:when test="@contentsMatch='classesdiffer'">
                        <xsl:attribute name="style">background: <xsl:value-of select="matfilecomparison:getvarcolor('no')"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="@leftclass"/>
            </td>
            <!-- Name again (hyperlink to open the right-hand variable -->
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                <xsl:call-template name="openhyperlink">
                  <xsl:with-param name="side">right</xsl:with-param>
                  <xsl:with-param name="name"><xsl:value-of select="."/></xsl:with-param>
                </xsl:call-template>
            </td>
            <!-- Right size -->
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                <xsl:value-of select="@rightsize"/>
            </td>
            <!-- Right class -->
            <td class="var">
                <xsl:choose>
                    <xsl:when test="@contentsMatch='classesdiffer'">
                        <xsl:attribute name="style">background: <xsl:value-of select="matfilecomparison:getvarcolor('no')"/></xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="@rightclass"/>
            </td>
            <!-- Status -->
            <td class="var">
                <xsl:attribute name="style">background: <xsl:value-of select="$color"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="@contentsMatch='yes'"><xsl:value-of select="msg:format0('Identical')" disable-output-escaping="yes"/></xsl:when>
                    <xsl:when test="@contentsMatch='no'">
                        <xsl:value-of select="msg:format0('Modified')" disable-output-escaping="yes"/>&nbsp;
                    </xsl:when>
                    <xsl:when test="@contentsMatch='classesdiffer'">
                        <xsl:value-of select="msg:format0('ClassesDiffer')" disable-output-escaping="yes"/>&nbsp;
                    </xsl:when>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>


<?xml version="1.0" encoding="utf-8"?>

<!-- 
   Copyright 2006-2008 The MathWorks, Inc.
   $Revision: 1.1.6.2 $
-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dependencies="http://www.mathworks.com/manifest">
    <xsl:output method="html" encoding="utf-8"
        media-type="text/html" indent="yes" />

    <!--xsl:strip-space elements="*"/-->

    <xsl:template match="DepSetDiffs">
        <html><head>
                <!--link rel="stylesheet" type="text/css" href="mcss.css"/-->
                <title>Model Manifest Differences Report
                </title>
            </head>
            <body bgcolor="#ffffff">
                <h2>Model Manifest Differences Report</h2>

                <h3>First Manifest</h3>
                <div style="margin-left: 30px">
                    <xsl:if test="boolean(string(Manifest1))">
                        <p><b>File:  </b> <xsl:value-of select="Manifest1"/></p>
                    </xsl:if>
                    <p><b>Analysis performed:  </b>
                        <xsl:apply-templates select="DepSet1/MDLDepSet[1]/AnalysisDate"/>
                    </p>
                    <h4>Simulink block diagram names:</h4>
                    <ul>
                        <xsl:apply-templates select="DepSet1/MDLDepSet/MDLName"/>
                    </ul>
                    <p><b>Project root:   </b>
                        <xsl:choose>
                            <xsl:when test="ProjectRoots/FirstProjectRoot=''">
                                (no project root specified)
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ProjectRoots/FirstProjectRoot"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                </div>

                <h3>Second Manifest</h3>
                <div style="margin-left: 30px">
                    <xsl:if test="boolean(string(Manifest2))">
                        <p><b>File:  </b> <xsl:value-of select="Manifest2"/></p>
                    </xsl:if>
                    <p><b>Analysis performed:  </b>
                        <xsl:apply-templates select="DepSet2/MDLDepSet[1]/AnalysisDate"/>
                    </p>
                    <h4>Simulink block diagram names:</h4>
                    <ul>
                        <xsl:apply-templates select="DepSet2/MDLDepSet/MDLName"/>
                    </ul>
                    <p><b>Project root:   </b>
                        <xsl:choose>
                            <xsl:when test="ProjectRoots/SecondProjectRoot=''">
                                (no project root specified)
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ProjectRoots/SecondProjectRoot"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                </div>

                <h3>Files in first manifest only:</h3>
                <p>
                    <xsl:if test="count(FilesInFirstOnly/FileState)=0">
                        (none)
                    </xsl:if>
                    <xsl:if test="count(FilesInFirstOnly/FileState)>0">
                        <table border="1">
                            <tr>
                                <th>File Name</th>
                                <th>Size</th>
                                <th>Last Modified Date</th>
                            </tr>
                            <xsl:apply-templates select="FilesInFirstOnly/FileState"/>
                        </table>
                    </xsl:if>
                </p>
                <h3>Files in second manifest only:</h3>
                <p>
                    <xsl:if test="count(FilesInSecondOnly/FileState)=0">
                        (none)
                    </xsl:if>
                    <xsl:if test="count(FilesInSecondOnly/FileState)>0">
                        <table border="1">
                            <tr>
                                <th>File Name</th>
                                <th>Size</th>
                                <th>Last Modified Date</th>
                            </tr>
                            <xsl:apply-templates select="FilesInSecondOnly/FileState"/>
                        </table>
                    </xsl:if>
                </p>
                <h3>Modified files</h3>
                <p>
                    <xsl:if test="count(ModifiedFilesFirst/FileState)=0">
                        (none)
                    </xsl:if>
                    <xsl:if test="count(ModifiedFilesFirst/FileState)>0">
                        <p>
                        (These are the files which appear in both manifests but with
                        different date-stamps, meaning that they have been modified
                        between the creation of the two manifests.)
                        </p>
                        <table border="1">
                            <tr>
                                <th rowspan="2">File Name</th>
                                <th colspan="2">Size</th>
                                <th colspan="2">Last Modified Date</th>
                            </tr>
                            <tr>
                                <!-- First column occupied by "File Name" cell
                                     from row above -->
                                <th>Manifest 1</th>
                                <th>Manifest 2</th>
                                <th>Manifest 1</th>
                                <th>Manifest 2</th>
                            </tr>
                            <xsl:for-each select="ModifiedFilesFirst/FileState">
                                <tr>
                                    <xsl:variable name="pos">
                                        <xsl:value-of select="position()"/>
                                    </xsl:variable>
                                    <td><xsl:call-template name="absname_display"/></td>
                                    <td><xsl:value-of select="Size"/> bytes</td>
                                    <td>
                                        <xsl:value-of select="../../ModifiedFilesSecond/FileState[number($pos)]/Size"/>
                                        bytes
                                    </td>
                                    <td><xsl:value-of select="LastModifiedDate"/></td>
                                    <td>
<xsl:value-of select="../../ModifiedFilesSecond/FileState[number($pos)]/LastModifiedDate"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:if>
                </p>
                <h3>Unmodified files</h3>
                <p>
                    <xsl:if test="count(UnmodifiedFiles/FileState)=0">
                        (none)
                    </xsl:if>
                    <xsl:if test="count(UnmodifiedFiles/FileState)>0">
                        <p>
                            (These are the files which appear in both manifests and have
                            the same date-stamps in both cases.)
                        </p>
                        <table border="1">
                            <tr>
                                <th>File Name</th>
                                <th>Size</th>
                                <th>Last Modified Date</th>
                            </tr>
                            <xsl:apply-templates select="UnmodifiedFiles/FileState"/>
                        </table>
                    </xsl:if>
                </p>
                <h3>Directories included in first manifest only:</h3>
                <xsl:apply-templates select="DirsInFirstOnly"/>

                <h3>Directories included in second manifest only:</h3>
                <xsl:apply-templates select="DirsInSecondOnly"/>

                <h3>Directories included in both manifests:</h3>
                <xsl:apply-templates select="DirsInBoth"/>

            </body>
        </html>
    </xsl:template>

    <xsl:template match="FileState">
        <tr>
            <td><xsl:call-template name="absname_display"/></td>
            <td><xsl:value-of select="Size"/> bytes</td>
            <td><xsl:value-of select="LastModifiedDate"/></td>
        </tr>
    </xsl:template>

    <xsl:template match="DirsInFirstOnly">
        <xsl:apply-templates select="./DirList"/>
    </xsl:template>

    <xsl:template match="DirsInSecondOnly">
        <xsl:apply-templates select="./DirList"/>
    </xsl:template>

    <xsl:template match="DirsInBoth">
        <xsl:apply-templates select="./DirList"/>
    </xsl:template>

    <xsl:template match="DirList">
        <p>
            <xsl:choose>
                <xsl:when test="count(./DirName)=0">
                    (none)
                </xsl:when>
                <xsl:otherwise>
                    <ul>
                        <xsl:apply-templates select="DirName"/>
                    </ul>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>

    <xsl:template match="DirName">
        <li>
            <xsl:choose>
                <xsl:when test="@RelativeTo='matlabroot'">$matlabroot/<xsl:value-of select="."/></xsl:when>
                <xsl:when test="@RelativeTo='projectroot'">$projectroot/<xsl:value-of select="."/></xsl:when>
                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="MDLName">
        <li><xsl:value-of select="."/></li>
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


</xsl:stylesheet>


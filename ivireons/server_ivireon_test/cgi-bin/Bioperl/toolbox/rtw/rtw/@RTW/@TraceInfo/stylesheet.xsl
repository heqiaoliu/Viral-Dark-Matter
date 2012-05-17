<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="traceInfo">
<html>
<head>
<title>Traceability Report</title>
<link rel="stylesheet" type="text/css" href="rtwreport.css"/>
</head>
<body>
<font size="+3" color="#000066">Traceability Report</font>
<xsl:apply-templates select="blocks" mode="eliminated"/>
<xsl:apply-templates select="blocks" mode="traceable"/>
</body>
</html>
</xsl:template>

<xsl:template match="blocks" mode="eliminated">
<h4>Eliminated / Virtual Blocks</h4>
<table border="1" width="100%" cellspacing="0">
<tr>
<th>Block Path</th><th>Comment</th>
</tr>
<xsl:apply-templates select="block" mode="eliminated"/>
</table>
</xsl:template>

<xsl:template match="blocks" mode="traceable">
<h4>Traceable Blocks</h4>
<table border="1" width="100%" cellspacing="0">
<tr>
<th>Block Path</th><th>Code Location</th>
</tr>
<xsl:apply-templates select="block" mode="traceable"/>
</table>
</xsl:template>

<xsl:template match="block">
<xsl:choose>
<xsl:when test="locations/location">
<tr>
<td><xsl:apply-templates select="pathname"/></td>
<td><xsl:apply-templates select="locations"/></td>
</tr>
</xsl:when>
<xsl:otherwise>
<tr>
<td><xsl:apply-templates select="pathname"/></td>
<td>
    <xsl:choose>
      <xsl:when test="locations/comment">
        <p style="color: red"><xsl:value-of select="locations/comment"/></p>
      </xsl:when>
      <xsl:otherwise>
        <p style="color: red">Not traceable</p>
      </xsl:otherwise>
    </xsl:choose>
</td>
</tr>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="block" mode="eliminated">
<xsl:choose>
<xsl:when test="locations/location"></xsl:when>
<xsl:otherwise>
<tr>
<td><xsl:apply-templates select="pathname"/></td>
<td>
    <xsl:choose>
      <xsl:when test="locations/comment">
        <p style="color: red"><xsl:value-of select="locations/comment"/></p>
      </xsl:when>
      <xsl:otherwise>
        <p style="color: red">Not traceable</p>
      </xsl:otherwise>
    </xsl:choose>
</td>
</tr>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="block" mode="virtual">
<xsl:choose>
<xsl:when test="locations/location"></xsl:when>
<xsl:otherwise>
<tr style="background-color: #ffcc99">
<td><xsl:apply-templates select="pathname"/></td>
<td>
    <xsl:choose>
      <xsl:when test="locations/comment">
        <p style="color: red"><xsl:value-of select="locations/comment"/></p>
      </xsl:when>
      <xsl:otherwise>
        <p style="color: red">Not traceable</p>
      </xsl:otherwise>
    </xsl:choose>
</td>
</tr>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="block" mode="traceable">
<xsl:choose>
<xsl:when test="locations/location">
<tr>
<td><xsl:apply-templates select="pathname"/></td>
<td><xsl:apply-templates select="locations"/></td>
</tr>
</xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="pathname">
<xsl:choose>
<xsl:when test="../href">
<a href="{../href};"><xsl:value-of select="."/></a>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="."/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="locations">
<xsl:apply-templates select="location"/>
</xsl:template>

<xsl:template match="location">
<xsl:if test="line > 0">
<p style="margin-top: 0; margin-bottom: 0">
<a href="{href}"><xsl:value-of select="file"/>:<xsl:value-of select="line"/></a></p>
</xsl:if>
</xsl:template>

</xsl:stylesheet>
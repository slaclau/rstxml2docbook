<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     "Resolves" RST XML index.xml file into one, single RST XML file

   Parameters:
     * xml.ext (default '.xml')
       Parameter will be appended to be read in by the document() function

   Input:
     RST XML file, converted with sphinx-build using option -b xml
     Usually you should use 'index.xml' to start with

   Output:
     Single RST XML file without any toctree-wrapper or content sections

   Author:
     Thomas Schraitle <toms AT opensuse.org>
     Copyright 2016 SUSE Linux GmbH

-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  exclude-result-prefixes="exsl">
  
  <!-- ================================================================== -->
  <xsl:param name="xml.ext">.xml</xsl:param>


  <!-- ================================================================== -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================== -->
  <xsl:template match="section[@names='contents']">
    <xsl:apply-templates mode="xinclude"/>
  </xsl:template>

  <xsl:template match="compound[@classes='toctree-wrapper']">
    <xsl:apply-templates mode="xinclude"/>
  </xsl:template>

  <xsl:template match="text()" mode="xinclude"/>

  <xsl:template match="list_item[@classes='toctree-l1']" mode="xinclude">
    <xsl:variable name="ref" select="concat(*/reference/@refuri, $xml.ext)"/>
    <xsl:message>Including "<xsl:value-of select="$ref"/>"...</xsl:message>
    <xsl:apply-templates select="document($ref, .)"/>
  </xsl:template>

</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transforms RST XML tree into DocBook

   Parameters:
     * productname
       The name of the product; added inside <bookinfo>
     * produtnumber
       The number or any other identification of a product; added inside
       <bookinfo>
     * xml.ext
       References to XML files; this parameter contains the extension
       (usually '.xml') which is appended for the reference/@refuri part.
     * rootlang
       (Natural) language of the document; added into the root element as
       lang="$rootlang"

   Input:
     RST XML file, converted with sphinx-build using option -b xml

   Output:
     DocBook 5 document

   Author:
     Thomas Schraitle <toms AT opensuse.org>
     Copyright 2016-2018 SUSE Linux GmbH

-->
<xsl:stylesheet version="1.0"
  xmlns="http://docbook.org/ns/docbook"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:doc="urn:x-suse:xslt-doc"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xl="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="exsl doc d xi xl">

  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- Keys =============================================================-->
  <xsl:key name="id" match="*" use="@ids"/>
  <xsl:key name="documents" match="document" use="@source"/>

  <!-- Parameters =======================================================-->
  <xsl:param name="xml.ext" doc:descr="Extension for referenced files">.xml</xsl:param>
  <xsl:param name="rootlang" doc:descr="Natural language for root element">en</xsl:param>
  <xsl:param name="productname" doc:descr="The product name, empty by default"/>
  <xsl:param name="productnumber" doc:descr="The product number, empty by default"/>
  <xsl:param name="rootversion"
             doc:descr="The value of the version attribute for the root element">5.1</xsl:param>
  <xsl:param name="ids.separator" doc:descr="The separator between IDs on @ids attribute">_</xsl:param>

  <!-- Templates ======================================================= -->
  <xsl:template match="*">
    <!-- <xsl:message>WARN: Unknown element '<xsl:value-of select="local-name()"/>'</xsl:message> -->
  </xsl:template>

  <xsl:template name="include.xmlbase">
   <xsl:param name="node" select="."/>
   <xsl:variable name="xmlbase">
    <xsl:choose>
     <xsl:when test="$node/parent::*/@xml:base">
      <xsl:value-of select="$node/parent::*/@xml:base"/>
     </xsl:when>
    </xsl:choose>
   </xsl:variable>

   <xsl:if test="$xmlbase != ''">
    <xsl:attribute name="xml:base">
     <xsl:value-of select="$xmlbase"/>
    </xsl:attribute>
   </xsl:if>
  </xsl:template>

  <xsl:template name="get.structural.name">
    <xsl:param name="level"/>
    <xsl:choose>
      <xsl:when test="$level = 0">article</xsl:when>
      <xsl:when test="$level >= 1">section</xsl:when>
      <!--
      <xsl:when test="$level = 2">section</xsl:when>
      <xsl:when test="$level = 3">sect2</xsl:when>
      <xsl:when test="$level = 4">sect3</xsl:when>
      <xsl:when test="$level = 5">sect4</xsl:when>
      <xsl:when test="$level = 6">sect5</xsl:when>
      -->
      <xsl:otherwise>
        <xsl:message>ERROR: Level out of scope (level=<xsl:value-of select="$level"/>)</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="create.structural.name">
    <xsl:param name="id" select="@ids"/>
    <xsl:variable name="level" select="count(ancestor::section)"/>
    <xsl:variable name="name">
      <xsl:call-template name="get.structural.name">
        <xsl:with-param name="level" select="$level"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$name"/>
  </xsl:template>

  <xsl:template name="get.target4section.id">
    <xsl:param name="node" select="."/>

    <xsl:choose>
       <xsl:when test="not(contains($node/@ids, ' '))">
         <xsl:value-of select="$node/@ids"/>
       </xsl:when>
        <xsl:when test="$node/preceding-sibling::section[1]/section[1]/section[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::section[1]/section[1]/section[1]/*[last()][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::section[1]/section[last()]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::section[1]/section[last()]/*[last()][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::section[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::section[1]/*[last()][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::*[1][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[1][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="contains($node/@ids, ' ')">
          <!--  -->
         <xsl:value-of select="translate($node/@ids, ' ', $ids.separator)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$node/@ids"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template name="get.target4table.id">
    <xsl:param name="node" select="."/>

    <xsl:choose>
        <!--<xsl:when test="$node/preceding-sibling::section[1]/section[1]/section[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::section[1]/section[1]/section[1]/*[last()][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::section[1]/section[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::section[1]/section[1]/*[last()][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::section[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::section[1]/*[last()][self::target]/@refid"/>
        </xsl:when>-->
        <xsl:when test="$node/preceding-sibling::*[2][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[2][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::*[1][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[1][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="contains($node/@ids, ' ')">
          <xsl:value-of select="substring-after($node/@ids, ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$node/@ids"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template name="get.target.id">
    <xsl:param name="node" select="."/>

    <xsl:choose>
        <!--<xsl:when test="$node/preceding-sibling::*[1]/*[1]/*[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[1]/*[1]/*[1]/*[last()][self::target]/@refid"/>
        </xsl:when>-->
        <!--<xsl:when test="$node/preceding-sibling::*[1]/*[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[1]/*[1]/*[last()][self::target]/@refid"/>
        </xsl:when>-->
        <xsl:when test="$node/preceding-sibling::*[1]/*[last()][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[1]/*[last()][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="$node/preceding-sibling::*[1][self::target]">
          <xsl:value-of select="$node/preceding-sibling::*[1][self::target]/@refid"/>
        </xsl:when>
        <xsl:when test="contains($node/@ids, ' ')">
          <xsl:value-of select="substring-after($node/@ids, ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$node/@ids"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <!-- Taken from common/common.xsl of the DocBook stylesheets -->
  <xsl:template name="filename-basename">
    <!-- We assume all filenames are really URIs and use "/" -->
    <xsl:param name="filename"/>
    <xsl:param name="recurse" select="false()"/>

    <xsl:choose>
      <xsl:when test="substring-after($filename, '/') != ''">
        <xsl:call-template name="filename-basename">
          <xsl:with-param name="filename" select="substring-after($filename, '/')"/>
          <xsl:with-param name="recurse" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- =================================================================== -->
  <!-- Ignored elements                                                    -->
  <xsl:template match="section[@names='search\ in\ this\ guide']"/>
  <xsl:template match="section[@names='abstract']"/>

  <xsl:template match="comment"/>
  <xsl:template match="index"/>
  <xsl:template match="meta"/>
  <xsl:template match="raw"/>
  <xsl:template match="target"/>
  <xsl:template match="substitution_definition"/>


  <!-- =================================================================== -->
  <!-- Skipped elements                                                    -->
  <xsl:template match="hlist|hlistcol">
   <xsl:apply-templates/>
  </xsl:template>

  <!-- =================================================================== -->
  <xsl:template match="document">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/document[@role='big']/section">
    <xsl:variable name="idattr">
      <xsl:call-template name="get.target4section.id"/>
    </xsl:variable>

    <article xml:lang="{$rootlang}" version="{$rootversion}"  xml:id="index">
      <xsl:call-template name="include.xmlbase"/>
      <xsl:apply-templates select="title"/>
      <info>
        <xsl:apply-templates select="section[@names='abstract']" mode="info"/>
        <xsl:if test="$productname != ''">
          <productname>
            <xsl:value-of select="$productname"/>
          </productname>
        </xsl:if>
        <xsl:if test="$productnumber != ''">
          <productnumber>
            <xsl:value-of select="$productnumber"/>
          </productnumber>
        </xsl:if>
      </info>
      <xsl:apply-templates select="*[not(self::title)]"/>
    </article>
  </xsl:template>

  <xsl:template match="/document[@role='big']/section/document/section">
    <xsl:variable name="idattr">
      <xsl:call-template name="get.target4section.id"/>
    </xsl:variable>

    <section>
      <xsl:if test="$idattr != ''">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="$idattr"/>
        </xsl:attribute>
      </xsl:if>
     <xsl:call-template name="include.xmlbase"/>
      <xsl:apply-templates/>
    </section>
  </xsl:template>

  <xsl:template match="section[@names = 'abstract']" mode="info">
     <abstract>
      <xsl:apply-templates/>
    </abstract>
  </xsl:template>

  <xsl:template match="section">
    <xsl:variable name="name">
      <xsl:call-template name="create.structural.name"/>
    </xsl:variable>
    <xsl:variable name="idattr">
      <xsl:call-template name="get.target4section.id"/>
    </xsl:variable>
    <xsl:variable name="level" select="count(ancestor::section)"/>

    <xsl:element name="{$name}">
      <xsl:if test="@ids">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="$idattr"/>
        </xsl:attribute>
      </xsl:if>
     <xsl:call-template name="include.xmlbase"/>
      <xsl:apply-templates>
        <xsl:with-param name="root" select="$name"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="section/title">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>

  <xsl:template match="section[@names='contents']">
    <xsl:apply-templates mode="xinclude"/>
  </xsl:template>

  <xsl:template match="compound[@classes='toctree-wrapper']">
    <xsl:apply-templates mode="xinclude"/>
  </xsl:template>

  <xsl:template match="text()" mode="xinclude"/>

  <xsl:template match="list_item[@classes='toctree-l1']" mode="xinclude">
    <xsl:variable name="xiref" select="*/reference/@refuri"/>
    <!--<xi:include href="{$xiref}" xmlns:xi="http://www.w3.org/2001/XInclude"/>-->
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:attribute name="href">
        <xsl:value-of select="$xiref"/>
      </xsl:attribute>
    </xsl:element>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>


  <!-- =================================================================== -->
  <xsl:template match="block_quote">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="seealso">
    <formalpara>
       <title>See also</title>
       <xsl:choose>
        <xsl:when test="paragraph">
          <xsl:apply-templates select="paragraph[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <para/>
        </xsl:otherwise>
       </xsl:choose>
    </formalpara>
    <xsl:apply-templates select="paragraph[position()>1]"/>
     <xsl:apply-templates select="*[not(self::paragraph)]"/>
  </xsl:template>

  <xsl:template match="manpage">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="literal_block
                       | literal_block[@language='shell' or @language='console']
                       | literal[@classes='sp_cli']
                       | doctest_block" name="screen">
    <screen>
      <xsl:apply-templates/>
    </screen>
  </xsl:template>

  <xsl:template match="literal_block[@language]|block_quote/literal_block[@language]">
    <screen language="{@language}">
      <xsl:apply-templates/>
    </screen>
  </xsl:template>

  <xsl:template match="line_block[line[normalize-space(.)='']]"/>

  <xsl:template match="note|tip|warning|caution|important">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="local-name()='caution'">important</xsl:when>
        <xsl:otherwise><xsl:value-of select="local-name(.)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$name}">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="paragraph">
    <para>
      <xsl:apply-templates/>
    </para>
  </xsl:template>

  <xsl:template match="bullet_list[@bullet='-' or @bullet='*']|bullet_list">
    <itemizedlist>
      <xsl:apply-templates/>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="list_item">
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>

  <xsl:template match="enumerated_list">
    <procedure>
      <xsl:apply-templates/>
    </procedure>
  </xsl:template>

  <xsl:template match="enumerated_list/list_item">
    <xsl:variable name="id">
      <xsl:call-template name="get.target.id"/>
    </xsl:variable>
    <step>
      <xsl:if test="$id != ''">
        <xsl:attribute name="xml:id"><xsl:value-of select="$id"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </step>
  </xsl:template>

  <xsl:template match="definition_list">
    <variablelist>
      <xsl:apply-templates select="definition_list_item"/>
    </variablelist>
  </xsl:template>

  <xsl:template match="definition_list_item">
    <varlistentry>
      <xsl:apply-templates/>
      <xsl:apply-templates select="../definition"/>
    </varlistentry>
  </xsl:template>

  <xsl:template match="definition_list_item/term">
    <term>
      <xsl:apply-templates/>
    </term>
  </xsl:template>

  <xsl:template match="definition">
    <listitem>
      <xsl:apply-templates/>
    </listitem>
  </xsl:template>


  <!-- =================================================================== -->
  <xsl:template match="section[@names='glossary'][document/section[@names='glossary']]">
   <!-- Just skip this double entry: -->
   <xsl:message>INFO: skipping document for glossary</xsl:message>
   <xsl:apply-templates select="document/section[@names='glossary']"/>
  </xsl:template>

  <xsl:template match="document/section[@names='glossary']">
   <glossary>
    <xsl:call-template name="include.xmlbase"/>
    <xsl:apply-templates/>
   </glossary>
  </xsl:template>

 <xsl:template match="section[@names='glossary']/section">
  <xsl:variable name="name">
   <xsl:call-template name="create.structural.name"/>
  </xsl:variable>
  <xsl:variable name="idattr">
   <xsl:call-template name="get.target4section.id"/>
  </xsl:variable>
  <xsl:message>INFO: Add glossdiv <xsl:value-of select="$idattr"/></xsl:message>
  <glossdiv>
    <xsl:attribute name="xml:id"><xsl:value-of select="$idattr"/></xsl:attribute>
   <xsl:call-template name="include.xmlbase"/>
   <xsl:apply-templates select="title"/>
   <xsl:apply-templates select="*[not(self::title)]"/>
  </glossdiv>
 </xsl:template>

 <xsl:template match="section[@names='glossary']/section/glossary">
  <xsl:apply-templates/>
 </xsl:template>

  <xsl:template match="*" mode="glossary">
      <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="glossary">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="definition_list[@classes='glossary']">
      <xsl:apply-templates select="definition_list_item"/>
  </xsl:template>

  <xsl:template match="definition_list[@classes='glossary']/definition_list_item">
   <xsl:variable name="idattr">
     <xsl:value-of select="term/@ids"/>
   </xsl:variable>
    <glossentry>
      <xsl:if test="$idattr">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="$idattr"/>
        </xsl:attribute>
        <xsl:message>INFO: Add xml:id=<xsl:value-of select="$idattr"/></xsl:message>
      </xsl:if>
      <xsl:call-template name="include.xmlbase"/>
      <xsl:apply-templates select="term"/>
      <xsl:apply-templates select="definition"/>
    </glossentry>
  </xsl:template>

  <xsl:template match="definition_list[@classes='glossary']/definition_list_item/term">
   <glossterm>
      <xsl:apply-templates/>
   </glossterm>
  </xsl:template>

  <xsl:template match="definition_list[@classes='glossary']/definition_list_item/term/index"/>

  <xsl:template match="definition_list[@classes='glossary']/definition_list_item/definition">
    <xsl:message>INFO: Add definition of <xsl:value-of select="normalize-space(../term)"/>, xml:id=<xsl:value-of select="../term/@ids"/></xsl:message>
    <glossdef>
      <xsl:apply-templates/>
    </glossdef>
  </xsl:template>


  <!-- =================================================================== -->
  <xsl:template match="table">
    <xsl:variable name="title">
     <xsl:choose>
      <xsl:when test="title">
       <xsl:apply-templates select="title"/>
      </xsl:when>
      <!--<xsl:when test="preceding-sibling::paragraph[1][strong]">
       <xsl:apply-templates select="preceding-sibling::paragraph[1]/strong"/>
      </xsl:when>-->
     </xsl:choose>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:call-template name="get.target4table.id"/>
    </xsl:variable>
    <xsl:variable name="tabletype">
      <xsl:choose>
        <xsl:when test="$title != ''">table</xsl:when>
        <xsl:otherwise>informaltable</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

<!--    <xsl:message>table:
    title=<xsl:value-of select="$title"/>
    xml:id=<xsl:value-of select="$id"/>
    type=<xsl:value-of select="$tabletype"/>
    </xsl:message>-->

    <xsl:element name="{$tabletype}">
      <xsl:if test="$id != ''">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$title != '' and $tabletype = 'table'">
        <xsl:copy-of select="$title"/>
      </xsl:if>
      <xsl:apply-templates mode="table"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="table/title">
   <xsl:variable name="content">
    <xsl:apply-templates/>
   </xsl:variable>
   <title><xsl:value-of select="normalize-space($content)"/></title>
  </xsl:template>

  <xsl:template match="@stub" mode="table"/>

  <xsl:template match="@morecols" mode="table">
   <xsl:attribute name="namest">c1</xsl:attribute>
   <xsl:attribute name="nameend">
    <xsl:text>c</xsl:text>
    <xsl:value-of select=". +1"/>
   </xsl:attribute>
  </xsl:template>

  <xsl:template match="node() | @*" mode="table">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="table"/>
    </xsl:copy>
  </xsl:template>
 
 <xsl:template match="title" mode="table"/>

  <xsl:template match="colspec" mode="table">
    <colspec colname="c{position() -1}">
      <xsl:apply-templates select="@*" mode="table"/>
    </colspec>
  </xsl:template>

  <xsl:template match="row" mode="table">
    <row>
      <xsl:apply-templates mode="table"/>
    </row>
  </xsl:template>

  <xsl:template match="tbody" mode="table">
    <tbody>
      <xsl:apply-templates mode="table"/>
    </tbody>
  </xsl:template>
  <xsl:template match="thead" mode="table">
    <thead>
      <xsl:apply-templates mode="table"/>
    </thead>
  </xsl:template>

  <xsl:template match="tgroup" mode="table">
    <tgroup>
       <xsl:attribute name="cols">
         <xsl:value-of select="count(colspec)"/>
      </xsl:attribute>
      <xsl:apply-templates mode="table"/>
    </tgroup>
  </xsl:template>
  

  <xsl:template match="entry" mode="table">
    <entry>
      <xsl:apply-templates mode="table"/>
    </entry>
  </xsl:template>

  <xsl:template match="entry/*[not(self::paragraph or self::bullet_list)]" mode="table">
    <para>
      <xsl:apply-templates/>
    </para>
  </xsl:template>

  <xsl:template match="paragraph" mode="table">
    <para>
      <xsl:apply-templates/>
    </para>
  </xsl:template>

  <xsl:template match="literal_block|definition_list|bullet_list" mode="table">
    <xsl:apply-templates select="."/>
  </xsl:template>


  <!-- =================================================================== -->
  <xsl:template match="option_list">
   <variablelist>
    <xsl:apply-templates/>
   </variablelist>
  </xsl:template>

  <xsl:template match="option_list_item">
   <varlistentry>
    <xsl:apply-templates/>
   </varlistentry>
  </xsl:template>

  <xsl:template match="option_group">
   <term>
    <xsl:apply-templates/>
   </term>
  </xsl:template>

  <xsl:template match="option">
   <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="option_string">
   <option><xsl:apply-templates/></option>
  </xsl:template>

  <xsl:template match="description">
   <listitem>
    <xsl:apply-templates/>
   </listitem>
  </xsl:template>


  <!-- =================================================================== -->
 <xsl:template match="figure[caption]">
  <figure>
   <title>
    <xsl:apply-templates select="caption"/>
   </title>
   <xsl:apply-templates select="node()[not(self::caption)]">
    <xsl:with-param name="use.informalfigure" select="false()"/>
   </xsl:apply-templates>
  </figure>
 </xsl:template>

  <xsl:template match="figure">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="following-sibling::paragraph[1][strong]">
          <xsl:variable name="tmp.title" select="following-sibling::paragraph[1][strong]"/>
          <xsl:choose>
            <xsl:when test="starts-with($tmp.title, 'Figure:&#xa0;')">
              <xsl:value-of select="substring-after($tmp.title, 'Figure:&#xa0;')"/>
            </xsl:when>
            <xsl:when test="starts-with($tmp.title, 'Figure&#xa0;')">
              <xsl:value-of select="substring-after($tmp.title, 'Figure&#xa0;')"/>
            </xsl:when>
            <xsl:when test="starts-with($tmp.title, 'Figure:')">
              <xsl:value-of select="substring-after($tmp.title, 'Figure:')"/>
            </xsl:when>
            <xsl:when test="starts-with($tmp.title, 'Figure')">
              <xsl:value-of select="substring-after($tmp.title, 'Figure')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$tmp.title"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="caption"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
     <xsl:when test="normalize-space($title) != ''">
       <figure>
        <title><xsl:value-of select="normalize-space($title)"/></title>
        <informalfigure>
         <xsl:apply-templates select="node()[not(self::caption)]">
          <xsl:with-param name="use.informalfigure" select="false()"/>
         </xsl:apply-templates>
        </informalfigure>
       </figure>
     </xsl:when>
     <xsl:otherwise>
         <xsl:apply-templates select="node()[not(self::caption)]">
          <xsl:with-param name="use.informalfigure" select="false()"/>
         </xsl:apply-templates>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="caption|caption/strong">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="image">
    <xsl:param name="use.informalfigure" select="true()"/>
    <xsl:variable name="uri">
      <xsl:call-template name="filename-basename">
        <xsl:with-param name="filename" select="@uri"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="imagedata">
     <imagedata fileref="{$uri}">
      <xsl:if test="@width">
       <xsl:attribute name="width">
        <xsl:value-of select="@width"/>
       </xsl:attribute>
      </xsl:if>
     </imagedata>
    </xsl:variable>
    <xsl:variable name="mediaobject">
     <mediaobject>
      <imageobject role="fo">
       <xsl:copy-of select="$imagedata"/>
      </imageobject>
      <imageobject role="html">
       <xsl:copy-of select="$imagedata"/>
      </imageobject>
     </mediaobject>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="$use.informalfigure = false()">
     <xsl:copy-of select="$mediaobject"/>
     </xsl:when>
     <xsl:otherwise>
      <informalfigure>
       <xsl:copy-of select="$mediaobject"/>
      </informalfigure>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

	<xsl:template match="paragraph[strong][preceding-sibling::figure]"/>

	<xsl:template match="desc">
    <xsl:variable name="id" select="normalize-space(desc_signature/@ids)"/>
	  <variablelist>
			<varlistentry><!-- Bug in libxslt with AVT? -->
			<xsl:if test="$id != ''">
			  <xsl:attribute name="xml:id">
			     <xsl:value-of select="$id"/>
			  </xsl:attribute>
			</xsl:if>
          <xsl:apply-templates/>
			</varlistentry>
		</variablelist>
	</xsl:template>
	
	<xsl:template match="desc_signature">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="../@objtype='function'">
          <xsl:text>function</xsl:text>
        </xsl:when>
        <xsl:when test="../@objtype='method'">
          <xsl:text>property</xsl:text>
        </xsl:when>
        <xsl:when test="../@objtype='attribute'">
          <xsl:text>property</xsl:text>
        </xsl:when>
        <xsl:when test="../@objtype='classmethod'">
          <xsl:text>property</xsl:text>
        </xsl:when>
        <xsl:when test="../@objtype='staticmethod'">
          <xsl:text>property</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>literal</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
      <term>
        <xsl:element name="{$name}">
          <xsl:value-of select="@ids"/>
        </xsl:element>
      </term>
	</xsl:template>

  <xsl:template match="desc_content">
    <listitem>
      <xsl:choose>
        <xsl:when test="not(*)">
          <para/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </listitem>
  </xsl:template>

  <!-- =================================================================== -->
  <xsl:template match="emphasis">
    <emphasis>
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="inline">
   <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="emphasis[@classes='guilabel']|inline[@classes='guilabel']">
    <!-- We use guimenu instead of guilabel here because of GeekoDoc -->
    <guimenu>
      <xsl:apply-templates/>
    </guimenu>
  </xsl:template>

  <xsl:template match="emphasis[@classes='menuselection']|inline[@classes='menuselection']">
    <menuchoice>
      <xsl:call-template name="create.guimenu">
        <xsl:with-param name="text" select="text()"/>
      </xsl:call-template>
    </menuchoice>
  </xsl:template>

  <xsl:template name="create.guimenu">
    <xsl:param name="text"/>
    <xsl:param name="delimiter">&gt;</xsl:param>

    <xsl:if test="$text != ''">
      <guimenu>
        <xsl:value-of select="normalize-space(substring-before(concat($text,$delimiter),$delimiter))"/>
      </guimenu>
      <xsl:call-template name="create.guimenu">
        <xsl:with-param name="text" select="substring-after($text, $delimiter)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="strong[@classes='command']|literal_strong[@classes='command']">
    <command>
      <xsl:apply-templates/>
    </command>
  </xsl:template>

  <xsl:template match="strong" name="strong">
    <emphasis role="bold">
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <xsl:template match="literal|literal_strong" name="literal">
    <literal>
      <xsl:apply-templates/>
    </literal>
  </xsl:template>

  <xsl:template match="literal_emphasis[contains(@classes, 'option')]">
    <option>
      <xsl:apply-templates/>
    </option>
  </xsl:template>

  <xsl:template match="reference[@refuri]">
    <link xl:href="{@refuri}">
      <xsl:if test="@refuri != .">
       <xsl:value-of select="."/>
      </xsl:if>
    </link>
  </xsl:template>

  <xsl:template match="reference[@refuri][@internal='True']">
    <xsl:variable name="uri">
    <xsl:choose>
      <xsl:when test="contains(@refuri,'#')">
        <xsl:value-of select="substring-after(@refuri, '#')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@refuri"/>
      </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$uri != ''">
        <xref linkend="{$uri}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="refuri" select="concat(@refuri, '.xml')"/>
        <xsl:variable name="sectid" select="key('documents', @refuri)"/>
        <xsl:choose>
          <xsl:when test="$sectid != ''">
            <xref linkend="{$sectid}"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>WARNING: could not find referenced ID '<xsl:value-of select="@refuri"/>'!
             sectid="<xsl:value-of select="$sectid"/>"
             refuri=<xsl:value-of select="$refuri"/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="reference[@refid]">
   <xsl:choose>
    <xsl:when test="count(*) > 0">
     <link xl:href="#{@refid}"
      ><xsl:apply-templates/></link>
    </xsl:when>
    <xsl:otherwise>
     <xref linkend="{@refid}"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

  <xsl:template match="title_reference">
    <literal>
      <xsl:apply-templates/>
    </literal>
  </xsl:template>

</xsl:stylesheet>

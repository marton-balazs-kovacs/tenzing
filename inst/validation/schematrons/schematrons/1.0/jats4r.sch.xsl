<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:sch="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:ali="http://www.niso.org/schemas/ali/1.0"
                xmlns:j4r="http://jats4r.org/ns"
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"
                ali:dummy-for-xmlns=""
                j4r:dummy-for-xmlns=""
                mml:dummy-for-xmlns=""
                xsi:dummy-for-xmlns=""
                xlink:dummy-for-xmlns="">

<!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--KEYS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-FULL-PATH-->
<xsl:template match="*|@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>@*[local-name()='schema' and namespace-uri()='http://purl.oclc.org/dsdl/schematron']</xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:choose>
         <xsl:when test="count(. | ../namespace::*) = count(../namespace::*)">
            <xsl:value-of select="concat('.namespace::-',1+count(namespace::*),'-')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA METADATA-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <svrl:ns-prefix-in-attribute-values uri="http://www.niso.org/schemas/ali/1.0" prefix="ali"/>
         <svrl:ns-prefix-in-attribute-values uri="http://jats4r.org/ns" prefix="j4r"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">permissions-errors</xsl:attribute>
            <xsl:attribute name="name">permissions-errors</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">permissions-warnings</xsl:attribute>
            <xsl:attribute name="name">permissions-warnings</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">math-errors</xsl:attribute>
            <xsl:attribute name="name">math-errors</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">math-warnings</xsl:attribute>
            <xsl:attribute name="name">math-warnings</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">data-citations-errors</xsl:attribute>
            <xsl:attribute name="name">data-citations-errors</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="id">data-citations-warnings</xsl:attribute>
            <xsl:attribute name="name">data-citations-warnings</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN permissions-errors-->


	<!--RULE -->
<xsl:template match="article-meta" priority="4000" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="article-meta"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="permissions"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="permissions">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text>
      
      ERROR: Missing top-level &lt;permissions&gt; element. JATS4R-compliant articles must include
      a &lt;permissions&gt; element within &lt;article-meta&gt;.. (See https://jats4r.org/permissions, Recommendation 1.)
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="permissions" priority="3999" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="permissions"/>

		    <!--REPORT -->
<xsl:if test="(copyright-statement|copyright-holder) and not(copyright-year)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(copyright-statement|copyright-holder) and not(copyright-year)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      
      ERROR: Missing &lt;copyright-year&gt;. When an article is under copyright (i.e. it is not in the public domain) a &lt;copyright-year&gt; must be given. (See https://jats4r.org/permissions, Recommendation 3.)
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="(copyright-statement|copyright-year) and not(copyright-holder)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(copyright-statement|copyright-year) and not(copyright-holder)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      
      ERROR: Missing &lt;copyright-holder&gt;. When an article is under copyright
      (i.e. it is not in the public domain) a &lt;copyright-holder&gt; must be given.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="copyright-year" priority="3998" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="copyright-year"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="number() and number() &gt; 999 and number() &lt; 10000"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="number() and number() &gt; 999 and number() &lt; 10000">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text> 
      
      ERROR: &lt;copyright-year&gt; must be a 4-digit year, not "<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>". 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
<xsl:if test="normalize-space(string(.)) != string(.)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="normalize-space(string(.)) != string(.)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      
      ERROR: &lt;copyright-year&gt; should not contain whitespace. 
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="license" priority="3997" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="license"/>

		    <!--REPORT -->
<xsl:if test="@xlink:href and ali:license_ref and                   string(@xlink:href) != string(ali:license_ref)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@xlink:href and ali:license_ref and string(@xlink:href) != string(ali:license_ref)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text>
      
      ERROR: If both @xlink:href and &lt;ali:license_ref&gt; are used to specify the licence
      URI of an article, their contents must match exactly.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="@*|node()" mode="M5"/>
   </xsl:template>

   <!--PATTERN permissions-warnings-->


	<!--RULE -->
<xsl:template match="license" priority="4000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="license"/>

		    <!--REPORT -->
<xsl:if test="@xlink:href and normalize-space(@xlink:href) = ''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@xlink:href and normalize-space(@xlink:href) = ''">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      
      WARNING: Whenever the @xlink:href attribute appears on the &lt;license&gt; element, its
      value must be the canonical URI of a valid license (such as a Creative Commons
      license). In this article, the attribute is empty.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="ali:license_ref and normalize-space(string(ali:license_ref)) = ''">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ali:license_ref and normalize-space(string(ali:license_ref)) = ''">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      
      WARNING: Whenever the ali:license_ref element appears, its
      content must be the canonical URI of a valid license (such as a Creative Commons
      license). In this article, the element is empty.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="j4r:jats-version-later-1d2(/article/@dtd-version) and                    not(@xlink:href) and not(ali:license_ref)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="j4r:jats-version-later-1d2(/article/@dtd-version) and not(@xlink:href) and not(ali:license_ref)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text>
      
      WARNING: No licence URI.
      For JATS 1.1d3 and later, if the licence is defined by a canonical URI, then the
      &lt;license&gt; element should have an &lt;ali:license_ref&gt; child, that specifies
      that URI.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="j4r:jats-version-later-1d2(/article/@dtd-version) and                    @xlink:href and not(ali:license_ref)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="j4r:jats-version-later-1d2(/article/@dtd-version) and @xlink:href and not(ali:license_ref)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text>
      
      WARNING: The license URI is given in @xlink:href.
      For JATS 1.1d3 and later, if the licence is defined by a canonical URI, then it
      should be specified in the &lt;ali:license_ref&gt; child element.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="not(j4r:jats-version-later-1d2(/article/@dtd-version)) and                   not(@xlink:href)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="not(j4r:jats-version-later-1d2(/article/@dtd-version)) and not(@xlink:href)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      
      WARNING: No licence URI.
      For JATS 1.1d2 and earlier, if the licence is defined by a canonical URI, then the
      &lt;license&gt; element should have an @xlink:href attribute, that specifies
      that URI.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="@*|node()" mode="M6"/>
   </xsl:template>

   <!--PATTERN math-errors-->


	<!--RULE -->
<xsl:template match="mml:math | tex-math" priority="4000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="mml:math | tex-math"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="ancestor::disp-formula or ancestor::inline-formula"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::disp-formula or ancestor::inline-formula">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text> 
      ERROR: Math expressions must
      be in &lt;disp-formula&gt; or &lt;inline-formula&gt; elements. They should not appear directly
      in &lt;<xsl:text/>
                  <xsl:value-of select="name(parent::node())"/>
                  <xsl:text/>&gt;. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="disp-formula | inline-formula" priority="3999" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="disp-formula | inline-formula"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         count(child::graphic) + count(child::tex-math) +         count(child::mml:math) &lt; 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(child::graphic) + count(child::tex-math) + count(child::mml:math) &lt; 2">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text> 
      ERROR: Formula element should contain only one expression. If these are alternate
      representations of the same expression, use &lt;alternatives&gt;. If they are different
      expressions, tag each in its own &lt;<xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/>&gt;. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="disp-formula/alternatives | inline-formula/alternatives" priority="3998"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="disp-formula/alternatives | inline-formula/alternatives"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="         count(child::graphic) + count(child::inline-graphic) &lt;= 1 and         count(child::tex-math) &lt;= 1 and         count(child::mml:math) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(child::graphic) + count(child::inline-graphic) &lt;= 1 and count(child::tex-math) &lt;= 1 and count(child::mml:math) &lt;= 1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text> 
      ERROR: For alternate representations of the same expression, there can be at most one of
      each type of representation (graphic or inline-graphic, tex-math, and mml:math). 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="@*|node()" mode="M7"/>
   </xsl:template>

   <!--PATTERN math-warnings-->


	<!--RULE -->
<xsl:template match="disp-formula | inline-formula" priority="4000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="disp-formula | inline-formula"/>

		    <!--REPORT -->
<xsl:if test="(graphic or inline-graphic) and not(mml:math or tex-math)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(graphic or inline-graphic) and not(mml:math or tex-math)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text> 
      WARNING: All mathematical expressions should be provided in markup using either &lt;mml:math&gt; or
      &lt;tex-math&gt;. The only instance in which the graphic representation of a mathematical
      expression should be used outside of &lt;alternatives&gt; and without the equivalent markup is
      where that expression is so complicated that it cannot be represented in markup at all.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="@*|node()" mode="M8"/>
   </xsl:template>

   <!--PATTERN data-citations-errors-->


	<!--RULE -->
<xsl:template match="mixed-citation | element-citation" priority="4000" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="mixed-citation | element-citation"/>

		    <!--REPORT -->
<xsl:if test="data-title and not(@publication-type='data')">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="data-title and not(@publication-type='data')">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text>
       
      ERROR: When &lt;data-title&gt; element is present, the @citation-type must be set to "data". 
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="@publication-type='data' and        (not(source) and not(data-title))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@publication-type='data' and (not(source) and not(data-title))">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text>
       
      ERROR: &lt;data-title&gt; and/or &lt;source&gt; must be present in data citations. 
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
<xsl:if test="@publication-type='data' and        (article-title and not(data-title))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@publication-type='data' and (article-title and not(data-title))">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-get-full-path"/>
            </xsl:attribute>
            <svrl:text>
       
      ERROR: &lt;data-title&gt; must be used in data citations, not &lt;article-title&gt;.
    </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="year[ancestor::mixed-citation or ancestor::element-citation]"
                 priority="3999"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="year[ancestor::mixed-citation or ancestor::element-citation]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="matches(.,'^([1][4-9]|[2][0])[0-9][0-9]$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(.,'^([1][4-9]|[2][0])[0-9][0-9]$')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text>
       
      ERROR: &lt;year&gt; in a citation must be a valid 4-digit year. "<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>" 
      was supplied 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="version" priority="3998" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="version"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="normalize-space(@designator)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="normalize-space(@designator)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-get-full-path"/>
               </xsl:attribute>
               <svrl:text>
       
      ERROR: &lt;version&gt; must include a machine-readable version number in the @designator. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="@*|node()" mode="M9"/>
   </xsl:template>

   <!--PATTERN data-citations-warnings-->
<xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="@*|node()" mode="M10"/>
   </xsl:template>
   <xsl:function xmlns="http://purl.oclc.org/dsdl/schematron"/>
</xsl:stylesheet>
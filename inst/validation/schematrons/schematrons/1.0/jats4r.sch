<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2019 JATS4Reuse (https://jats4r.org)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    -->

<schema xmlns="http://purl.oclc.org/dsdl/schematron"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:j4r="http://jats4r.org/ns"
        queryBinding="xslt2">

<!-- Define all namespaces and prefixes here -->
  <ns prefix="ali" uri="http://www.niso.org/schemas/ali/1.0"/>
  <ns prefix="j4r" uri="http://jats4r.org/ns"/>
  <ns prefix="mml" uri="http://www.w3.org/1998/Math/MathML"/>
  <ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
  <ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>
  <ns prefix="oasis" uri="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"/>

<!-- Set phases for ERRORS and WARNINGS -->
  <phase id="errors">
    <active pattern="abstract-errors"/>
    <active pattern="accessibility-errors"/>
    <active pattern="auths-aff-errors"/>
    <active pattern="coi-errors"/>
    <active pattern="clinical-trial-errors-1"/>
    <active pattern="clinical-trial-errors-2"/>
    <active pattern="credit-errors"/>
    <active pattern="data-availability-errors"/>
    <active pattern="data-citations-errors"/>
    <active pattern="display-object-errors"/>
    <active pattern="ethics-errors"/>
    <active pattern="funding-errors"/>
    <active pattern="general-citations-errors"/>
    <active pattern="general-citations-warnings"/>
    <active pattern="math-errors"/>
    <active pattern="peer-review-errors"/>
    <active pattern="peer-review-errors-2"/>
    <active pattern="permissions-errors"/>
    <active pattern="preprint-citations-errors"/>
    <active pattern="xml-lang-errors"/>
  </phase>
  
  <phase id="warnings">
    <active pattern="abstract-warnings-1"/>
    <active pattern="abstract-warnings-2"/>
    <active pattern="accessibility-warnings"/>
    <active pattern="auths-aff-warnings"/>
    <active pattern="clinical-trial-warnings"/>
    <active pattern="credit-warnings"/>
    <active pattern="data-availability-warnings"/>
    <active pattern="display-object-warnings-1"/>
    <active pattern="display-object-warnings-2"/>
    <active pattern="ethics-warnings"/>
    <active pattern="kwd-warnings"/>
    <active pattern="math-warnings"/>
    <active pattern="peer-review-warnings"/>
    <active pattern="permissions-warnings"/>
    <active pattern="preprint-citations-warnings"/>
    <active pattern="subj-warnings"/>
  </phase>
  
<!-- Call in the files that include the tests -->
  <include href="abstract-errors.sch"/>
  <include href="abstract-warnings-1.sch"/>
  <include href="abstract-warnings-2.sch"/>

  <include href="accessibility-errors.sch"/>
  <include href="accessibility-warnings.sch"/>
  
  <include href="auths-affs-errors.sch"/>
  <include href="auths-affs-warnings.sch"/>
  
  <include href="coi-errors.sch"/>
  
  <include href="clinical-trial-errors-1.sch"/>
  <include href="clinical-trial-errors-2.sch"/>
  <include href="clinical-trial-warnings.sch"/>
  
  <include href="credit-errors.sch"/>
  <include href="credit-warnings.sch"/>
  
  <include href="data-availability-errors.sch"/>
  <include href="data-availability-warnings.sch"/>
  
  <include href="data-citations-errors.sch"/>
  
  <include href="display-object-errors.sch"/>
  <include href="display-object-warnings-1.sch"/>
  <include href="display-object-warnings-2.sch"/>
  
  <include href="ethics-errors.sch"/>
  <include href="ethics-warnings.sch"/>
  
  <include href="funding-errors.sch"/>
  
  <include href="general-citations-errors.sch"/>
  <include href="general-citations-warnings.sch"/>
  
  <include href="kwd-warnings.sch"/>
  
  <include href="math-errors.sch"/>
  <include href="math-warnings.sch"/>
  
  <include href="peer-review-errors.sch"/>
  <include href="peer-review-errors-2.sch"/>
  <include href="peer-review-warnings.sch"/>
  
  <include href="permissions-errors.sch"/>
  <include href="permissions-warnings.sch"/>
  
  <include href="preprint-citations-errors.sch"/>
  <include href="preprint-citations-warnings.sch"/>
  
  <include href="subj-warnings.sch"/>
  
  <include href="xml-lang-errors.sch"/>
  
 <xsl:function name='j4r:jats-version-later-1d2' as="xsd:boolean">
    <xsl:param name="v"/>
    <xsl:variable name='maj' select="substring-before($v, '.')"/>
    <xsl:variable name='min' select="substring-after($v, '.')"/>
    <xsl:variable name='min-is-num' select='number($min) = number($min)'/>
    <xsl:value-of select="
      $maj = '1' and
      ( $min-is-num and number($min) >= 1 or
        not($min-is-num) and $min > '1d2' )
    "/>
  </xsl:function>
  
  <xsl:function name="j4r:coi-type" as="xsd:boolean">
    <xsl:param name="type"/>
    <xsl:value-of select="
      $type='COI_statement' or
      $type='COI-statement' or
      $type='coi_statement' or
      $type='conflict-statement' or
      $type='conflict_statement' or
      $type='conflict-of-interests' or
      $type='conflict_of_interests' or
      $type='conflict-of-interest' or
      $type='conflict_of_interest' or
      $type='competing-interests' or
      $type='competing_interests' or
      $type='competing-interest' or
      $type='competing_interess' or
      $type='conflict'"/>
  </xsl:function>
  
  <xsl:function name="j4r:coi-title" as="xsd:boolean">
    <xsl:param name="title"/>
    <xsl:variable name="testtitle" select="upper-case($title)"/>
    <xsl:value-of select="
      $testtitle='CONFLICT OF INTEREST' or
      $testtitle='CONFLICTS OF INTEREST' or
      $testtitle='CONFLICT OF INTEREST STATEMENT' or
      $testtitle='CONFLICT OF INTEREST STATEMENTS' or
      $testtitle='AUTHOR CONFLICTS' or
      $testtitle='COMPETING INTERESS' or
      $testtitle='COMPETING INTERESTS' or
      $testtitle='CONFLICTS'"/>
  </xsl:function>
  
  <xsl:function name="j4r:data-avail-type" as="xsd:boolean">
    <xsl:param name="type"/>
    <xsl:value-of select="
      $type='data availability' or
      $type='Data availability' or
      $type='Data Availability' or 
      $type='Data-Availability' or 
      $type='data availability statement' or 
      $type='Data availability statement' or 
      $type='Data Availability Statement' or 
      $type='data-availability-statement' or
      $type='Data-availability-statement' or
      $type='Data-Availability-Statement' or 
      $type='Data_Availability' or 
      $type='data_availability-statement' or 
      $type='Data_availability-statement' or
      $type='Data_Availability-Statement' or 
      $type='data_availability' or
      $type='Data Accessibility' or
      $type='Data accessibility'"/>
  </xsl:function>
  
  <!-- global variables for peer review tests -->
  <let name="types-with-related-object" value="('reviewer-report', 'editor-report', 'author-comment')"/>
  <let name="peer-review-types" value="($types-with-related-object, 'community-comment', 'aggregated-review-documents')"/>
  <let name="peer-review-document-types" value="('peer-reviewed-article', 'reviewer-report', 'editor-report', 'author-comment', 'community-comment', 'aggregated-review-documents', 'peer-review-report')"/>
  <let name="unallowed-type-regex" value="string-join(for $value in $peer-review-types return concat('^',replace($value,'-','[\\s_–—\\-]?'),'$'),'|')"/>
  
</schema>

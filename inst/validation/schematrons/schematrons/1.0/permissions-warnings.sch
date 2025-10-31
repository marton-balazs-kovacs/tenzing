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

<pattern id="permissions-warnings" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">

  <rule context="license">
    <let name="jurisdictions" value="'(am|at|au|az|br|ca|ch|cl|cn|cr|cz|de|ec|ee|eg|es|fr|ge|gr|gt|hk|hr|ie|igo|it|lu|nl|no|nz|ph|pl|pr|pt|ro|rs|sg|th|tw|ug|us|ve|vn|za)'"/>
    <let name="p1" value="'https://creativecommons\.org/licenses/by(-sa|-nd|-nc|-nc-sa|-nc-nd)?/4\.0/'"/>
    <let name="p2" value="concat('https://creativecommons\.org/licenses/by(-sa|-nd|-nc|-nc-sa|-nc-nd)?/(1|2|3)\.\d(/', $jurisdictions, ')?/')"/>
    <let name="p3" value="'https://creativecommons\.org/publicdomain/(zero|mark)/1\.0/'"/>
    <let name="li_check" value="if (child::node()[local-name()='license_ref']) then child::node()[local-name()='license_ref'] else @xlink:href"/>
    
    <report test="contains($li_check, 'creativecommons.org') and not(matches($li_check, $p1) or matches($li_check, $p2) or matches($li_check, $p3))" role="warning">
      Creative Commons licenses should follow the recommended patterns. <value-of select="$li_check"/> is not a best practices pattern for a Creative Commons URL. Check that it uses https and a trailing slash.
    </report>

    <!-- If license/@xlink:href exists, it must not be empty -->
    <report test="@xlink:href and normalize-space(@xlink:href) = ''" role="warning"> 
      Whenever the @xlink:href attribute appears on the &lt;license> element, its
      value must be the canonical URI of a valid license (such as a Creative Commons
      license). In this article, the attribute is empty.
    </report>

    <!-- Same for ali:license_ref -->
    <report test="child::node()[local-name()='license_ref'] and normalize-space(string(child::node()[local-name()='license_ref'])) = ''" role="warning"> 
      Whenever the ali:license_ref element appears, its
      content must be the canonical URI of a valid license (such as a Creative Commons
      license). In this article, the element is empty.
    </report>
    

    <!-- For JATS 1.1d3 and later, <license> should have an <ali:license_ref> -->
    <report test="j4r:jats-version-later-1d2(/article/@dtd-version) and  not(child::node()[local-name()='license_ref'])" role="warning">
      No licence URI.
      For JATS 1.1d3 and later, if the licence is defined by a canonical URI, then the
      &lt;license> element should have an &lt;ali:license_ref> child, that specifies
      that URI.
    </report>
    <report test="j4r:jats-version-later-1d2(/article/@dtd-version) and 
      @xlink:href and not(child::node()[local-name()='license_ref'])" role="warning">
      The license URI is given in @xlink:href.
      For JATS 1.1d3 and later, if the licence is defined by a canonical URI, then it
      should be specified in the &lt;ali:license_ref> child element.
    </report>
    
    <!-- For JATS 1.1d2 and earlier, <license> should have an @xlink:href to the license URI -->
   <report test="not(j4r:jats-version-later-1d2(/article/@dtd-version)) and
     not(@xlink:href)" role="warning"> 
      No licence URI.
      For JATS 1.1d2 and earlier, if the licence is defined by a canonical URI, then the
      &lt;license> element should have an @xlink:href attribute, that specifies
      that URI.
    </report>

  </rule>
  
  <rule context="license-p">
    <let name="li_check" value="if (parent::license/child::node()[local-name()='license_ref']) then parent::license/child::node()[local-name()='license_ref'] else parent::license/@xlink:href"/>
    <report test="ext-link and ext-link/@xlink:href != $li_check" role="warning">URI in license-p (<value-of select="ext-link/@xlink:href"/>) does not match canonical license URI (<value-of select="$li_check"/>).</report>
  </rule>
  
  <rule context="copyright-statement">
    <report test="parent::permissions/copyright-year and not(contains(., parent::permissions/copyright-year))" role="warning">
      The contents of &lt;copyright-statement&gt; should not conflict with &lt;copyright-year&gt;.
    </report>
    <report test="parent::permissions/copyright-holder and not(contains(lower-case(.), lower-case(parent::permissions/copyright-holder)))" role="warning">
      The contents of &lt;copyright-statement&gt; should not conflict with &lt;copyright-holder&gt;.
    </report>
  </rule>

</pattern>

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

<pattern id="auths-aff-warnings" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">

    <rule context="/article/front/article-meta[descendant::contrib]">
        <report test="not(descendant::contrib[@contrib-type='author'])" role="warning">
            Articles should have authors included as &lt;contrib contrib-type="author">.
        </report>
    </rule>
    
    <rule context="contrib[@contrib-type='author']/xref[@ref-type='aff' and (* or normalize-space(.)!='')]" role="warning">
        <let name="aff" value="id(./@rid)"/>
        <assert test="$aff/label" role="warning">
            &lt;xref> which contains content, but the &lt;aff> that it points to does not have a label.
        </assert>
    </rule>
    
    <rule context="contrib[@initials]">
        <assert test="matches(@initials,'^[\p{L}]\.?[\p{L}]?\.?[\p{L}]?\.?[\p{L}]?\.?[\p{L}]?\.?$')" role="warning">
            &lt;xref> which contains content, but the &lt;aff> that it points to does not have a label.
        </assert>
    </rule>

  <rule context="aff//country">
    <let name="countries" value="document('countries.xml')"/>
    <let name="country" value="@country"/>
    
    <assert test="@country and (some $code in $countries//*:country satisfies $code/@country = $country)" role="warning">
      &lt;country> should have a @country that includes the ISO 3166-1 2-letter country code.
    </assert>
  </rule>

    <rule context="aff">
        <assert test="institution" role="info">
            &lt;aff> does not contain &lt;institution>
        </assert>
    </rule>
    
    <rule context="collab">
        <report test="ancestor::article-meta and not(parent::contrib[@contrib-type='author'])" role="warning">
            &lt;collab> should be a child of &lt;contrib contrib-type="author"> when it is a group author
        </report>
    </rule>

</pattern>

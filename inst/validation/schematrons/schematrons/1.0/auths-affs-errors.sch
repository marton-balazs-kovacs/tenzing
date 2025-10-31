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

<pattern id="auths-aff-errors" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">

<rule context="aff">
  <report test="parent::article-meta and following-sibling::aff and count(preceding::contrib) > 1 and ((@id and not(idref(@id)) or not(@id)))" role="error">
    When there is more than one author and more than one affiliation, there must be a relationship between them either by position of the &lt;aff> in the &lt;contrib-group> or with &lt;xref ref-type="aff"  in the &lt;contrib> pointing to the @id on the &lt;aff>.
  </report>
  
  <report test="parent::contrib-group and following-sibling::aff and count(preceding-sibling::contrib) > 1 and ((@id and not(idref(@id)) or not(@id)))" role="error">
    When there is more than one author and more than one affiliation in a &lt;contrib-group>, there mut be a relationship between them  defined by an &lt;xref ref-type="aff" in the &lt;contrib> pointing to the @id on the &lt;aff>.
  </report>
  
  <report test="name(child::node()[1])='sup' and string-length(sup[1])=1" role="error">
    Do not put label content in &lt;sup> at the begnning of &lt;aff>. Use  &lt;label> instead.
  </report>
</rule>
  
  <rule context="xref[name(id(@rid))='aff']">
    <assert test="@ref-type and @ref-type='aff'" role="error">
      &lt;xref> that point to &lt;aff> must have @ref-type="aff"/
    </assert>
  </rule>
  
  <rule context="institution-id">
    <assert test="@institution-id-type" role="error">
      &lt;institution-id> must have an @institution-id-type.
    </assert>
  </rule>
  
  <rule context="contrib-id">
    <assert test="normalize-space(@contrib-id-type)!=''" role="error">
      &lt;contrib-id> must have a @contrib-id-type with a non-empty value.
    </assert>
  </rule>

  <rule context="article/front/article-meta">
    <report test="count(descendant::contrib[@contrib-type='author' and @equal-contrib='yes'])=1" role="error">
      There is only one author with the attribute @equal-contrib="yes", which cannot be correct.
    </report>
  </rule>

  <rule context="contrib[@contrib-type='author']">
    <report test="ancestor::collab" role="error">
       &lt;contrib contrib-id-type="author"> should not be a descendant of collab.
    </report>
  </rule>

</pattern>



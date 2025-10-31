<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2020 JATS4Reuse (https://jats4r.org)
    
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

<pattern id="clinical-trial-errors-1" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">
  
  <rule context="related-object[@content-type=('pre-results', 'results', 'post-results')]">
    <let name="registries" value="doc('clinical-trial-registries.xml')"/>
    <let name="source-id" value="@source-id"/>
    
    <report test="@source-id-type='crossref-doi' and not(some $registry in $registries//*:registry satisfies ($registry/@doi = $source-id))" role="error">
      Clinical trial &lt;related-object> elements must have a source-id attribute with a value which is either a WHO-approved registry DOI or name.
    </report>
    
    <assert test="@source-id-type=('crossref-doi','registry-name')" role="error">
      Clinical trial &lt;related-object> elements must have a source-id-type attribute with a value which is 'crossref-doi' or 'registry-name', depending what's in the source-id attribute.
    </assert>
    
    <assert test="@document-id" role="error">
      Clinical trial &lt;related-object> elements must have a document-id attribute with a value which is the clinical trial number as provided in the clinical trial registry.
    </assert>
    
    <assert test="@document-id-type=('clinical-trial-number','doi')" role="error">
      Clinical trial &lt;related-object> elements must have a document-id-type attribute with a value which is either 'clinical-trial-number' or 'doi'. '<value-of select="@document-id-type"/>' is not either of those.
    </assert>
    
  </rule>
  
  <!-- Included here again for related-object elements without the optional content-type attribute -->
  <rule context="related-object[not(@content-type) and @source-id-type='crossref-doi']">
    <let name="registries" value="doc('clinical-trial-registries.xml')"/>
    <let name="source-id" value="@source-id"/>
    
    <assert test="some $registry in $registries//*:registry satisfies ($registry/@doi = $source-id)" role="error">
      Clinical trial links in &lt;related-object source-id-type="crossref-doi"> must have a source-id attribute with a value which is one of the WHO-approved registry DOIs. '<value-of select="$source-id"/>' is not one of the WHO-approved registry DOIs.
    </assert>
    
    <assert test="@document-id" role="error">
      Clinical trial &lt;related-object> elements must have a document-id attribute with a value which is the clinical trial number as provided in the clinical trial registry.
    </assert>
    
    <assert test="@document-id-type=('clinical-trial-number','doi')" role="error">
      Clinical trial &lt;related-object> elements must have a document-id-type attribute with a value which is either 'clinical-trial-number' or 'doi'. '<value-of select="@document-id-type"/>' is not either of those.
    </assert>
    
    <report test="count(tokenize($source-id,' ')) gt 1" role="error">
      source-id attribute on &lt;related-object source-id-type='crossref-doi'> has more than 1 value "<value-of select="$source-id"/>". Each clinical trial number must be captured in its own &lt;related-object> element.
    </report>
    
  </rule>
  
  <!-- Included here again for related-object elements without the optional content-type attribute -->
  <rule context="related-object[not(@content-type) and @source-id-type='registry-name']">
    
    <assert test="@document-id" role="error">
      Clinical trial &lt;related-object> elements must have a document-id attribute with a value which is the clinical trial number as provided in the clinical trial registry.
    </assert>
    
    <assert test="@document-id-type=('clinical-trial-number','doi')" role="error">
      Clinical trial &lt;related-object> elements must have a document-id-type attribute with a value which is either 'clinical-trial-number' or 'doi'. '<value-of select="@document-id-type"/>' is not either of those.
    </assert>
    
  </rule>
  
  
</pattern>



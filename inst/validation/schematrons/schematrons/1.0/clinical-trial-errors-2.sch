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

<pattern id="clinical-trial-errors-2" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">
  
  <rule context="related-object[@document-id and @document-id-type='doi']">
    <let name="document-id" value="@document-id"/>
    
    <assert test="matches($document-id,'^10\.\d{4,9}/[-._;\+()#/:A-Za-z0-9&lt;&gt;\[\]]+$')" role="error">
      &lt;related-object> has a document-id-type='doi' attribute, but the document-id attribute value is not a doi - <value-of select="@document-id"/>.
    </assert>
    
    <report test="count(tokenize(@document-id,' ')) gt 1" role="error">
      document-id attribute on &lt;related-object> has more than 1 value "<value-of select="$document-id"/>". Each object must be captured in its own &lt;related-object> element.
    </report>
  </rule>
  
  <rule context="related-object[@document-id and (not(@document-id-type) or @document-id-type='clinical-trial-number')]">
    <let name="document-id" value="@document-id"/>
    
    <report test="preceding::related-object[@document-id-type='clinical-trial-number' and (@document-id = $document-id)]" role="error">
      More than one &lt;related-object> with the attribute document-id="<value-of select="$document-id"/>" exists in the document.
    </report>
    
    <report test="count(tokenize(@document-id,' ')) gt 1" role="error">
      document-id attribute on &lt;related-object> has more than 1 value "<value-of select="$document-id"/>". Each clinical trial number must be captured in its own &lt;related-object> element.
    </report>
  </rule>
  
  
</pattern>



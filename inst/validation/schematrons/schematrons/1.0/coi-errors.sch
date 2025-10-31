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

<pattern id="coi-errors" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">

  
  
  <rule context="fn[@fn-type='coi-statement']">
    <assert test="parent::author-notes" role="error">
      Conflict of Interest Statements shoud be tagged as &lt;fn fn-type="coi-statement" in the &lt;author-notes>.
    </assert>  
  </rule>
  
  <rule context="fn">
    <report test="@content-type='coi-statement' or j4r:coi-type(@content-type) or j4r:coi-type(@fn-type)" role="error">
      Conflict of Interest Statements shoud be tagged as &lt;fn fn-type="coi-statement" in the &lt;author-notes>.
    </report>
  </rule>
  
  
  <rule context="notes">
    <report test="@notes-type='coi-statement' or j4r:coi-type(@notes-type)" role="error">
      Conflict of Interest Statements shoud be tagged as &lt;fn fn-type="coi-statement" in the &lt;author-notes>.
    </report>
  </rule>
  
  <rule context="p">
    <report test="@content-type='coi-statement' or j4r:coi-type(@content-type) or j4r:coi-title(normalize-space(b[1]))" role="error">
      Conflict of Interest Statements shoud be tagged as &lt;fn fn-type="coi-statement" in the &lt;author-notes>.
    </report>
  </rule>
  
  <rule context="sec">
    <report test="@sec-type='coi-statement' or j4r:coi-type(@sec-type) or j4r:coi-title(normalize-space(title))" role="error">
      Conflict of Interest Statements shoud be tagged as &lt;fn fn-type="coi-statement" in the &lt;author-notes>.
    </report>
  </rule>
  
</pattern>



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

<pattern id="display-object-errors" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="fig-group">
        <let name="fig-count" value="count(fig[label[* or normalize-space(.)!=''] or caption[title[* or normalize-space(.)!=''] or p[* or normalize-space(.)!='']]])"/>
        
        <assert test="$fig-count gt 1" role="error">
            &lt;<name/>> must have more than 1 child &lt;fig> with a label and/or caption. This one has <value-of select="$fig-count"/>.
        </assert>
        
        <assert test="label[* or normalize-space(.)!=''] or caption[title[* or normalize-space(.)!=''] or p[* or normalize-space(.)!='']]" role="error">
            &lt;<name/>> must have a &lt;label> and/or a &lt;caption> with a child &lt;title> and/or &lt;p> which is not empty.
        </assert>
    </rule>
    
    <rule context="fig">
        
        <assert test="graphic or alternatives[graphic]" role="error">
            Images in &lt;<name/>> must be captured using &lt;graphic>. This &lt;<name/>> does not have a &lt;graphic>.
        </assert>
    </rule>
    
    <rule context="table-wrap-group">
        <let name="table-count" value="count(table-wrap[label[* or normalize-space(.)!=''] or caption[title[* or normalize-space(.)!=''] or p[* or normalize-space(.)!='']]])"/>
        
        <assert test="$table-count gt 1" role="error">
            &lt;<name/>> must have more than 1 child &lt;table-wrap> with a label and/or caption. This one has <value-of select="$table-count"/>.
        </assert>
        
        <assert test="label[* or normalize-space(.)!=''] or caption[title[* or normalize-space(.)!=''] or p[* or normalize-space(.)!='']]" role="error">
            &lt;<name/>> must have a &lt;label> and/or a &lt;caption> with a child &lt;title> and/or &lt;p> which is not empty.
        </assert>
    </rule>
    
    <rule context="disp-formula-group">
        <let name="formula-count" value="count(disp-formula)"/>
        
        <assert test="$formula-count gt 1" role="error">
            &lt;<name/>> must have more than 1 child &lt;disp-formula>. This one has <value-of select="$formula-count"/>.
        </assert>
        
        <assert test="label[* or normalize-space(.)!=''] or caption[title[* or normalize-space(.)!=''] or p[* or normalize-space(.)!='']]" role="error">
            &lt;<name/>> must have a &lt;label> and/or a &lt;caption> with a child &lt;title> and/or &lt;p> which is not empty.
        </assert>
    </rule>
    
    <rule context="object-id[@pub-id-type='doi' and parent::*/local-name()=('fig','fig-group','table-wrap','table-wrap-group','disp-formula','disp-formula-group','boxed-text')]">
        
        <assert test="matches(.,'10\.\d{4,9}/[-._;()/:A-Za-z0-9]+$')" role="error">
            &lt;<name/> pub-id-type="doi"> must contain a valid doi. '<value-of select="."/>' is not a valid doi.
        </assert>
    </rule>

</pattern>

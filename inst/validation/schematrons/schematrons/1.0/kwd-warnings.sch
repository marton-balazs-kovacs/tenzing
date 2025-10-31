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

<pattern id="kwd-warnings" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="*[kwd-group]">
    <let name="vanilla-kwd-group-count" value="count(kwd-group[not(@xml:lang) and not(@kwd-group-type)])"/>    
        
        <assert test="$vanilla-kwd-group-count le 1" role="warning">There should not be two or more &lt;kwd-group>s without a @kwd-group-type or @xml:lang attribute. <name/> contains <value-of select="$vanilla-kwd-group-count"/>.</assert>
    </rule>
    
    <rule context="kwd-group">  
        <report test="@xml:lang and (@xml:lang = ancestor::article/@xml:lang)" role="warning"><name/> has @xml:lang="<value-of select="@xml:lang"/>", which is the same as the @xml:lang value on the article. It is unnecessary.</report>
        
        <report test="
            (preceding-sibling::kwd-group or following-sibling::kwd-group)
            and (count(kwd) gt 1)
            and kwd[@content-type]
            and (count(kwd) != count(kwd[@content-type]))" 
            role="warning"><name/> has sibling <name/>s, <value-of select="count(kwd)"/> kwds, but only <value-of select="count(kwd[@content-type])"/> kwd(s) with the attribute content-type. under these conditions each kwd should have an attribute content-type.</report>
    </rule>
    
    <rule context="compound-kwd">    
        
        <report test="count(compound-kwd-part) = 1" role="warning">There is only one  &lt;<name/>> in &lt;compound-kwd> - <value-of select="."/>.</report>
    </rule>
    
</pattern>
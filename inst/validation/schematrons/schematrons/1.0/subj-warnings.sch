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

<pattern id="subj-warnings" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="*[subj-group]">
        <let name="vanilla-subj-group-count" value="count(subj-group[not(@xml:lang) and not(@subj-group-type)])"/>
        
        <assert test="$vanilla-subj-group-count le 1" role="warning">There should not be two or more &lt;subj-group>s without a @subj-group-type or @xml:lang attribute. <name/> contains <value-of select="$vanilla-subj-group-count"/>.</assert>
    </rule>
    
    <rule context="subj-group">
        
        <report test="@xml:lang and (@xml:lang = ancestor::article/@xml:lang)" role="warning"><name/> has @xml:lang="<value-of select="@xml:lang"/>", which is the same as the @xml:lang value on the article. It is unnecessary.</report>
        
    </rule>
    
    <rule context="compound-subject">    
        
        <report test="count(compound-subject-part) = 1" role="warning">There is only one  &lt;<name/>-part> in &lt;<name/>> - <value-of select="."/>.</report>
        
    </rule>
    
</pattern>
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

<pattern id="general-citations-warnings" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="element-citation|mixed-citation">
        <report test="@publication-type='other'" role="warning">
            &lt;<name/>> has the attribute publication-type="other". Avoid using this value.
        </report>
        
        <assert test="person-group[@person-group-type]" role="warning">
            Where possible &lt;<name/>> should always have a child &lt;person-group> which hold the contributors for that work, with their role being specified in the attribute person-group-type. This &lt;<name/>> does not have a &lt;person-group person-group-type="...">.
        </assert>
    </rule>
    
    <rule context="name[ancestor::element-citation]|string-name[ancestor::mixed-citation]">
        
        <assert test="parent::person-group[@person-group-type]" role="warning">
            Where possible &lt;<name/>> should be captured in a parent &lt;person-group>, with their role being specified in the attribute person-group-type on that element. This &lt;<name/>> is a child of &lt;<value-of select="parent::*/local-name()"/>>.
        </assert>
        
    </rule>
    
</pattern>



<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2022 JATS4Reuse (https://jats4r.org)
    
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

<pattern id="abstract-warnings-1" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="abstract|trans-abstract">
        <let name="recommended-values" value="('teaser','extract','editor-summary','executive-summary','interpretive-summary','summary','plain-language-summary','graphical','simple','structured','video','audio')"/>
        <report test="(not(@abstract-type) or @abstract-type!='graphical') and descendant::fig[descendant::graphic]" role="warning"> 
            &lt;<value-of select="name()"/>> does not have the attribute abstract-type="graphical" but it has a descendant &lt;fig> with a graphic. 
        </report>
        
        <report test="@abstract-type and not(normalize-space(@abstract-type)=$recommended-values)" role="warning"> 
            abstract-type attribute value (<value-of select="@abstract-type"/>) on &lt;<value-of select="name()"/>> is not one of the recommended values (<value-of select="string-join($recommended-values,'; ')"/>). 
        </report>
    </rule>
    
</pattern>

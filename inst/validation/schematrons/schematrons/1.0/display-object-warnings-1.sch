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

<pattern id="display-object-warnings-1" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:j4r="http://jats4r.org/ns">

<!-- Need to extend for various other languages -->
    <rule context="fig[(not(label) or label[not(*) and normalize-space(.)='']) and caption]|fig-group[not(label) and caption]">
        <report test="matches(lower-case(caption[1]),'^\s*fig(ure)?\.?\s*\d|^\s*scheme\.?\s*\d|^\s*supplement(al|ary)?\.?\s*\d|^\s*supplement(al|ary)?\s*fig(ure)?\.?\s*\d')" role="warning">
            &lt;<name/>> has no non-empty label, but its caption begins with what looks like a label '<value-of select="substring(caption[1],1,10)"/>'. 
        </report>  
    </rule>
    
    <rule context="table-wrap[(not(label) or label[not(*) and normalize-space(.)='']) and caption]|table-wrap-group[not(label) and caption]">
        <report test="matches(lower-case(caption[1]),'^\s*table\.?\s*\d||^\s*supplement(al|ary)?\s*table\.?\s*\d')" role="warning">
            &lt;<name/>> has no non-empty label, but its caption begins with what looks like a label '<value-of select="substring(caption[1],1,10)"/>'. 
        </report>  
    </rule>
    
    <rule context="boxed-text[(not(label) or label[not(*) and normalize-space(.)='']) and caption]">
        <report test="matches(lower-case(caption[1]),'^\s*box\.?\s*\d')" role="warning">
            &lt;<name/>> has no non-empty label, but its caption begins with what looks like a label '<value-of select="substring(caption[1],1,10)"/>'. 
        </report>  
    </rule>

</pattern>

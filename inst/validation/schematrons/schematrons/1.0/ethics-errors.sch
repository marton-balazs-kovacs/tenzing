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

<pattern id="ethics-errors" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="sec[@sec-type='ethics-statement']//sec[@sec-type]">
        
        <report test="@sec-type='ethics-statement'" role="error">
            &lt;<name/> sec-type="ethics-statement"> appears more than once in the document.
        </report>
    </rule>
    
    <rule context="sec[@sec-type='ethics-statement']">
        
        <report test="preceding::sec[@sec-type='ethics-statement']" role="error">
            &lt;<name/> sec-type="ethics-statement"> appears more than once in the document.
        </report>
    </rule>
    
    <rule context="sec[@sec-type!='ethics-statement']">
        
        <!-- Simple implementation with scope for improvement - perhaps with Levenshtein distance, or something faster  -->
        <report test="lower-case(@sec-type) = 'ethics-statement'" role="error">
            Ethics sections must have a sec-type="ethics-statement". This one has '<value-of select="@sec-type"/>'.
        </report>
    </rule>
    
    <rule context="sec[@sec-type='ethics-statement']//p[@content-type]|sec[@sec-type='ethics-statement']//named-content[@content-type]">
        
        <report test="@content-type='ethics-statement'" role="error">
            Ethics related information on &lt;<name/>> must be specified with a content-type attribute, whose value is 'ethics-' followed by publisher values, but this one is 'ethics-statement'.
        </report>
    </rule>

</pattern>

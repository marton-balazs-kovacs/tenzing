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

<pattern id="display-object-warnings-2" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:j4r="http://jats4r.org/ns">

    <rule context="fig|fig-group[label or caption[title or p]]|table-wrap|table-wrap-group[label or caption[title or p]]|boxed-text|disp-formula-group[label or caption[title or p]]|chem-struct-wrap[label or caption[title or p]]">
        <assert test="@id" role="warning">
            &lt;<name/>> has no id attribute. 
        </assert>  
    </rule>

</pattern>

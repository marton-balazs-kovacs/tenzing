<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2024 JATS4Reuse (https://jats4r.org)
    
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

<pattern id="accessibility-warnings" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="graphic/alt-text">
        <report test="normalize-space(.)=normalize-space(ancestor::fig/caption/title)" role="warning">
            &lt;alt-text> should not be a duplication of the figure title.
        </report>

        <report test="normalize-space(.)=normalize-space(ancestor::fig/caption/p[1])" role="warning">
            &lt;alt-text> should not be a duplication of the figure caption.
        </report>

        <report test="normalize-space(.)=''" role="warning">
            Use value ‘null’ to indicate a decorative (non-substantive) image
        </report>
    </rule>

    <rule context="ext-link | uri | self-uri">
        <report test=".=@xlink:href or matches(.,'^https?://|^s?ftp://')" role="warning"> 
            A URI is not descriptive link text. The text of ext-link should describe the linked object.
        </report>
    </rule>

    <rule context="list-item">
        <report test="label" role="warning"> 
            Accessible @list-type overridden by list-item/label.
        </report>
    </rule>

</pattern>

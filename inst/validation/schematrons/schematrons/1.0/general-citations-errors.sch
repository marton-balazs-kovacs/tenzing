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

<pattern id="general-citations-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="element-citation|mixed-citation">
        <assert test="@publication-type" role="error">&lt;<name/>> does not have a publication-type attribute.</assert>
        
        <report test="elocation-id and (fpage or lpage or page-range)" role="error">
            Either &lt;elocation-id> or &lt;fpage> (and possibly &lt;lpage>) should be included in a reference. &lt;<name/>> has both &lt;elocation-id> as well as <value-of select="if (fpage and lpage) then 'both &lt;fpage> and &lt;lpage>' else concat('&lt;',*[name()=('fpage','lpage')],'>')"></value-of>
        </report>
        
        <report test="not(page-range) and lpage and (number(replace(fpage[1],'[^\d\.]','')) gt number(replace(lpage[1],'[^\d\.]','')))" role="error">
            &lt;lpage> must be larger than &lt;fpage>, if present.
        </report>
    </rule>
    
    <rule context="element-citation/year|mixed-citation/year">
        <report test="not(matches(.,'^[1][0-9][0-9][0-9]$|[2]0[0-2][0-9]$')) and not(matches(@iso-8601-date,'^[1][0-9][0-9][0-9]$|[2]0[0-2][0-9]$'))" role="error">&lt;year> which does not contain a 4 digit year must have an iso-8601-date attribute which does contain a 4 digit year.</report>
    </rule>
    
    <rule context="element-citation/pub-id|mixed-citation/pub-id">
        <assert test="@pub-id-type" role="error">&lt;year> which does not contain a 4 digit year must have an iso-8601-date attribute which does contain a 4 digit year.</assert>
    </rule>

</pattern>



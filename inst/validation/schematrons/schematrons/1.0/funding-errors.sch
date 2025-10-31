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

<pattern id="funding-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="article-meta | front-stub">
        <report test="count(descendant::funding-group) gt 1" role="error">
            There can only be 1 &lt;funding-group> within &lt;<value-of select="local-name()"/>>. This one has <value-of select="count(descendant::funding-group)"/>  
        </report>
        
    </rule>
    
    <rule context="award-group">
        <report test="count(funding-source) gt 1" role="error">
            More than one (<value-of select="count(funding-source)"/>) &lt;funding-source> found within &lt;award-group>. 
        </report>
        
        <assert test="funding-source or support-source" role="error">
            No &lt;funding-source> or &lt;support-source> found within &lt;award-group>. 
        </assert>
    </rule>
    
    <rule context="award-id[@award-id-type='doi']">
        <assert test="starts-with(.,'10')" role="error">
            The value of &lt;award-id award-id-type='doi'> starts with something other than "10", meaning that it is not a doi - <value-of select="."/>.
        </assert>
    </rule>    
    
    <rule context="funding-source">
        <assert test="count(institution-wrap) = 1" role="error">
            &lt;funding-source> contains <value-of select="count(institution-wrap)"/> &lt;institution-wrap> elements.
        </assert>
    </rule>
    
    <rule context="article[number(replace(@dtd-version,'[^\d\.]','')) ge 1.2]//funding-group//institution-id[@vocab='open-funder-registry']">
        <assert test="@vocab-identifier='10.13039/open_funder_registry'" role="error">
            &lt;institution vocab="open-funder-registry"> in JATS <value-of select="ancestor::article/@dtd-version"/> must have an @vocab-identifier="10.13039/open_funder_registry". 
        </assert>
        
        <assert test="@institution-id-type='doi'" role="error">
            &lt;institution vocab="open-funder-registry"> in JATS <value-of select="ancestor::article/@dtd-version"/> must have @institution-id-type="doi". 
        </assert>
        
        <assert test="starts-with(.,'10.13039/')" role="error">
            The value of &lt;institution vocab="open-funder-registry"> in JATS <value-of select="ancestor::article/@dtd-version"/> must start with '10.13039/'.
        </assert>
    </rule>
    
    <rule context="article[not(@dtd-version) or (number(replace(@dtd-version,'[^\d\.]','')) le 1.1)]//funding-group//institution-id[@institution-id-type='doi']">
        <assert test="starts-with(.,'10')" role="error">
            The value of &lt;institution institution-id-type="doi"> must start with "10", meaning that it has to be a doi. <value-of select="."/> does not.
        </assert>
    </rule>
    
    <rule context="funding-group//principal-award-recipient">
        <assert test="count(name) + count(string-name) + count(institution) + count(institution-wrap) = 1" role="error">
            Only 1 person or organisation is allowed in &lt;principal-award-recipient>. This one contains more than 1 name, string-name, institution, or institution-wrap.
        </assert>
    </rule>
    
</pattern>
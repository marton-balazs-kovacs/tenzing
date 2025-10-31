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

<pattern id="preprint-citations-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="element-citation[@publication-type='preprint']|mixed-citation[@publication-type='preprint']">
        <assert test="person-group" role="error">
            &lt;<name/> publication-type="preprint"> must include a &lt;person-group>.
        </assert>
        
        <assert test="article-title" role="error">
            &lt;<name/> publication-type="preprint"> must include an &lt;article-title>.
        </assert>
        
        <assert test="year or date[@date-type='published']" role="error">
            &lt;<name/> publication-type="preprint"> must include either a &lt;year> or a &lt;date>.
        </assert>
        
        <report test="year and date[@date-type='published']" role="error">
            &lt;<name/> publication-type="preprint"> must not include both a &lt;year> and a &lt;date>.
        </report>
        
        <assert test="source" role="error">
            &lt;<name/> publication-type="preprint"> must include a &lt;source>.
        </assert>
        
        <assert test="ext-link or pub-id" role="error">
            &lt;<name/> publication-type="preprint"> must include either an &lt;ext-link> or a &lt;pub-id>.
        </assert>
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/person-group|mixed-citation[@publication-type='preprint']/person-group">
        <assert test="@person-group-type" role="error">
            &lt;person-group> in &lt;<value-of select="parent::*/local-name()"/> publication-type="preprint"> must have the attribute person-group-type.
        </assert>
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/year|mixed-citation[@publication-type='preprint']/year">
        <report test="matches(.,'[^\d]') and not(matches(@iso-8601-date,'^\d{4}$'))" role="error">
            &lt;year> which is a direct child of &lt;<value-of select="parent::*/local-name()"/> publication-type="preprint"> must either be integer or have an @iso-8601-date with an iso-8601 date. <value-of select="if (@iso-8601-date and matches(.,'[^\d]')) then (concat('The @iso-8601-date, ',@iso-8601-date,' is not in the format 0000.')) else if (not(@iso-8601-date) and matches(.,'[^\d]')) then ('There is no @iso-8601-date and the &lt;year> element is not an integer.') else ()"/>
        </report>
    </rule>
    
    <rule context="element-citation[@publication-type='preprint']/date|mixed-citation[@publication-type='preprint']/date">
        <report test="matches(year[1],'[^\d]') and not(matches(@iso-8601-date,'^\d{4}$|^\d{4}-\d{2}$|^\d{4}-\d{2}-\d{2}$'))" role="error">
            &lt;date> in &lt;<value-of select="parent::*/local-name()"/> publication-type="preprint"> must either  have an @iso-8601-date with an iso-8601 date, or contain a &lt;year> whose contents are an integer. <value-of select="if (@iso-8601-date and matches(year[1],'[^\d]')) then (concat('The @iso-8601-date, ',@iso-8601-date,' is not in one of the formats 0000, 0000-00, or 0000-00-00.')) else if (not(@iso-8601-date) and matches(.,'[^\d]')) then concat('There is no @iso-8601-date and the &lt;year> element is not an integer. &lt;year>',child::year[1],'&lt;/year>') else ()"/>
        </report>
    </rule>
    
</pattern>
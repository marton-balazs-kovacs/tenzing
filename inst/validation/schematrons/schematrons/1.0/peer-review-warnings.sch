<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2021 JATS4Reuse (https://jats4r.org)
    
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

<pattern id="peer-review-warnings" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//contrib | sub-article[@article-type=$peer-review-types]/front-stub//contrib">
        
        <assert test="@contrib-type='author'" role="warning">
            &lt;contrib> for peer review material should have the attribute contrib-type="author".
        </assert>
        
    </rule>
    
    <rule context="sub-article[@article-type=$types-with-related-object]//front-stub">
        
        <assert test="related-object[@document-type=$peer-review-document-types]" role="warning">
            Peer review sub-articles with the article-type '<value-of select="ancestor::article/@article-type"/>' should contain a link to the article they pass judgement on, captured as a related-object element with the the appropriate document-type attribute value (one of: <value-of select="string-join(for $y in $peer-review-document-types return $y,', ')"/>).</assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta/pub-history/event[@event-type] | 
        sub-article[@article-type=$peer-review-types]/front-stub/pub-history/event[@event-type]">
        
        <assert test="@event-type = ('reviewer-report-received', 'author-comment-received', 'editor-decision-sent')" role="warning">
            The suggested (but not required) values for the event-type attribute are: reviewer-report-received, author-comment-received, or editor-decision-sent.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta/history/date | 
        sub-article[@article-type=$peer-review-types]/front-stub/history/date">
        <!-- if dtd number is less than 1.2 then return true -->
        <let name="isnt-jats-1.2" value="number(replace(ancestor::article/@dtd-version,'[^\d\.]','')) lt 1.2"/>
        
        <report test="$isnt-jats-1.2 and not(@date-type = ('reviewer-report-received', 'author-comment-received', 'editor-decision-sent'))" role="warning">
            The suggested (but not required) values for the date-type attribute are: reviewer-report-received, author-comment-received, or editor-decision-sent.
        </report>
        
    </rule>
    
    <rule context="article[@article-type=$types-with-related-object]//article-meta/related-object[@document-type=$peer-review-document-types]|
        sub-article[@article-type=$types-with-related-object]/front-stub/related-object[@document-type=$peer-review-document-types]">
        
        <report test="@source-id and not(@source-id-type)" role="warning">
            &lt;related-object> with a source-id attribute should have a source-id-type attribute with an appropriate value.
        </report>
        
    </rule>
    
</pattern>
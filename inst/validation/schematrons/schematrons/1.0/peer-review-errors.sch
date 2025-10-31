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

<pattern id="peer-review-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="article[not(@article-type=$peer-review-types)]|sub-article[not(@article-type=$peer-review-types)]">
        
        <report test="matches(lower-case(@article-type),$unallowed-type-regex)" role="error">
            The article-type value on &lt;<name/>> is <value-of select="@article-type"/>. The permitted values for peer review materials are 'reviewer-report', 'editor-report', 'author-comment', 'community-comment' or 'aggregated-review-documents'.
        </report>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta | sub-article[@article-type=$peer-review-types]/front-stub">
        <assert test="article-id[@pub-id-type='doi']" role="error">
            &lt;article-id pub-id-type="doi"> must be present in <name/>.
        </assert>
        
        <assert test="contrib-group/contrib" role="error">
            &lt;contrib> (within &lt;contrib-group>) is required.
        </assert>
        
        <assert test="title-group/article-title" role="error">
            Peer review material must have a title (&lt;article-title>).
        </assert>
        
        <report test="(name()='article-meta') and not(permissions)" role="error">
            Peer review articles must have permissions informaiton (&lt;permissions>).
        </report>
        
        <assert test="if (name()='article-meta') then (pub-date) else (ancestor::article//article-meta/pub-date or pub-date)" role="error">
            Peer review material must have a publication date (&lt;pub-date>).
        </assert>
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//contrib | sub-article[@article-type=$peer-review-types]/front-stub//contrib[not(ancestor::collab)]">
        
        <let name="contrib-roles" value="('reviewer', 'reader', 'author', 'editor')"/>
        
        <assert test="role[@specific-use=$contrib-roles]" role="error">
            &lt;contrib> for peer review material must have a child &lt;role>, which has a specific-use attribute with one of the following values: 'reviewer', 'reader', 'author', or 'editor'.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$types-with-related-object]//article-meta/related-object[@document-type=$peer-review-document-types]|
        sub-article[@article-type=$types-with-related-object]/front-stub/related-object[@document-type=$peer-review-document-types]">
        
        <assert test="@document-id-type='doi'" role="error">
            &lt;related-object> with the document-type '<value-of select="@document-type"/>' must have a document-id-type attribute with the value 'doi'.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta/pub-history/event | 
        sub-article[@article-type=$peer-review-types]/front-stub/pub-history/event">
        
        <assert test="count(date) = 1" role="error">
            &lt;event> must contain one and only one &lt;date>. This one has <value-of select="count(date)"/>.
        </assert>
        
        <assert test="@event-type" role="error">
            &lt;event> must contain and event-type attribute. The suggested values for this attribute are: reviewer-report-received, author-comment-received, or editor-decision-sent.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//custom-meta[meta-name='peer-review-stage'] | sub-article[@article-type=$peer-review-types]/front-stub//custom-meta[meta-name='peer-review-stage']">
        
        <assert test="meta-value = ('pre-publication','post-publication')" role="error">
            A &lt;custom-meta> with a &lt;meta-name> containing 'peer-review-stage', must have a &lt;meta-value> containing either 'pre-publication', or 'post-publication'. This one has '<value-of select="meta-value"/>'.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//custom-meta[meta-name='transfer'] | sub-article[@article-type=$peer-review-types]/front-stub//custom-meta[meta-name='transfer']">
        
        <assert test="meta-value = 'yes'" role="error">
            A &lt;custom-meta> with a &lt;meta-name> containing 'transfer', must have a &lt;meta-value> containing 'yes'. This one has '<value-of select="meta-value"/>'.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//custom-meta[meta-name='peer-review-revision-round'] | sub-article[@article-type=$peer-review-types]/front-stub//custom-meta[meta-name='peer-review-revision-round']">
        
        <assert test="matches(meta-value,'^\d+$')" role="error">
            A &lt;custom-meta> with a &lt;meta-name> containing 'peer-review-revision-round', must have a &lt;meta-value> containing a numerical value represented with digits. This one has '<value-of select="meta-value"/>'.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//custom-meta[meta-name='peer-review-recommendation'] | sub-article[@article-type=$peer-review-types]/front-stub//custom-meta[meta-name='peer-review-recommendation']">
        
        <assert test="meta-value = ('revision', 'major-revision', 'minor-revision', 'reject', 'reject-with-resubmit', 'accept', 'formal-accept', 'accept-in-principle')" role="error">
            A &lt;custom-meta> with a &lt;meta-name> containing 'peer-review-recommendation', must have a &lt;meta-value> containing one of the following values: 'revision', 'major-revision', 'minor-revision', 'reject', 'reject-with-resubmit', 'accept', 'formal-accept' or 'accept-in-principle'. This one has '<value-of select="meta-value"/>'.
        </assert>
        
    </rule>
    
    <rule context="article[@article-type=$peer-review-types]//article-meta//custom-meta[meta-name='peer-review-identity-transparency'] | sub-article[@article-type=$peer-review-types]/front-stub//custom-meta[meta-name='peer-review-identity-transparency']">
        
        <assert test="meta-value = ('all-identities-visible', 'single-anonymized', 'double-anonymized', 'triple-anonymized')" role="error">
            A &lt;custom-meta> with a &lt;meta-name> containing 'peer-review-identity-transparency', must have a &lt;meta-value> containing one of the following values: 'all-identities-visible', 'single-anonymized', 'double-anonymized' or 'triple-anonymized'. This one has '<value-of select="meta-value"/>'.
        </assert>
        
    </rule>
    
</pattern>
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

<pattern id="accessibility-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="graphic">
        <assert test="alt-text" role="error"> 
            All &lt;graphic> must have &lt;alt-text>. This one does not.
        </assert>

        <report test="long-desc and (parent::*/long-desc or parent::alternatives/parent::*/long-desc)" role="error"> 
            &lt;graphic> has a child &lt;long-desc>, but its ancestor <value-of select="if (parent::alternatives) then parent::alternatives/parent::*/name() else parent::*/name()"/> also has a child &lt;long-desc>. &lt;long-desc> should be for the entire object or for each included image, not both places.
        </report>
    </rule>

    <rule context="oasis:table">
        <report test="." role="error"> 
            OASIS (CALS) tables are not recommended for accessibility and should not be used. Tag all tables using the XHTML-based JATS model instead.
        </report>
    </rule>

    <rule context="table-wrap">
        <assert test="table or alternatives/table" role="error"> 
            &lt;table> element not found inside &lt;table-wrap>. The &lt;table> element is required inside &lt;table-wrap> for data table accessibility.
        </assert>
    </rule>

    <rule context="table">
        <assert test="descendant::th" role="error"> 
            &lt;th> element not found within &lt;table>. Headers must be included in &lt;th> tags for data table accessibility.
        </assert>
    </rule>

    <rule context="ext-link | uri | self-uri">
        <report test="((not(*) and normalize-space(.)='') or (.=@xlink:href) or matches(.,'^https?://|^s?ftp://')) and not(@xlink:title)" role="error"> 
            Text that describes the linked object must be provided for each link either in the element content or in @xlink:title.
        </report>
    </rule>

    <rule context="sec">
        <assert test="title" role="error"> 
            Each sec element must have a title.
        </assert>

        <report test="@disp-level" role="error"> 
            Document structure should be defined by the position of the sections, not by the @disp-level attribute.
        </report>
    </rule>

    <rule context="private-char">
        <report test="." role="error"> 
            Do not use &lt;private-char> or use graphics for special characters.
        </report>
    </rule>

    <rule context="disp-formula | inline-formula">
        <report test="graphic or alternatives[count(*)=1 and graphic]" role="error"> 
            Do not use &lt;graphic> to represent mathematical notation
        </report>
    </rule>

    <rule context="custom-meta-group[@content-type='accessibility-metadata']">
        <assert test="parent::processing-meta" role="error"> 
            Accessibility Metadata should be in a &lt;custom-meta-group> in &lt;processing-meta>.
        </assert>
    </rule>

    <rule context="processing-meta/custom-meta-group[@content-type='accessibility-metadata']/custom-meta">
        <let name="meta-name-values" value="('accessibilityFeature','accessibilityHazard','accessibilityStatement')"/>
        <assert test="meta-name[.=$meta-name-values]" role="error"> 
           Accessibility Metadata entries must have a &lt;meta-name> value of ‘accessibilityFeature’, ‘accessibilityHazard’, or ‘accessibilityStatement’.
        </assert>

        <assert test="@vocab='schema.org'" role="error"> 
           Accessibility Metadata entries should use the schema.org vocabulary.
        </assert>
    </rule>

    <rule context="alternatives/textual-form">
        <report test="ancestor::disp-formula or ancestor::inline-formula" role="error"> 
            Do not use &lt;textual-form> for math. Use MathML tagging.
        </report>

        <report test="ancestor::fig or ancestor::fig-group" role="error"> 
            Do not use &lt;textual-form> for figures. Use &lt;alt-text>, &lt;long-desc>, or supply a transcript for audio or  video material.
        </report>
    </rule>
    
</pattern>

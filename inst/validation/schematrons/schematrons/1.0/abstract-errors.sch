<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2022 JATS4Reuse (https://jats4r.org)
    
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

<pattern id="abstract-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="article-meta">
        <report test="count(abstract[not(@abstract-type or @xml:lang or @specific-use)]) gt 1" role="error"> 
            If there are multiple abstracts then each abstract, other than the main abstract, must have at least one of the following attributes: abstract-type, xml:lang, or specific-use.
        </report>
    </rule>
    
    <rule context="abstract|trans-abstract">
        <report test="not(p) and count(sec)=1" role="error"> 
            &lt;<value-of select="name()"/>> has no child &lt;p> elements, but it has only 1 &lt;sec> element.
        </report>
        
        <report test="@abstract-type='graphical' and not(descendant::fig[descendant::graphic])" role="error"> 
            &lt;<value-of select="name()"/> abstract-type="graphical"> has no descendant &lt;fig> elements.
        </report>
        
        <report test="(not(@abstract-type) or not(@abstract-type=('video','audio'))) and descendant::media" role="error"> 
            &lt;<value-of select="name()"/>> has descendant &lt;media> element(s), but it does not have an abstract-type attribute with a value of either "video" or "audio".
        </report>
        
        <report test="@abstract-type='video' and not(descendant::fig[descendant::media[@mimetype='video']])" role="error"> 
            &lt;<value-of select="name()"/> abstract-type="video"> has no descendant &lt;fig> elements containing &lt;media mimetype="video">.
        </report>
        
        <report test="@abstract-type='audio' and not(descendant::fig[descendant::media[@mimetype='audio']])" role="error"> 
            &lt;<value-of select="name()"/> abstract-type="audio"> has no descendant &lt;fig> elements containing &lt;media mimetype="audio">.
        </report>
        
        <report test="name()='trans-abstract' and not(@xml:lang)" role="error">
            Missing xml:lang attribute. &lt;trans-abstract> must have an xml:lang attribute, whose value indicates the language. This one does not.
        </report>
    </rule>
    
    <rule context="abstract//sec">
        <assert test="title" role="error">
            Missing &lt;title>. Every &lt;sec> within &lt;abstract> must have a &lt;title>, this one does not.
        </assert>
    </rule>
    
    <rule context="graphic[ancestor::abstract or ancestor::trans-abstract]">
        <assert test="parent::fig or parent::alternatives/parent::fig" role="error">
            &lt;graphic> within &lt;abstract> must be a child of &lt;fig> or a child of &lt;alternatives>, which in turn is a child of &lt;fig>. This one is not.
        </assert>
    </rule>
    
    <rule context="media[ancestor::abstract or ancestor::trans-abstract]">
        <assert test="parent::fig or parent::alternatives/parent::fig" role="error">
            &lt;media> within &lt;abstract> must be a child of &lt;fig> or a child of &lt;alternatives>, which in turn is a child of &lt;fig>. This one is not.
        </assert>
    </rule>
    
</pattern>

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

<pattern id="credit-warnings" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="article[not(@dtd-version) or (number(replace(@dtd-version,'[^\d\.]','')) ge 1.2)]//role[not(@*/name()=('vocab','vocab-identifier','vocab-term','vocab-term-identifier')) and parent::*/local-name()=('contrib','collab','contrib-group')]">
        <let name="credit-roles" value="document('credit-roles.xml')"/>
        <!-- Normalize text so that slight differences (e.g. hyphen instead of em dash) do not fail matching.
             Levenshtein distance could be used but that would be more resource intensive.    -->
        <let name="normalized-text" value="replace(replace(lower-case(.),'[—–-]','–'),'\s','')"/>
        
        <report test="some $item in $credit-roles//*:item satisfies $item/@normalized-term = $normalized-text" role="warning">
            A CRediT taxonomy role should have the attributes vocab="credit" and vocab-identifier="https://credit.niso.org/", as well as the following attributes which correspond to a specific CRediT taxonomy term: vocab-term (whose value should possibly be '<value-of select="$credit-roles//*:item[@normalized-term = $normalized-text]/@term"/>'), and vocab-term-identifier (whose value should possibly be '<value-of select="$credit-roles//*:item[@normalized-term = $normalized-text]/@uri"/>').
        </report>
    </rule>
    
    <rule context="article[not(@dtd-version) or (number(replace(@dtd-version,'[^\d\.]','')) le 1.1)]//role[not(@content-type) and parent::*/local-name()=('contrib','collab','contrib-group')]">
        <let name="credit-roles" value="document('credit-roles.xml')"/>
        <!-- Normalize text so that slight differences (e.g. hyphen instead of em dash) do not fail matching.
             Levenshtein distance could be used but that would be more resource intensive.    -->
        <let name="normalized-text" value="replace(replace(lower-case(.),'[—–-]','–'),'\s','')"/>
        
        <report test="some $item in $credit-roles//*:item satisfies $item/@normalized-term = $normalized-text" role="warning">
            A CRediT taxonomy role should have a @content-type, whose value should be one of the specific CRediT term URLs. Based on the content of this element (<value-of select="."/>), it should have a content-type="<value-of select="$credit-roles//*:item[@normalized-term = $normalized-text]/@uri"/>" attribute.
        </report>
    </rule>
    
</pattern>
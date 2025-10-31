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

<pattern id="credit-errors" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="article[number(replace(@dtd-version,'[^\d\.]','')) ge 1.2]//role[@vocab='credit' and parent::*/local-name()=('contrib','collab','contrib-group')]">
        <let name="credit-roles" value="document('credit-roles.xml')"/>
        <let name="vocab-term" value="@vocab-term"/>
        <let name="vocab-term-id" value="lower-case(@vocab-term-identifier)"/>
        <let name="credit-role" value="$credit-roles//*:item[(@term = $vocab-term) or (@uri = $vocab-term-id)]"/>
        
        <assert test="@vocab-identifier='https://credit.niso.org/'" role="error">
            A CRediT taxonomy role must have a @vocab-identifier whose value is https://credit.niso.org/.
        </assert>
        
        <report test="not(@vocab-term-identifier) or ((count($credit-role) = 1) and ($vocab-term-id != $credit-role/@uri))" role="error">
            A CRediT taxonomy role must have a @vocab-term-identifier, the value of which must be the URL of the specific CRediT term. <value-of select="if (empty($credit-role)) then concat('It must be one of these - ',string-join($credit-roles//*:item/@uri,', ')) 
                else concat('In this case ',$credit-role/@uri,' (based on the @vocab-term of this role element)')"/>.
        </report>
        
        <report test="not(@vocab-term) or ((count($credit-role) = 1) and ($vocab-term != $credit-role/@term))" role="error">
            A CRediT taxonomy role must have a @vocab-term, the value of which must be one of the CRediT terms - <value-of select="if (empty($credit-role)) then string-join($credit-roles//*:item/@term,', ') 
                else concat(' in this case ',$credit-role/@term,' (based on the @vocab-term-identifer of of this role element)')"/>.
        </report>
        
        <report test="count($credit-role) gt 1" role="error">
            A CRediT taxonomy role must have a @vocab-term, whose value is a specific CRediT taxonomy term, and a @vocab-term-identifier, whose value is the URL for that corresponding CRediT term. <value-of select="concat('Either the @vocab-term - ', $vocab-term, ' - is incorrect and must be ', $credit-role[@uri=$vocab-term-id]/@term, ', or the @vocab-term-identifier - ', $vocab-term-id,' - is incorrect and must be ', $credit-role[@term=$vocab-term]/@uri)"/>.
        </report>
        
    </rule>
    
    <rule context="article[number(replace(@dtd-version,'[^\d\.]','')) ge 1.2]//role[not(@vocab='credit') and (parent::*/local-name()=('contrib','collab','contrib-group')) and (@vocab-term or @vocab-term-identifier)]">
        <let name="credit-roles" value="document('credit-roles.xml')"/>
        <let name="vocab-term" value="@vocab-term"/>
        <let name="vocab-term-id" value="lower-case(@vocab-term-identifier)"/>
        
        <report test="some $x in $credit-roles//*:item satisfies ($x/@uri=$vocab-term-id) or ($x/@term=$vocab-term)" role="error">
            A CRediT taxonomy role must have a @vocab whose value is 'credit'.
        </report>
        
    </rule>
    
    <rule context="article[not(@dtd-version) or (number(replace(@dtd-version,'[^\d\.]','')) le 1.1)]//role[contains(@content-type,'credit.niso.org') and parent::*/local-name()=('contrib','collab','contrib-group')]">
        <let name="credit-roles" value="document('credit-roles.xml')"/>
        <let name="type" value="lower-case(@content-type)"/>
        
        <assert test="some $item in $credit-roles//*:item satisfies $item/@uri = $type" role="error">
            A CRediT taxonomy role must have a @content-type, whose value must be one of the specific CRediT term URLs. <value-of select="@content-type"/> is not one of <value-of select="string-join($credit-roles//*:item/@uri,', ')"/>.
        </assert>
    </rule>
    
</pattern>
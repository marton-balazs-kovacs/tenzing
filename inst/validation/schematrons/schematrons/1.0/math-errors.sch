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

<pattern id="math-errors" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">

  <rule context="mml:math | tex-math">
    <!--
      All mathematical expressions must be enclosed in an <inline-formula> element (for 
      expressions within the flow of text) or a <disp-formula> element (for display equations).
   -->
    <assert test="parent::disp-formula or parent::inline-formula or parent::alternatives[parent::disp-formula or parent::inline-formula]" role="error"> 
      Math expressions must be in &lt;disp-formula&gt; or &lt;inline-formula&gt; elements. They must not appear directly
      in &lt;<value-of select="name(parent::node())"/>&gt;. 
    </assert>
  </rule>

  <rule context="disp-formula | inline-formula">
    <assert test="
        count(child::graphic) + count(child::tex-math) +
        count(child::mml:math) &lt; 2" role="error"> 
      Formula element must contain only one expression. If these are alternate
      representations of the same expression, use &lt;alternatives&gt;. If they are different
      expressions, tag each in its own &lt;<value-of select="name()"/>&gt;. 
    </assert>
  </rule>

  <rule context="disp-formula/alternatives | inline-formula/alternatives">
    <assert test="
        count(child::graphic) + count(child::inline-graphic) &lt;= 1 and
        count(child::tex-math) &lt;= 1 and
        count(child::mml:math) &lt;= 1" role="error"> 
      For alternate representations of the same expression, there can be at most one of
      each type of representation (graphic or inline-graphic, tex-math, and mml:math). 
    </assert>
  </rule>

</pattern>

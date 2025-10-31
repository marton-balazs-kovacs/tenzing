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
<pattern id="math-warnings" 
         xmlns="http://purl.oclc.org/dsdl/schematron"
         xmlns:j4r="http://jats4r.org/ns">

  <rule context="disp-formula | inline-formula">
    <!--
      The use of images to represent mathematical expressions is strongly discouraged. Math 
      should be marked up within <inline-formula> and <disp-formula> using either <tex-math> 
      or <mml:math>.
    -->
    <report test="(graphic or inline-graphic) and not(mml:math or tex-math)" role="warning"> 
      All mathematical expressions should be provided in markup using either &lt;mml:math&gt; or
      &lt;tex-math&gt;. The only instance in which the graphic representation of a mathematical
      expression should be used outside of &lt;alternatives> and without the equivalent markup is
      where that expression is so complicated that it cannot be represented in markup at all.
    </report>
  </rule>
</pattern>

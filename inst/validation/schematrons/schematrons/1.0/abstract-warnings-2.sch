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

<pattern id="abstract-warnings-2" 
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:j4r="http://jats4r.org/ns">
    
    <rule context="abstract[@xml:lang]">
        <let name="iso-639-3-sl" value="('ads','aed','aen','afg','ajs','ase','asp','asq','asw','bfi','bfk','bog','bqn','bqy','bvl','bzs','cds','csc','csd','cse','csf','csg','csl','csn','csq','csr','csx','doq','dse','dsl','dsz','ecs','ehs','esl','esn','eso','eth','fcs','fse','fsl','fss','gds','gse','gsg','gsm','gss','gus','hab','haf','hds','hks','hos','hps','hsh','hsl','icl','iks','inl','ins','ise','isg','isr','jcs','jhs','jks','jls','jos','jsl','jus','kgi','kvk','lbs','lls','lsb','lsc','lsl','lsn','lso','lsp','lst','lsv','lsw','lsy','lws','mdl','mfs','mre','msd','msr','mzc','mzg','mzy','nbs','ncs','nsi','nsl','nsp','nsr','nzs','okl','pgz','pks','prl','prz','psc','psd','psg','psl','pso','psp','psr','pys','rib','rms','rnb','rsl','rsm','rsn','sdl','sfs','sgg','sgx','slf','sls','sqk','sqs','sqx','ssp','ssr','svk','swl','syy','szs','tse','tsm','tsq','tss','tsy','tza','ugn','ugy','ukl','uks','vsi','vsl','vsv','wbs','xki','xml','xms','ygs','yhs','ysl','ysm','zib','zsl')"/>
        
        <report test="@xml:lang=$iso-639-3-sl" role="warning"> 
            &lt;abstract> has an xml:lang attribute with a value for one of the ISO-639 sign languages ("<value-of select="@xml:lang"/>"). Where a video depicts sign language which is a direct translation of the main abstract, &lt;trans-abstract abstract-type="video"> should be used with the correct (same) xml:lang attribute.
        </report>
    </rule>
    
</pattern>

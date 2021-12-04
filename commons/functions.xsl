<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.loc.gov/mods/v3"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:f="http://functions"
    exclude-result-prefixes="xs xd f" version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 28, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> rdonahue</xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>Function: </xd:b>f:monthNumFromName</xd:p>
            <xd:p><xd:b>Usage: </xd:b>f:monthNumFtworomName(string)</xd:p>
            <xd:p><xd:b>Purpose: </xd:b>Pull the -digit equivalent of a month name for a given date
                string. e.g. "June 28, 2017" will return "06." The name of the month
                <xd:i>must</xd:i> be at the start of the string. "28 June 2017" will return NaN.
                This function is not case sensitive.</xd:p>
            <xd:p>Originally from <xd:a>https://stackoverflow.com/a/37454157</xd:a></xd:p>
        </xd:desc>
        <xd:param name="month-name">string which starts with the month name</xd:param>
    </xd:doc>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="month-name"/>
    </xd:doc>
    <xsl:function name="f:monthNumFromName" as="xs:string" xmlns:functx="http://functions">
        <xsl:param name="month-name" as="xs:string"/>
        <xsl:variable name="months" as="xs:string*"
            select="'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'"/>
        <xsl:sequence
            select="format-number(index-of($months, lower-case(substring($month-name, 1, 3))), '00')"
        />
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>Function: </xd:b>f:calculateTotalPages</xd:p>
            <xd:p><xd:b>Usage: </xd:b>f:calculateTotalPages([xpath/value for first page],
                [xpath/value for last page])</xd:p>
            <xd:p><xd:b>Purpose: </xd:b>Calculate the total page count if the first and last pages
                are present and are integers</xd:p>
        </xd:desc>
        <xd:param name="fpage">value or XPath for the first page</xd:param>
        <xd:param name="lpage">value or XPath for the last page</xd:param>
    </xd:doc>
    <xsl:function name="f:calculateTotalPgs">
        <xsl:param name="fpage"/>
        <xsl:param name="lpage"/>
        <xsl:if test="(string(number($fpage)) != 'NaN' and string(number($lpage)) != 'NaN')">
            <total>
                <xsl:value-of select="if (number($lpage) - number($fpage) = 0)
                                      then +1     
                                      else (number($lpage) - number($fpage) +1 )"/>
            </total>
        </xsl:if>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>Function: </xd:b>f:checkMonthType</xd:p>
            <xd:p><xd:b>Usage: </xd:b>f:checkMonthType(XPath)</xd:p>
            <xd:p><xd:b>Purpose: </xd:b>If no month provided, return nothing. If month provided,
                check if represented as an integer or string. If integer, pad with zeroes to 2
                digits; if string, run <xd:i>f:monthNumFromName</xd:i></xd:p>
        </xd:desc>
        <xd:param name="testValue"/>
    </xd:doc>
    <xsl:function name="f:checkMonthType">
        <xsl:param name="testValue"/>
        <xsl:choose>
            <xsl:when test="(string($testValue)) and (not(string-length($testValue) > 2))">
                <xsl:value-of select="format-number($testValue, '00')"/>
            </xsl:when>
            <xsl:when test="string-length($testValue) > 2">
                <xsl:value-of select="f:monthNumFromName($testValue)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
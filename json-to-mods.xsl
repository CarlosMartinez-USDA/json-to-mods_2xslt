<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns="http://www.loc.gov/mods/v3"
    xmlns:f="http://functions"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:local="http://local_functions"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" 
    xmlns:saxon="http://saxon.sf.net/"
   
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.com/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:usfs=" http://usfs_treesearch"
    exclude-result-prefixes="f fn local math mods saxon usfs xd xlink xs xsi">

    <!--output-->
    <xsl:output method="json" indent="yes" encoding="UTF-8"  omit-xml-declaration="yes" name="archive"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="fix_characters.xsl"/><!-- name="original"/>--> 

    <!--includes-->
    <xsl:include href="commons/common.xsl"/>
    <xsl:include href="commons/functions.xsl"/>
    <xsl:include href="commons/usfs_naming_functions.xsl"/>
    <xsl:include href="commons/params-cm.xsl"/>
    <xsl:include href="commons/predefined.xsl"/>

    <!--white space control-->
    <xsl:strip-space elements="*"/>


    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> September 21, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b>Carlos Martinez</xd:p>
            <xd:p><xd:b>Edited by:</xd:b>Carlos Martinez </xd:p>
            <xd:p><xd:b>Last Edited on:</xd:b>November 8, 2021</xd:p>
            <xd:p><xd:b>Purpose:</xd:b>This stylesheet transforms Treesearch metadata in JSON to XML
                then maps the transformed map, into MODS 3.7</xd:p>
        </xd:desc>
    </xd:doc>


    <!--Root template for local testing
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:b>Root template for local testing</xd:b>
            </xd:p>
            <xd:ul>
                <xd:p>This stylesheet may be run without pre-setting any parameters.</xd:p>
                <xd:li>
                    <xd:p><xd:b>Step 1:</xd:b>Choose the JSON file you wish to transform.</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:b>Step 2:</xd:b> Apply the transformation scenario or select a
                        debugging button to begin.</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:b>Step 3:</xd:b>Comment out this template or remove entirely before
                        putting into production.</xd:p>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template match="data">
        <data>
            <xsl:result-document method="xml" omit-xml-declaration="yes"
                href="{$working_dir}A-{$original_filename}_{position()}.json" format="archive">
                <xsl:value-of disable-output-escaping="yes" select="."/>
            </xsl:result-document>
        </data>
        <xsl:result-document method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"
            format="original" href="{$working_dir}N-{$original_filename}_{position()}.xml">
            <mods version="3.7">
                <xsl:attribute name="{'xmlns'}">http://www.loc.gov/mods/v3</xsl:attribute>
                <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
                <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                <xsl:attribute name="xsi:schemaLocation"
                    select="normalize-space('http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd')"/>
                <xsl:apply-templates select="json-to-xml(.)"/>
            </mods>
        </xsl:result-document>
    </xsl:template>-->


    <!----><xd:doc>
        <xd:desc>
            <xd:p><xd:b>For Development and Production</xd:b>uncommment this template when testing
                on the server or putting into production</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="data">
        <data>
            <xsl:result-document omit-xml-declaration="yes" indent="yes" encoding="UTF-8"
                method="json"
                href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml|\.json)','$2')}_{position()}.json"
                format="archive">
                <xsl:value-of select="."/>
            </xsl:result-document>
        </data>
        <xsl:result-document indent="yes" encoding="UTF-8" method="xml" 
            href="file:///{$workingDir}N-{replace($originalFilename, '(.*/)(.*)(\.xml|\.json)','$2')}_{position()}.xml">
        <mods version="3.7">
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation" select="normalize-space('http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd')"/>
            <xsl:apply-templates select="json-to-xml(.)"/>
        </mods>
        </xsl:result-document>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:b>The Mapping Template</xd:b>
            </xd:p>
            <xd:p>After the JSON file is converted into XML via the json-to-xml() function,</xd:p>
            <xd:p>This template matches and maps the string key values to MODS elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="map" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">

        <!-- titleInfo/title -->
        <xsl:apply-templates select="./string[@key = 'title']"/>

        <!-- name/namePart-->
        <xsl:apply-templates select="./array[@key = 'pub_authors'] | ./array[@key = 'primary_station']"/>

        <!--default values for typeOfResource and genre-->
        <typeOfResource>text</typeOfResource>
        <genre>article</genre>

        <!--originInfo/dateIssued-->
        <xsl:call-template name="dateIssued"/>
        
        <!-- note-->
        <xsl:apply-templates select="./string[@key = 'status_name']"/>

        <!-- default for language/languageTerm -->
        <language>
            <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
            <languageTerm type="text">English</languageTerm>
        </language>

        <!--abstract-->
        <xsl:apply-templates select="./string[@key = 'abstract']"/>

        <!--subject/topic-->
        <xsl:call-template name="keywords"/>

        <!--relatedItem-->
        <xsl:call-template name="relatedItem"/>

        <!--identifiers-->
        <xsl:call-template name="identifiers"/>

        <!-- default values for accessCondition -->
        <accessCondition type="use and reproduction" displayLabel="Resource is Open Access">
            <program xmlns="https://data.crossref.org/schemas/AccessIndicators.xsd">
                <license_ref>
                    <xsl:text>http://purl.org/eprint/accessRights/OpenAccess</xsl:text>
                </license_ref>
            </program>
        </accessCondition>

        <!--extension-->
        <xsl:call-template name="extension"/>
    </xsl:template>


    <!-- titleInfo/title -->
    <xd:doc scope="component" id="main_title">
        <xd:desc>
            <xd:p>
                <xd:b>JSON to MODS title/titleInfo transformation</xd:b>
            </xd:p>
            <xd:p><xd:b>output:</xd:b>A string value containing the main title of an article.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="map/string[@key = 'title']" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <titleInfo>
            <title>
                <xsl:value-of select="."/>
            </title>
        </titleInfo>
    </xsl:template>

    <!--corporate/author-->
    <xd:doc scope="component" id="pub_authors">
        <xd:desc>
            <xd:p>If the contributor is a collaborator rather than an individual, format output
                accordingly. If processing the first author in the group, assign an attribute
                of</xd:p>
            <xd:p><xd:b>usage</xd:b> with a value of "primary."</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="map/array[@key = 'pub_authors'] | map/array[@key = 'primary_station']" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:choose>
            <xsl:when test="count(map/string[@key = 'name']) = 0">
                <!-- corporate body -->
                <name type="corporate">
                    <namePart>
                        <xsl:text>United States Department of Agriculture, Forest Service, </xsl:text>
                        <xsl:value-of
                            select="local:acronymToName(./array[@key = 'primary_station'])"/>
                        <xsl:value-of
                            select="local:acronymToAddress(./array[@key = 'primary_station'])"/>
                    </namePart>
                </name>
            </xsl:when>
            <xsl:otherwise>
                <!-- name -->
                <xsl:for-each select="map[position()]">
                    <name type="personal">
                        <xsl:if
                            test="position() = 1 and count(map/preceding-sibling::string[@key = 'name']) = 0">
                            <xsl:attribute name="usage">primary</xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="name-info"/>
                    </name>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xd:doc scope="component" id="name-info">
        <xd:desc>
            <xd:p>'pub_authors' array contains the key values for author name's and uses numbers and
                acronyms to provide affiliation information</xd:p>
            <xd:p>An author's given and family name are parsed from the JSON
                map/array/map/string[@key='name'] string key value</xd:p>
            <xd:p>displayName matches on the 'name' string key value.</xd:p>
            <xd:p>affiliation uses two external stylesheets to match abbreviated station and unit
                numbers and names with their respective whole name and address</xd:p>
            <xd:p>roleTerm is hardcoded to "author"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="name-info" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <!-- namePart -->
        <xsl:if test="./string[@key = 'name']">
            <namePart type="given">
                <xsl:value-of
                    select="substring-after(normalize-space(./string[@key = 'name']), ', ')"/>
            </namePart>
            <namePart type="family">
                <xsl:value-of
                    select="substring-before(normalize-space(./string[@key = 'name']), ', ')"/>
            </namePart>
            <displayForm>
                <xsl:value-of select="./string[@key = 'name']"/>
            </displayForm>
        </xsl:if>
        <!--affiliation-->
        <xsl:if test="./string[@key = 'station_id'] != ''">
            <affiliation>
                <xsl:text>United States Department of Agriculture, Forest Service, </xsl:text>
                <xsl:value-of select="local:acronymToName(./string[@key = 'station_id'])"/>
                <xsl:text>, </xsl:text>
                <xsl:choose>
                    <xsl:when test="number(./string[@key = 'unit_id']) castable as xs:integer">
                        <xsl:value-of select="local:unitNumberToName(./string[@key = 'unit_id'])"/>
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:when test="string(./string[@key = 'unit_id'] != '')">
                        <xsl:value-of select="local:unitAcronymToName(./string[@key = 'unit_id'])"/>
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                </xsl:choose>
                <!-- <xsl:when test="number(./string[@key = 'unit_id']) castable as xs:integer">
                            <xsl:value-of select="local:unitNumberToAddress(./string[@key = 'unit_id'])"/>
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                            <xsl:when test="string(./string[@key = 'unit_id'] != '')">
                                <xsl:value-of select="local:unitAcronymToAddress(./string[@key = 'unit_id'])"/>
                                <xsl:text>, </xsl:text>
                            </xsl:when>-->
                <xsl:value-of select="local:acronymToAddress(./string[@key = 'station_id'])"/>
            </affiliation>
        </xsl:if>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>

    <!-- dateIssued -->
    <xd:doc scope="component" id="date_issued">
        <xd:desc>
            <xd:p>Chooses dateIssued mods element from one of three dates</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="dateIssued" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:choose>
            <xsl:when test="./string[@key = 'modified_on'] and (. != 'null') or (. != '')">
                <xsl:apply-templates select="./string[@key = 'modified_on']" mode="origin"/>
            </xsl:when>
            <xsl:when test="./string[@key = 'created_on'] and (./string[@key = 'modified_on'] = 'null') or (./string[@key = 'modified_on'] = '')">
                <xsl:apply-templates select="./string[@key = 'created_on']" mode="origin"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Chooses originInfo mods element from one of three dates</xd:p>
        </xd:desc>
        <xd:param name="input"/>
    </xd:doc>
    <xsl:template match="map/string[@key = 'modified_on'] | map/string[@key = 'created_on']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions" mode="origin">
        <xsl:param name="input" select="."/>
        <originInfo> 
            <xsl:choose>
                <xsl:when test="map/string[@key = 'modified_on'] and (. != 'null') or (. != '')">
                    <dateIssued encoding="w3cdtf" keyDate="yes">
                        <!-- Define array of months -->
                        <xsl:variable name="months" select="('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC')"/>
                        <!-- Define regex to match input date format -->
                        <xsl:analyze-string select="$input" regex="^([0-9]{{1,2}})\-([A-Z]{{3}})\-([0-9]{{4}})(.*)$">
                            <xsl:matching-substring>
                                <xsl:number value="regex-group(3)" format="0001"/>
                                <xsl:text>-</xsl:text>
                                <xsl:number value="index-of($months, regex-group(2))" format="01"/>
                                <xsl:text>-</xsl:text>
                                <xsl:number value="regex-group(1)" format="01"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </dateIssued>
                </xsl:when>
                <xsl:when test="map/string[@key = 'created_on'] and (. != 'null') or (. != '')">
                    <dateCreated encoding="w3cdtf">
                        <!-- Define array of months -->
                        <xsl:variable name="months"
                            select="('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC')"/>
                        <!-- Define regex to match input date format -->
                        <xsl:analyze-string select="$input" regex="^([0-9]{{1,2}})\-([A-Z]{{3}})\-([0-9]{{4}})(.*)$">
                            <xsl:matching-substring>
                                <xsl:number value="regex-group(3)" format="0001"/>
                                <xsl:text>-</xsl:text>
                                <xsl:number value="index-of($months, regex-group(2))" format="01"/>
                                <xsl:text>-</xsl:text>
                                <xsl:number value="regex-group(1)" format="01"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </dateCreated>
                </xsl:when>
                <xsl:otherwise>
                    <originInfo>
                        <dateOther encoding="w3cdtf">
                            <xsl:value-of select="normalize-space(/map/string[@key = 'product_year'])"/>
                            <xsl:text>-01-01</xsl:text>
                        </dateOther>
                    </originInfo>
                </xsl:otherwise>
            </xsl:choose>
        </originInfo>
    </xsl:template>

    <!-- abstract -->
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="map/string[@key = 'abstract']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <abstract>
            <xsl:value-of select="."/>
        </abstract>
    </xsl:template>

    <!-- note -->
    <xd:doc>
        <xd:desc>
            <xd:p>note type="treesearch-status"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="map/string[@key = 'status_name']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <note type="treesearch-status">
            <xsl:value-of select="."/>
        </note>
    </xsl:template>

    <!-- subject/topic -->
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:b>"Controlled Vocabulary (NRTE)" or "Keywords" transforms into MODS
                    Subject/Object</xd:b>
            </xd:p>
            <xd:p><xd:b>Condtional</xd:b>When the National Research Taxonomy Elements (NRTE) JSON
                array is not null the string key values within the nrt_title tag are selected</xd:p>
            <xd:p>Otherwise the string key "keywords" value is selected</xd:p>
            <xd:p>If neither of these fields contain string values no MODS Subject/Object is
                created</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="keywords" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:choose>
            <xsl:when test="./array[@key = 'national_research_taxonomy_elements']">
                <xsl:apply-templates select="./array[@key = 'national_research_taxonomy_elements']"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./string[@key = 'keywords']"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- controlled vocacbulary -->
    <xd:doc>
        <xd:desc>The national research taxonomy elements are the preferred controlled vocabulary
            chosen for inclusion in subject/topic MODS metadata. </xd:desc>
    </xd:doc>
    <xsl:template match="map/array[@key = 'national_research_taxonomy_elements']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:for-each select="map[position()]">
            <xsl:if test="./string[@key = 'nrt_title']">
                <subject>
                    <topic>
                        <xsl:value-of select="./string[@key = 'nrt_title']"/>
                    </topic>
                </subject>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- from keywords -->
    <xd:doc>
        <xd:desc>When the array for national research taxonomy elements is not present, the keywords
            listed are used for the subject/topic</xd:desc>
    </xd:doc>
    <xsl:template match="map/string[@key = 'keywords']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:for-each select="tokenize(., ',\s+')">
            <subject>
                <topic>              
                    <xsl:value-of select="subsequence(tokenize(., ',\s+'), 1, last())"/>
                </topic>
            </subject>
        </xsl:for-each>
    </xsl:template>


    <!-- relatedItem -->
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:b>Treesearch Publication titles to MODS relatedItem title</xd:b>
            </xd:p>
            <xd:p>Publication info as a string to be parsed</xd:p>
            <xd:p>Journal host info: base doi, origin, agency, sub-agency, research station,
                research unit, page numbers</xd:p>
            <xd:p>The "@type" attribute contains one of two possible choices in this instance</xd:p>
            <xd:p>If a title matches one of the titles contained within the $p_series, that means
                its a USFS series publication and thus carries the @type="series" attribute</xd:p>
            <xd:p>All others are set to match the "pub_publication" field until the first period
                encountered. </xd:p>
        </xd:desc>
        <xd:param name="p_series"/>
    </xd:doc>
    <xsl:template name="relatedItem"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:param name="p_series">
            <xsl:value-of select="('Forest Insect &amp; Disease Leaflet',
                'General Technical Report (GTR)',
                'General Technical Report - Proceedings',
                'Information Forestry',
                'Proceeding (Rocky Mountain Research Station Publications)',
                'Resource Bulletin (RB)',
                'Research Map (RMAP)',
                'Research Note (RN)',
                'Research Paper (RP)',
                'Resource Update (RU)')"/>
        </xsl:param>
        <xsl:variable name="pub_desc_type" select="./string[@key = 'pub_type_desc']"/>
        <xsl:variable name="citation" select="./string[@key = 'citation']"/>
        <xsl:choose>
            <xsl:when test="contains($p_series, $pub_desc_type)">
                <relatedItem type="series">
                    <titleInfo type="abbreviated">
                        <title>
                            <xsl:value-of
                                select="local:seriesToAbbrv(./string[@key = 'pub_type_desc'])"/>
                        </title>
                    </titleInfo>
                    <titleInfo>
                        <title>
                            <xsl:value-of select="./string[@key = 'pub_type_desc']"/>
                        </title>
                    </titleInfo>
                    <xsl:call-template name="part"/>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise>
                <relatedItem type="host">
                    <titleInfo>
                        <title>
                            <xsl:value-of
                                select="substring-before(./string[@key = 'pub_publication'], '.')"/>
                        </title>
                    </titleInfo>
                    <xsl:call-template name="part"/>
                </relatedItem>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- part -->
    <xd:doc>
        <xd:desc>
            <xd:p>mods:part is a subelement to the </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="part" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <part>
            <!--volume-->
            <xsl:if test="(./string[@key = 'pub_volume'] != ' ')">
                <detail type="volume">
                    <number>
                        <xsl:value-of select="./string[@key = 'pub_volume']"/>
                    </number>
                    <caption>v.</caption>
                </detail>
            </xsl:if>
            <!--issue-->
            <xsl:if test="(./string[@key = 'pub_issue'] != ' ')">
                <detail type="issue">
                    <number>
                        <xsl:value-of select="./string[@key = 'pub_issue']"/>
                    </number>
                    <caption>no.</caption>
                </detail>
            </xsl:if>
            <!--extent/pages-->
            <xsl:choose>
            <xsl:when test="(./string[@key = 'modified_on']) and (. != ' ' or 'null')">
                <xsl:apply-templates select="./string[@key = 'modified_on']" mode="part"/>
            </xsl:when>
                <xsl:when test="(./string[@key = 'created_on'] != ' ') and count(./string[@key = 'modified_on'] = 0)">
                <xsl:apply-templates select="./string[@key = 'created_on']" mode="part"/>
            </xsl:when>
                <xsl:otherwise>
                    <text>
                        <xsl:attribute name="type">
                            <xsl:value-of select="/map/string[@key = 'product_year']"/>
                        </xsl:attribute>
                    </text>
                    <text type="month">01</text>
                    <text type="day">01</text>
                </xsl:otherwise>
                
               
            </xsl:choose>
            <extent unit="pages">
                <xsl:call-template name="pages"/>
            </extent>
        </part>
    </xsl:template>

    <!-- pages -->
    <xd:doc>
        <xd:desc>
            <xd:p>Matches "pub_page_start" and "pub_page_end" stiing key values</xd:p>
            <xd:p>If not, looks for a hyphenated value within the "pub_page" field, and performs the
                math</xd:p>
            <xd:p>When none of these fields used, no page numbers appear within the output</xd:p>
            <xd:p>Below a commmented out template runs through six conditions in an attempt to
                capture fields</xd:p>
            <xd:p>If all page numbers are desired, the citation field or th e</xd:p>
            <xd:p>Test 1: Special case for page numbers starting with "S" (maybe obsolete)</xd:p>
        </xd:desc>
        <xd:param name="start_page"/>
        <xd:param name="end_page"/>
        <xd:param name="citation"/>
    </xd:doc>
    <xsl:template name="pages" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:param name="start_page" select="/fn:map/fn:string[@key = 'pub_page_start']"/>
        <xsl:param name="end_page" select="/fn:map/fn:string[@key = 'pub_page_end']"/>
        <xsl:param name="citation" select="/fn:map/fn:string[@key = 'citation']"/>
        <xsl:choose>
            <xsl:when test="$start_page and $end_page">
                <xsl:sequence>
                    <start>
                        <xsl:value-of select="$start_page"/>
                    </start>
                    <end>
                        <xsl:value-of select="$end_page"/>
                    </end>
                    <total>
                        <xsl:value-of select="f:calculateTotalPgs($start_page, $end_page)"/>
                    </total>
                </xsl:sequence>
            </xsl:when>
            <xsl:when test="contains(/map/string[@key = 'pub_page'], '-')">
                <xsl:choose>
                    <xsl:when
                        test="string[@key = 'pub_page'] except *[($start_page) or ($end_page)]">
                        <start>
                            <xsl:value-of select="substring-before(string[@key = 'pub_page'], '-')"
                            />
                        </start>
                        <end>
                            <xsl:value-of select="substring-after(string[@key = 'pub_page'], '-')"/>
                        </end>
                        <xsl:if test="contains(string[@key = 'pub_page'], 's')"/>
                        <xsl:variable name="translated_total"
                            select="translate(string[@key = 'pub_page'], 's', '')"/>
                        <total>
                            <xsl:value-of
                                select="f:calculateTotalPgs(substring-before($translated_total, '-'), substring-after($translated_total, '-'))"
                            />
                        </total>
                    </xsl:when>
                    <xsl:when test="contains(/map/string[@key = 'pub_page'], '-')">
                        <xsl:analyze-string select="/map/string[@key = 'pub_page']"
                            regex="(\d+)(\-\d+)?">
                            <xsl:matching-substring>
                                <xsl:choose>
                                    <xsl:when test="regex-group(1) and regex-group(2)">
                                        <xsl:variable name="substring"
                                            select="substring-after(regex-group(2), '-')"/>
                                        <start>
                                            <xsl:number value="regex-group(1)"/>
                                        </start>
                                        <end>
                                            <xsl:number value="$substring"/>
                                        </end>
                                        <total>
                                            <xsl:value-of
                                                select="f:calculateTotalPgs(number(regex-group(1)), number($substring))"
                                            />
                                        </total>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <total>
                                    <xsl:value-of
                                        select="replace(., '^(([\.-]?[^\d\.-])+)?([+-]?\d*\.?\d+).*$', '$3')"
                                    />
                                </total>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="/map/string[@key = 'citation']">
                <xsl:analyze-string select="$citation"
                    regex="([A-z]\d+)-([A-z]\d+)|(: pages |: |: p. |: Pages )(\d+-\d+)|(\d+)(\sp|\sp.&#x22;)|(\[\d{{1,3}}\])(-\d+)?">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="regex-group(5) and regex-group(6)">
                                <total>
                                    <xsl:value-of select="number(regex-group(5))"/>
                                </total>
                            </xsl:when>
                            <xsl:when test="regex-group(1) and regex-group(2)">
                                <start>
                                    <xsl:value-of select="regex-group(1)"/>
                                </start>
                                <end>
                                    <xsl:value-of select="regex-group(2)"/>
                                </end>
                                <total>
                                    <xsl:value-of
                                        select="f:calculateTotalPgs(replace(regex-group(1), '([A-z])(\d+)', '$2'), replace(regex-group(2), '([A-z])(\d+)', '$2'))"
                                    />
                                </total>
                            </xsl:when>
                            <xsl:when test="regex-group(3) and regex-group(4)">
                                <start>
                                    <xsl:value-of select="substring-before(regex-group(4), '-')"/>
                                </start>
                                <end>
                                    <xsl:value-of select="substring-after(regex-group(4), '-')"/>
                                </end>
                                <total>
                                    <xsl:value-of
                                        select="f:calculateTotalPgs(substring-before(regex-group(4), '-'), substring-after(regex-group(4), '-'))"
                                    />
                                </total>
                            </xsl:when>
                            <xsl:when test="regex-group(7) and not(regex-group(8))">
                                <total>
                                    <xsl:value-of
                                        select="replace(regex-group(7), '(\[)(\d+)(\])', '$2')"/>
                                </total>
                            </xsl:when>
                            <xsl:when test="regex-group(7) and (regex-group(8))">
                                <start>
                                    <xsl:value-of select="regex-group(7)"/>
                                </start>
                                <end>
                                    <xsl:value-of select="substring-after(regex-group(8), '-')"/>
                                </end>
                                <total>
                                    <xsl:value-of
                                        select="f:calculateTotalPgs(replace(regex-group(7), '(\[)(\d+)(\])', '$2'), substring-after(regex-group(8), '-'))"
                                    />
                                </total>

                            </xsl:when>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:if
                            test="not(matches($citation, '([A-z]\d+)-([A-z]\d+)|(: pages |: |: p. |: Pages )(\d+-\d+)|(\d+)(\sp|\sp.&#x22;)'))">
                            <xsl:variable name="lastNumber"
                                select="string(tokenize($citation, '[^\d]+')[.][last()])"/>
                            <xsl:variable name="secondToLastNumber"
                                select="string(tokenize($citation, '[^\d]+')[.][last() - 1])"/>
                            <xsl:choose>
                                <xsl:when test="matches($citation, '(\d+-\d+)')">
                                    <start>
                                        <xsl:value-of select="$secondToLastNumber"/>
                                    </start>
                                    <end>
                                        <xsl:value-of select="$lastNumber"/>
                                    </end>
                                    <total>
                                        <xsl:value-of
                                            select="f:calculateTotalPgs($secondToLastNumber, $lastNumber)"
                                        />
                                    </total>
                                </xsl:when>
                                <xsl:when test="matches($citation, '(\d+\sp)')">
                                    <total>
                                        <xsl:value-of select="$lastNumber"/>
                                    </total>
                                    <xsl:comment>test 3.b.ii</xsl:comment>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$citation" mode="special_cases"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="/map/string[@key = 'citation']">
                <xsl:analyze-string select="$citation"
                    regex="[^\d](\d+)(-\d+)?(\sp|\sp$)|(pages\s|Pages\s|:\s|p\.\s)(\d+-\d+)">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="regex-group(1) and not(regex-group(2))">
                                <total>
                                    <xsl:value-of select="regex-group(1)"/>
                                </total>
                            </xsl:when>
                            <xsl:when test="regex-group(1) and regex-group(2)">
                                <start>
                                    <xsl:value-of select="regex-group(1)"/>
                                </start>
                                <end>
                                    <xsl:value-of select="substring-after(regex-group(2), '-')"/>
                                </end>
                                <total>
                                    <xsl:value-of
                                        select="f:calculateTotalPgs(regex-group(1), substring-after(regex-group(2), '-'))"
                                    />
                                </total>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="regex-group(5)">
                                    <start>
                                        <xsl:value-of select="substring-before(regex-group(5), '-')"
                                        />
                                    </start>
                                    <end>
                                        <xsl:value-of select="substring-after(regex-group(5), '-')"
                                        />
                                    </end>
                                    <total>
                                        <xsl:value-of
                                            select="f:calculateTotalPgs(substring-before(regex-group(5), '-'), substring-after(regex-group(5), '-'))"
                                        />
                                    </total>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:choose>
                            <xsl:when test="matches(., '[A-z]\d+-[A-z]\d')">
                                <xsl:apply-templates select="$citation" mode="special_cases"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$citation" mode="start_end_total"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                <xsl:fallback>
                    <xsl:apply-templates select="$citation" mode="start_end_total"/>
                </xsl:fallback>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <!--PUB-PUBLICATION-->
    <xd:doc>
        <xd:desc/>
        <xd:param name="pub_publication"/>
    </xd:doc>
    <xsl:template match="/fn:map/fn:string[@key = 'pub_publication']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions" mode="pub_pages"
        name="pub_publication">
        <xsl:param name="pub_publication"/>
        <xsl:variable name="lastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'pub_publication'], '[^\d]+')[.][last()])"/>
        <xsl:variable name="secondToLastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'pub_publication'], '[^\d]+')[.][last() - 1])"/>
        <xsl:choose>
            <xsl:when
                test="not(matches($pub_publication, '(\d+)(-)(\d+)')) and matches($pub_publication, '(\d+\sp)')">
                <total>
                    <xsl:value-of select="$lastNumber"/>
                </total>
            </xsl:when>
            <xsl:when test="matches($pub_publication, '(\d+)(-)(\d+)')">
                <start>
                    <xsl:value-of select="$secondToLastNumber"/>
                </start>
                <end>
                    <xsl:value-of select="$lastNumber"/>
                </end>
                <total>
                    <xsl:value-of select="f:calculateTotalPgs($secondToLastNumber, $lastNumber)"/>
                </total>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--START_END_TOTAL-->
    <xd:doc>
        <xd:desc/>
        <xd:param name="citation"/>
    </xd:doc>
    <xsl:template match="/fn:map/fn:string[@key = 'citation']" mode="start_end_total"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions" name="start_end_total">
        <xsl:param name="citation"/>
        <xsl:variable name="lastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last()])"/>
        <xsl:variable name="secondToLastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last() - 1])"/>
        <xsl:choose>
            <xsl:when test="matches($citation, '(\d+-\d+)')">
                <start>
                    <xsl:value-of select="$secondToLastNumber"/>
                </start>
                <end>
                    <xsl:value-of select="$lastNumber"/>
                </end>
                <total>
                    <xsl:value-of select="f:calculateTotalPgs($secondToLastNumber, $lastNumber)"/>
                </total>
            </xsl:when>
            <xsl:when test="matches($citation, '(\d+\sp)')">
                <total>
                    <xsl:value-of select="$lastNumber"/>
                </total>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="/fn:map/fn:string[@key = 'citation']" mode="total_only"
                />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!--TOTAL_ONLY-->
    <xd:doc>
        <xd:desc/>
        <xd:param name="citation"/>
    </xd:doc>
    <xsl:template match="/fn:map/fn:string[@key = 'citation']" mode="total_only"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions" name="total_only">
        <xsl:param name="citation"/>
        <xsl:variable name="lastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last()])"/>
        <xsl:variable name="secondToLastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last() - 1])"/>
        <xsl:choose>
            <xsl:when test="matches($citation, '[^\d+](\d+\sp)')">
                <xsl:comment>subtest 2d</xsl:comment>
                <total>
                    <xsl:value-of select="$lastNumber"/>
                </total>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
        <xd:param name="citation"/>
    </xd:doc>
    <xsl:template match="/fn:map/fn:string[@key = 'citation']" mode="analyze-string"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:param name="citation"/>
        <xsl:variable name="lastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last()])"/>
        <xsl:variable name="secondToLastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last() - 1])"/>
        <xsl:if test="matches($citation, '[^\d+](\d+\sp)')">
            <xsl:analyze-string select="$citation" regex="\d+">
                <xsl:matching-substring>
                    <total>
                        <xsl:value-of select="."/>
                    </total>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:desc/>
        <xd:param name="citation"/>
    </xd:doc>
    <xsl:template match="/fn:map/fn:string[@key = 'citation']" mode="special_cases">
        <xsl:param name="citation"/>
        <xsl:variable name="lastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last()])"/>
        <xsl:variable name="secondToLastNumber"
            select="string(tokenize(/fn:map/fn:string[@key = 'citation'], '[^\d]+')[.][last() - 1])"/>
        <xsl:choose>
            <xsl:when test="$lastNumber and $secondToLastNumber">
                <xsl:if test="matches($citation, 'R\d+-R\d+')">
                    <xsl:text>subtest3.b.iii</xsl:text>
                    <start>
                        <xsl:value-of select="$secondToLastNumber"/>
                    </start>
                    <end>
                        <xsl:value-of select="$lastNumber"/>

                    </end>
                    <total>
                        <xsl:value-of select="f:calculateTotalPgs($secondToLastNumber, $lastNumber)"
                        />
                    </total>
                </xsl:if>
            </xsl:when>
            <xsl:when test="matches($citation, '[^\d+](\d+\sp)')">
                <total>
                    <xsl:value-of select="$lastNumber"/>
                </total>
            </xsl:when>
        </xsl:choose>

    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Transforms and maps "modified_on" or "created_on" or "production_year"</xd:p>
        </xd:desc>
        <xd:param name="input"/>
    </xd:doc>
    <xsl:template match="map/string[@key = 'modified_on'] | map/string[@key = 'created_on']"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions" mode="part">
        <xsl:param name="input" select="."/>
        <!-- Define array of months -->
        <xsl:variable name="months"
            select="('JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC')"/>
        <!-- Define regex to match input date format -->
        <xsl:analyze-string select="$input" regex="^([0-9]{{1,2}})\-([A-Z]{{3}})\-([0-9]{{4}})(.*)$">
            <xsl:matching-substring>
                <text type="year">
                    <xsl:number value="regex-group(3)" format="0001"/>
                </text>
                
                <text type="month">
                    <xsl:number value="index-of($months, regex-group(2))" format="01"/>
                </text>
               
                <text type="day">
                    <xsl:number value="regex-group(1)" format="01"/>
                </text>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:ul>
                <xd:p>The following identifiers are matched and mappped to MODS:</xd:p>
                <xd:li>
                    <xd:p>DOI (digital object identifier) - ubiquitous usage of this identifer makes
                        it useful to researchers because it provides direct access to an
                        article</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p>product_id</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p>treesearch_pub_id - while only functional locally, this identifer also
                        provides direct access to the surrogate respresntion of the article</xd:p>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template name="identifiers"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <!--doi-->
        <xsl:if test="/map/string[@key = 'doi']">
            <identifier type="doi">
                <xsl:value-of select="/map/string[@key = 'doi']"/>
            </identifier>
            <!--resolves to file location-->
            <location>
                <url displayLabel="Direct access to publisher’s site">
                    <xsl:text>https://dx.doi.org/</xsl:text>
                    <xsl:value-of select="normalize-space(/map/string[@key = 'doi'])"/>
                </url>
            </location>
        </xsl:if>
        <!--vendor idedntifier-->
        <xsl:if test="/map/string[@key = 'product_id']">
            <identifier type="treesearch">
                <xsl:value-of select="/map/string[@key = 'product_id']"/>
            </identifier>
        </xsl:if>
        <!--surrogate identifier-->
        <xsl:if test="/map/string[@key = 'treesearch_pub_id']">
            <identifier type="treesearch-pub">
                <xsl:value-of select="/map/string[@key = 'treesearch_pub_id']"/>
            </identifier>
            <!--surrogate location-->
            <location>
                <url displayLabel="Direct access to publisher’s site">
                    <xsl:text>https://www.fs.usda.gov/treesearch/pubs/</xsl:text>
                    <xsl:value-of select="normalize-space(/map/string[@key = 'treesearch_pub_id'])"
                    />
                </url>
            </location>
        </xsl:if>
        <!--file location-->
        <xsl:if test="/map/string[@key = 'url_binary_file']">
            <location>
                <url displayLabel="Full Text in PDF">
                    <xsl:value-of select="normalize-space(/map/string[@key = 'url_binary_file'])"/>
                </url>
            </location>
        </xsl:if>
    </xsl:template>





    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>vendorName</xd:b>Metadata supplier name (e.g., Brill,
                Springer,Elsevier)</xd:p>
            <xd:p><xd:b>arhiveFile</xd:b>Filename from source metadata (eg.
                filename.xml,filename.json or filename.zip)</xd:p>
            <xd:p><xd:b>originalFilename</xd:b>filename w/o the extension (i.e., xml, json or
                zip)</xd:p>
            <xd:p><xd:b>workingDir</xd:b>Directory the source file is transformed</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="extension" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <extension>
            <vendorName>
                <xsl:text>United States. Forest Service</xsl:text>
            </vendorName>
            <archiveFile>
                <xsl:value-of select="$archiveFile"/>
            </archiveFile>
            <originalFile>
                <xsl:value-of select="$originalFilename"/>
            </originalFile>
            <workingDirectory>
                <xsl:value-of select="$workingDir"/>
            </workingDirectory>
            <stylesheet>
                <xsl:value-of select="document-uri(document(''))"/>
            </stylesheet>
        </extension>
    </xsl:template>
</xsl:stylesheet>

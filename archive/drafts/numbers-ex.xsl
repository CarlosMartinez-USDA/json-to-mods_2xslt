<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    
    
    
    
    <xsl:template match="map/string">
        <xsl:variable name="vS" select="concat(.,'Z')"/>
        <xsl:value-of select=
            "substring-before(translate($vS,translate($vS,'0123456789',''),'Z'),'Z')"/>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
    
    
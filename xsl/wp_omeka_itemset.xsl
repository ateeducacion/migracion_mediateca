<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wp="http://wordpress.org/export/1.2/"
    exclude-result-prefixes="wp">

    <!-- Output settings -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Root template -->
    <xsl:template match="/">
        <resources>
            <xsl:apply-templates select="//wp:term[wp:term_taxonomy = 'media-category']"/>
        </resources>
    </xsl:template>

    <!-- Template for wp:term -->
    <xsl:template match="wp:term">
        <resource wrapper="1">
            <wp:term xmlns:content="http://purl.org/rss/1.0/modules/content/"
                xmlns:wfw="http://wellformedweb.org/CommentAPI/"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:wp="http://wordpress.org/export/1.2/"
                xmlns:o="http://omeka.org/s/vocabs/o#" >
                <term_id>
                    <xsl:value-of select="wp:term_id"/>
                </term_id>
                <term_taxonomy>
                    <xsl:value-of select="wp:term_taxonomy"/>
                </term_taxonomy>
                <term_slug>
                    <xsl:value-of select="wp:term_slug"/>
                </term_slug>
                <term_parent>
                    <xsl:value-of select="wp:term_parent"/>
                </term_parent>
                <term_name>
                    <xsl:value-of select="wp:term_name"/>
                </term_name>
            </wp:term>
        </resource>
    </xsl:template>

</xsl:stylesheet>
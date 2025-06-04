<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wp="http://wordpress.org/export/1.2/"
    exclude-result-prefixes="wp">

    <!-- Declare parameters with default values -->
    <xsl:param name="postType" select="'attachment'" />
    <xsl:param name="postParent" select="'0'" />
    <xsl:param name="Media" select="'0'" />

    <!-- Root transformation -->
    <xsl:template match="/">
        <rss version="2.0">
            <xsl:choose>
                <xsl:when test="$Media = '0'">
                    <xsl:apply-templates select="//item[wp:post_type = $postType and wp:post_parent = $postParent]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="//item[wp:post_type = $postType]"/>
                </xsl:otherwise>
            </xsl:choose>
        </rss>
    </xsl:template>

    <!-- Transform each item -->
    <xsl:template match="item">
        <xsl:choose>
            <xsl:when test="wp:post_parent = '0'">
                <resource wrapper="1">
                    <wp:item xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/"
                          xmlns:content="http://purl.org/rss/1.0/modules/content/"
                          xmlns:wfw="http://wellformedweb.org/CommentAPI/"
                          xmlns:dc="http://purl.org/dc/elements/1.1/"
                          xmlns:wp="http://wordpress.org/export/1.2/"
                          xmlns:o="http://omeka.org/s/vocabs/o#">
                        
                        <!-- Basic metadata -->
                        <title>
                            <xsl:value-of select="title"/>
                        </title>
                        <link>
                            <xsl:value-of select="link"/>
                        </link>
                        <pubDate>
                            <xsl:value-of select="pubDate"/>
                        </pubDate>
                        <dc:creator>
                            <xsl:value-of select="dc:creator"/>
                        </dc:creator>
                        <guid>
                            <xsl:value-of select="guid"/>
                        </guid>
                        <description>
                            <xsl:value-of select="description"/>
                        </description>

                        <content:encoded>
                            <xsl:value-of select="content:encoded"/>
                        </content:encoded>
                        
                        <wp:attachment_url>
                                    <xsl:value-of select="wp:attachment_url"/>
                        </wp:attachment_url>

                        <!-- WordPress specific fields -->
                        <wp:post_id>
                            <xsl:value-of select="wp:post_id"/>
                        </wp:post_id>
                        <wp:post_date>
                            <xsl:value-of select="wp:post_date"/>
                        </wp:post_date>
                        <wp:post_date_gmt>
                            <xsl:value-of select="wp:post_date_gmt"/>
                        </wp:post_date_gmt>
                        <wp:comment_status>
                            <xsl:value-of select="wp:comment_status"/>
                        </wp:comment_status>
                        <wp:ping_status>
                            <xsl:value-of select="wp:ping_status"/>
                        </wp:ping_status>
                        <wp:post_name>
                            <xsl:value-of select="wp:post_name"/>
                        </wp:post_name>
                        <wp:status>
                            <xsl:value-of select="wp:status"/>
                        </wp:status>
                        <wp:post_parent>
                            <xsl:value-of select="wp:post_parent"/>
                        </wp:post_parent>
                        <wp:menu_order>
                            <xsl:value-of select="wp:menu_order"/>
                        </wp:menu_order>
                        <wp:post_type>
                            <xsl:value-of select="wp:post_type"/>
                        </wp:post_type>
                        <wp:post_password>
                            <xsl:value-of select="wp:post_password"/>
                        </wp:post_password>
                        <wp:is_sticky>
                            <xsl:value-of select="wp:is_sticky"/>
                        </wp:is_sticky>
                        <!-- Categories -->
                        <xsl:for-each select="category">
                            <category>
                                <xsl:copy-of select="@*"/>
                                <xsl:value-of select="."/>
                            </category>
                        </xsl:for-each>

                        <!-- Post Meta -->
                        <xsl:for-each select="wp:postmeta">
                            <wp:postmeta>
                                <wp:meta_key>
                                    <xsl:value-of select="wp:meta_key"/>
                                </wp:meta_key>
                                <wp:meta_value>
                                    <xsl:value-of select="wp:meta_value"/>
                                </wp:meta_value>
                            </wp:postmeta>
                        </xsl:for-each>
                    </wp:item>
                </resource>
                <xsl:choose>
                    <xsl:when test="$Media != '0'">
                        <resource wrapper="1">
                            <wp:item xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/"
                                  xmlns:content="http://purl.org/rss/1.0/modules/content/"
                                  xmlns:wfw="http://wellformedweb.org/CommentAPI/"
                                  xmlns:dc="http://purl.org/dc/elements/1.1/"
                                  xmlns:wp="http://wordpress.org/export/1.2/"
                                  xmlns:o="http://omeka.org/s/vocabs/o#">
                                <title>
                                    <xsl:value-of select="title"/>
                                </title>
                                <dc:creator>
                                    <xsl:value-of select="dc:creator"/>
                                </dc:creator>
                                <link>
                                    <xsl:value-of select="link"/>
                                </link>
                                <pubDate>
                                    <xsl:value-of select="pubDate"/>
                                </pubDate>
                                <wp:post_id>
                                    <xsl:value-of select="wp:post_id"/>
                                </wp:post_id>

                                <content:encoded>
                                    <xsl:value-of select="content:encoded"/>
                                </content:encoded>
                                <excerpt:encoded>
                                    <xsl:value-of select="excerpt:encoded"/>
                                </excerpt:encoded>
                                <!-- Post Meta copyright-->
                                <xsl:for-each select="wp:postmeta[wp:meta_key = 'meta_copyright']">
                                    <wp:postmeta>
                                        <wp:meta_key>
                                            <xsl:value-of select="wp:meta_key"/>
                                        </wp:meta_key>
                                        <wp:meta_value>
                                            <xsl:value-of select="wp:meta_value"/>
                                        </wp:meta_value>
                                    </wp:postmeta>
                                </xsl:for-each>
                            </wp:item>
                        </resource>
                    </xsl:when>
                </xsl:choose>
                
            </xsl:when>
            <xsl:otherwise>
                <resource wrapper="1">
                    <wp:item xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/"
                          xmlns:content="http://purl.org/rss/1.0/modules/content/"
                          xmlns:wfw="http://wellformedweb.org/CommentAPI/"
                          xmlns:dc="http://purl.org/dc/elements/1.1/"
                          xmlns:wp="http://wordpress.org/export/1.2/"
                          xmlns:o="http://omeka.org/s/vocabs/o#">
                        
                        <!-- Basic metadata -->
                        <title>
                            <xsl:value-of select="title"/>
                        </title>
                        <link>
                            <xsl:value-of select="link"/>
                        </link>
                        <pubDate>
                            <xsl:value-of select="pubDate"/>
                        </pubDate>
                        <dc:creator>
                            <xsl:value-of select="dc:creator"/>
                        </dc:creator>
                        <guid>
                            <xsl:value-of select="guid"/>
                        </guid>
                        <description>
                            <xsl:value-of select="description"/>
                        </description>
                        <!-- WordPress specific fields -->
                        <wp:post_id>
                            <xsl:value-of select="wp:post_parent"/>
                        </wp:post_id>
                        <wp:post_date>
                            <xsl:value-of select="wp:post_date"/>
                        </wp:post_date>
                        <wp:post_date_gmt>
                            <xsl:value-of select="wp:post_date_gmt"/>
                        </wp:post_date_gmt>
                        <wp:comment_status>
                            <xsl:value-of select="wp:comment_status"/>
                        </wp:comment_status>
                        <wp:ping_status>
                            <xsl:value-of select="wp:ping_status"/>
                        </wp:ping_status>
                        <wp:post_name>
                            <xsl:value-of select="wp:post_name"/>
                        </wp:post_name>
                        <wp:status>
                            <xsl:value-of select="wp:status"/>
                        </wp:status>
                        <wp:post_parent>
                            <xsl:value-of select="wp:post_parent"/>
                        </wp:post_parent>
                        <wp:menu_order>
                            <xsl:value-of select="wp:menu_order"/>
                        </wp:menu_order>
                        <wp:post_type>
                            <xsl:value-of select="wp:post_type"/>
                        </wp:post_type>
                        <wp:post_password>
                            <xsl:value-of select="wp:post_password"/>
                        </wp:post_password>
                        <wp:is_sticky>
                            <xsl:value-of select="wp:is_sticky"/>
                        </wp:is_sticky>
                        <!-- Attachment -->    
                        <wp:attachment_url>
                            <xsl:value-of select="wp:attachment_url"/>
                        </wp:attachment_url>
                        <!-- Categories -->
                        <xsl:for-each select="category">
                            <category>
                                <xsl:copy-of select="@*"/>
                                <xsl:value-of select="."/>
                            </category>
                        </xsl:for-each>

                        <!-- Post Meta -->
                        <xsl:for-each select="wp:postmeta">
                            <wp:postmeta>
                                <wp:meta_key>
                                    <xsl:value-of select="wp:meta_key"/>
                                </wp:meta_key>
                                <wp:meta_value>
                                    <xsl:value-of select="wp:meta_value"/>
                                </wp:meta_value>
                            </wp:postmeta>
                        </xsl:for-each>
                    </wp:item>
                </resource>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
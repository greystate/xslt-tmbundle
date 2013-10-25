<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xdt="http://www.w3.org/2005/04/xpath-data-types"
>

	<xsl:output method="html" indent="yes" omit-xml-declaration="yes"
		doctype-public="about:legacy-compat"
	/>
	
	<!-- Do some dirty work -->
	<xsl:variable name="durations" as="element()+">
		<xsl:apply-templates select="/logs/log[in and out]" mode="duration" />
	</xsl:variable>
	
	<xsl:template match="/">
		<html>
		<head>
			<title>Log Viewer</title>
			<style>
				html, body, p, dl, dt, dd, h1, h2, h3, p { margin: 0; padding: 0; }
				body { font: 75% 'Lucida Grande'; padding: 1em; }
				h1 { font-size: 1.1em; margin: 0 0 0.6em; }
				dl { margin: 0 0 1em; float: left; clear: both; }
				dt { clear: both; font-weight: bold; border-bottom: 1px dotted #ccc; color: #999; }
				dd.time { width: 8em; float: left; clear: both; color: #333; }
				dd.duration { width: 5em; text-align: right; float: left; font-weight: bold; position: relative; }
				dd small { position: absolute; width: 14em; left: 100%; color: ccc; }
				div.totals { width: 20em; padding: 10px 0; margin-bottom: 10px; border-bottom: 3px double; clear: both; }
				<!-- dd+dd+dd { clear: left; float: left; } -->
			</style>
		</head>
		<body>
			<xsl:apply-templates />
		</body>
		</html>
	</xsl:template>
	
	<xsl:template match="logs">
		<h1>Project Log: <xsl:value-of select="@project" /></h1>
		<div class="totals">
			<xsl:variable name="total" select="xs:dayTimeDuration(concat('PT', sum($durations/@minutes), 'M'))" as="xs:dayTimeDuration" />
			Total: <xsl:value-of select="sum($durations/@minutes) idiv 60" /> hour(s),
					<xsl:value-of select="minutes-from-duration($total)" /> minutes.
		</div>
		<xsl:for-each-group select="log[in and out]" group-by="substring(@on, 1, 10)">
			<xsl:sort select="concat(@on, in/@at)" order="descending" />
			<dl>
				<xsl:apply-templates select="." mode="group" />
				
				<xsl:apply-templates select="current-group()" mode="item" />
			</dl>
		</xsl:for-each-group>

		<xsl:sequence select="$durations" />
	</xsl:template>
	
	<xsl:template match="log" mode="group">
		<dt>
			<xsl:apply-templates select="@on" mode="date" />
		</dt>
	</xsl:template>
	
	<xsl:template match="log" mode="item">
		<dd class="time">
			<xsl:apply-templates select="in/@at" />
			<xsl:text> &#8212; </xsl:text>
			<xsl:apply-templates select="out/@at" />
		</dd>
		<dd class="duration">
			<xsl:variable name="duration" select="$durations[@in = concat(current()/@on, 'T', current()/in/@at)]/@val" />			
			<xsl:value-of select="concat(hours-from-duration($duration), 'h ', minutes-from-duration($duration), 'm')" />
			<xsl:apply-templates select="note" />
		</dd>
	</xsl:template>
	
	<xsl:template match="@at">
		<xsl:variable name="format" select="'[H01]:[m]'" />
		<xsl:value-of select="if (contains(., 'T')) then format-dateTime(., $format) else format-time(., $format)" />
	</xsl:template>
	
	<xsl:template match="log" mode="duration">
		<xsl:variable name="in" select="xs:dateTime(concat(@on, 'T', in/@at))" as="xs:dateTime" />
		<xsl:variable name="out" select="if (contains(out/@at ,'T')) then xs:dateTime(out/@at) else xs:dateTime(concat(@on, 'T', out/@at))" as="xs:dateTime" />

		<xsl:variable name="duration" select="$out - $in" as="xs:dayTimeDuration" />
		
		<dur in="{$in}" val="{$duration}" minutes="{hours-from-duration($duration) * 60 + minutes-from-duration($duration)}" />
	</xsl:template>
	
	<xsl:template match="@on" mode="date">
		<xsl:value-of select="format-date(., '[MNn,3-3] [D]')" />
	</xsl:template>
	
	<xsl:template match="note">
		<small>
			<xsl:value-of select="." />
		</small>
	</xsl:template>
	
</xsl:stylesheet>
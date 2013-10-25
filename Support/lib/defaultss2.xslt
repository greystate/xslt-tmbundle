<?xml version="1.0"?>
<!--
	IE5 default style sheet, provides a view of any XML document
	and provides the following features:
	- auto-indenting of the display, expanding of entity references
	- click or tab/return to expand/collapse
	- color coding of markup
	- color coding of recognized namespaces - xml, xmlns, xsl, dt
 
	This style sheet is available in IE5 in a compact form at the URL
	"res://msxml.dll/DEFAULTSS.xsl".  This version differs only in the
	addition of comments and whitespace for readability.

	Author:  	Jonathan Marsh (jmarsh@microsoft.com)
	Modified:   05/21/2001 by Nate Austin (naustin@idsgrp.com)
				Converted to use XSLT rather than WD-xsl

	TODO:		Detect CDATA Sections and re-implement
	TODO:		Detect processing-instructions and re-implement
	
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dt="urn:schemas-microsoft-com:datatypes"
	xmlns:d2="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
>

	<xsl:output
		method="html"
		indent="no"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		cdata-section-elements=""
	/>
	
	<xsl:variable name="xsl-prefix" select="'xsl:'" />
	
	<xsl:attribute-set name="name-class">
		<xsl:attribute name="class">
			<xsl:if test="starts-with(name(), $xsl-prefix)">x</xsl:if>
			<xsl:text>t</xsl:text>
		</xsl:attribute>
	</xsl:attribute-set>
	
<xsl:template match="/">
	<html>
		<head>
			<style type="text/css">
				body {font: small 'Verdana'; margin-right:1.5em; }
				<!-- container for expanding/collapsing content -->
				.c  { cursor: pointer; }
				<!-- button - contains +/-/nbsp -->
				.b  { color:red; font-family:'Courier New'; font-weight:bold; text-decoration:none; }
				<!-- element container -->
				.e  { margin-left:1em; text-indent:-1em; margin-right: 1em;}
				<!-- comment or cdata -->
				.k  { margin-left:1em; text-indent:-1em; margin-right:1em}
				<!-- tag -->
				.t  {color:#990000}
				<!-- tag in xsl namespace -->
				.xt {color:#990099}
				<!-- attribute in xml or xmlns namespace -->
				.ns {color:red}
				<!-- attribute in dt namespace -->
				.dt {color:green}
				<!-- markup characters -->
				.m  {color:blue}
				<!-- text node -->
				.tx {font-weight:bold}
				<!-- multi-line (block) cdata -->
				.db {text-indent:0px; margin-left:1em; margin-top:0px; margin-bottom:0px; padding-left:.3em; border-left:1px solid #CCCCCC; font:small Courier; }
				<!-- single-line (inline) cdata -->
				.di {font:small Courier}
				<!-- DOCTYPE declaration -->
				.d  {color:blue}
				<!-- pi -->
				.pi {color:blue}
				<!-- multi-line (block) comment -->
				.cb {text-indent:0px; margin-left:1em; margin-top:0px; margin-bottom:0px; padding-left:.3em; font:small Courier; color:#888888}
				<!-- single-line (inline) comment -->
				.ci {font:small Courier; color:#888888}
				pre {margin:0px; display:inline}
			</style>

			<script type="text/javascript"><xsl:comment><![CDATA[
			function $(element) { return (typeof element === "string" ? document.getElementById(element) : element); }
			// Detect and switch the display of CDATA and comments from an inline view
			//  to a block view if the comment or CDATA is multi-line.
			function f(e) {
				e = $(e);
				// if this element is an inline comment, and contains more than a single
				//  line, turn it into a block comment.
				if (e.className == "ci") {
					if (e.childNodes[0].innerText.indexOf("\n") > 0)
						fix(e, "cb");
				}

				// if this element is an inline cdata, and contains more than a single
				//  line, turn it into a block cdata.
				if (e.className == "di") {
					if (e.childNodes[0].innerText.indexOf("\n") > 0)
						fix(e, "db");
				}

				// remove the id since we only used it for cleanup
				e.id = "";
			}
        
			// Fix up the element as a "block" display and enable expand/collapse on it
			function fix(e, cl) {
				e = $(e);
				// change the class name and display value
				e.className = cl;
				e.style.display = "block";

				// mark the comment or cdata display as a expandable container
				j = e.parentElement.childNodes[0];
				j.className = "c";

				// find the +/- symbol and make it visible - the dummy link enables tabbing
				k = j.childNodes[0];
				k.style.visibility = "visible";
				k.href = "#";
			}

			// Change the +/- symbol and hide the children.
			// This function works on "element" displays
			function ch(e) {
				e = $(e);
				// find the +/- symbol
				mark = e.childNodes[0].childNodes[0];

				// if it is already collapsed, expand it by showing the children
				if (mark.innerText == "+") {
					mark.innerText = "-";
					for (var i = 1; i < e.childNodes.length; i++)
					e.childNodes[i].style.display = "block";
				}

				// if it is expanded, collapse it by hiding the children
				else if (mark.innerText == "-") {
					mark.innerText = "+";
					for (var i = 1; i < e.childNodes.length; i++)
					e.childNodes[i].style.display = "none";
				}
			}
        
			// Change the +/- symbol and hide the children.
			// This function work on "comment" and "cdata" displays
			function ch2(e) {
				e = $(e);
				// find the +/- symbol, and the "PRE" element that contains the content
				mark = e.childNodes[0].childNodes[0];
				contents = e.childNodes[1];

				// if it is already collapsed, expand it by showing the children
				if (mark.innerText == "+") {
					mark.innerText = "-";
					// restore the correct "block"/"inline" display type to the PRE
					if (contents.className == "db" || contents.className == "cb") {
						contents.style.display = "block";
					} else {
						contents.style.display = "inline";
					}
				}

				// if it is expanded, collapse it by hiding the children
				else if (mark.innerText == "-") {
					mark.innerText = "+";
					contents.style.display = "none";
				}
			}
        
			// Handle a mouse click
			function cl(evt) {
				e = (evt || window.event).srcElement;

				// make sure we are handling clicks upon expandable container elements
				if (e.className != "c") {
					e = e.parentElement;
					if (e.className != "c") {
						return;
					}
				}
				e = e.parentElement;

				// call the correct funtion to change the collapse/expand state and display
				if (e.className == "e") {
					ch(e);
				}
				if (e.className == "k") {
					ch2(e);
				}
			}

			// Dummy function for expand/collapse link navigation - trap onclick events instead
			function ex() { }

			// Erase bogus link info from the status window
			function h() {
				window.status = " ";
			}

			// Set the onclick handler
			document.onclick = cl;
      ]]></xsl:comment></script>
		</head>
		<body class="st">
			<xsl:apply-templates />
		</body>
	</html>
</xsl:template>

<!-- Templates for each node type follows.  The output of
each template has a similar structure to enable script to
walk the result tree easily for handling user
interaction. -->
  
<!-- Template for the DOCTYPE declaration.  No way to get
	  the DOCTYPE, so we just put in a placeholder -->

<!--  no support for doctypes
<xsl:template match="node()[nodeType()=10]">
  <DIV class="e"><SPAN>
  <SPAN class="b">&#160;</SPAN>
  <SPAN class="d">&lt;!DOCTYPE <xsl:value-of 
	  select="name()" /><I> (View
Source for full doctype...)</I>&gt;</SPAN>
  </SPAN></DIV>
</xsl:template>
-->

<!-- Template for pis not handled elsewhere -->
<xsl:template match="processing-instruction()">
	<div class="e">
		<span class="b">&#160;</span>
		<span class="m">&lt;?</span>
		<span class="pi">
			<xsl:value-of select="name()" />&#160;<xsl:value-of select="." />
		</span>
		<span class="m">?&gt;</span>
	</div>
</xsl:template>

<!-- Template for the XML declaration.  Need a separate template because the
pseudo-attributes
    are actually exposed as attributes instead of just element content, as
in other pis -->
<!--  No support for the xml declaration
<xsl:template match="pi('xml')">
  <DIV class="e">
  <SPAN class="b">&#160;</SPAN>
  <SPAN class="m">&lt;?</SPAN><SPAN class="pi">xml 
	  <xsl:for-each
select="@*"><xsl:value-of select="name()" />="<xsl:value-of select="." />"
</xsl:for-each></SPAN><SPAN class="m">?&gt;</SPAN>
  </DIV>
</xsl:template>
-->

<!-- Template for attributes not handled elsewhere -->
<xsl:template match="@*">
	<span xsl:use-attribute-sets="name-class">
		<xsl:value-of select="concat(' ', name())" />
	</span>
	<span class="m">="</span>
	<b><xsl:value-of select="." /></b>
	<span class="m">"</span>
</xsl:template>

<!-- Template for attributes in the xmlns or xml namespace -->
<!--  UNKNOWN
<xsl:template match="@xmlns:*|@xmlns|@xml:*"><SPAN 
	  class="ns"> <xsl:value-of
select="name()" /></SPAN><SPAN class="m">="</SPAN>
	  <B class="ns"><xsl:value-of
select="." /></B><SPAN class="m">"</SPAN></xsl:template>
-->

<!-- Template for attributes in the dt namespace -->
<!-- UNKNOWN
<xsl:template match="@dt:*|@d2:*"><SPAN 
	  class="dt"> <xsl:value-of
select="name()" /></SPAN><SPAN class="m">="</SPAN><B 
	  class="dt"><xsl:value-of
select="." /></B><SPAN class="m">"</SPAN></xsl:template>
-->

<!-- Template for text nodes -->
<xsl:template match="text()">
	<div class="e">
		<span class="b">&#160;</span>
		<span class="tx">
			<xsl:value-of select="." />
		</span>
	</div>
</xsl:template>

<!-- Template for empty text nodes -->
<xsl:template match="text()[not(normalize-space())]" />

<!-- Note that in the following templates for comments
and cdata, by default we apply a style appropriate for
single line content (e.g. non-expandable, single line
display).  But we also inject the attribute 'id="clean"' and
a script call 'f(clean)'.  As the output is read by the
browser, it executes the function immediately.  The function
checks to see if the comment or cdata has multi-line data,
in which case it changes the style to a expandable,
multi-line display.  Performing this switch in the DHTML
instead of from script in the XSL increases the performance
of the style sheet, especially in the browser's asynchronous
case -->
  
<!-- Template for comment nodes -->
<xsl:template match="comment()">
	<div class="k">
		<span>
			<a class="b" onclick="return false" onfocus="h()" style="visibility:hidden">-</a>
			<span class="m">&lt;!--</span>
		</span>
		<span id="{generate-id(.)}" class="ci">
			<pre>
				<xsl:value-of select="." />
			</pre>
		</span>
		<span class="b">&#160;</span>
		<span class="m">--&gt;</span>
		<script>f('<xsl:value-of select="generate-id(.)" />');</script>
	</div>
</xsl:template>

<!-- Template for cdata nodes -->
<!-- UNSUPPORTED
<xsl:template match="cdata()">
  <DIV class="k">
  <SPAN><A class="b" onclick="return false" onfocus="h()"
STYLE="visibility:hidden">-</A> <SPAN class="m">
	  &lt;![CDATA[</SPAN></SPAN>
  <SPAN id="clean" class="di"><PRE><xsl:value-of 
	  select="." /></PRE></SPAN>
  <SPAN class="b">&#160;</SPAN> <SPAN 
	  class="m">]]&gt;</SPAN>
  <SCRIPT>f(clean);</SCRIPT></DIV>
</xsl:template>
-->


<!-- Note the following templates for elements may
examine children.  This harms to some extent the ability to
process a document asynchronously - we can't process an
element until we have read and examined at least some of its
children.  Specifically, the first element child must be
read before any template can be chosen.  And any element
that does not have element children must be read completely
before the correct template can be chosen. This seems an
acceptable performance loss in the light of the formatting
possibilities available when examining children. -->

<!-- Template for elements not handled elsewhere (leaf nodes) -->
<xsl:template match="*">
	<div class="e">
		<div style="margin-left:1em;text-indent:-2em">
  			<span class="b">&#160;</span>
  			<span class="m">&lt;</span>
			<span xsl:use-attribute-sets="name-class">
				<xsl:value-of select="name()" />
			</span>
			<xsl:apply-templates select="@*" />
			<span class="m"> /&gt;</span>
		</div>
	</div>
</xsl:template>
  
<!-- Template for elements with comment, pi and/or cdata children -->
<xsl:template match="*[comment() | processing-instruction()]">
	<div class="e">
		<div class="c">
			<a href="#" onclick="return false" onfocus="h()" class="b">-</a>
			<span class="m">&lt;</span>
			<span xsl:use-attribute-sets="name-class">
				<xsl:value-of select="name()" />
			</span>
			<xsl:apply-templates select="@*" /> 
			<span class="m">&gt;</span>
		</div>
		<div>
			<xsl:apply-templates />
			<div>
				<span class="b">&#160;</span>
				<span class="m">&lt;/</span>
				<span xsl:use-attribute-sets="name-class">
					<xsl:value-of select="name()" />
				</span>
				<span class="m">&gt;</span>
			</div>
		</div>
	</div>
</xsl:template>

<!-- Template for elements with only text children -->
<xsl:template match="*[text() and not(comment() | processing-instruction())]">
	<div class="e">
		<div style="margin-left:1em;text-indent:-2em">
			<span class="b">&#160;</span>
			<span class="m">&lt;</span>
			<span xsl:use-attribute-sets="name-class">
				<xsl:value-of select="name()" />
			</span>
			<xsl:apply-templates select="@*" />
			<span class="m">&gt;</span>
			<span class="tx">
				<xsl:value-of select="." />
			</span>
			<span class="m">&lt;/</span>
			<span xsl:use-attribute-sets="name-class">
				<xsl:value-of select="name()" />
			</span>
			<span class="m">&gt;</span>
		</div>
	</div>
</xsl:template>

<!-- Template for elements with element children -->
<xsl:template match="*[*]">
	<div class="e">
		<div class="c" style="margin-left:1em;text-indent:-2em">
			<a href="#" onclick="return false" onfocus="h()" class="b">-</a>
			<span class="m">&lt;</span>
			<span xsl:use-attribute-sets="name-class">
				<xsl:value-of select="name()" />
			</span>
			<xsl:apply-templates select="@*" />
			<span class="m">&gt;</span>
		</div>
		<div>
			<xsl:apply-templates />
			<div>
				<span class="b">&#160;</span>
				<span class="m">&lt;/</span>
				<span>
					<xsl:attribute name="class">
						<xsl:if test="starts-with(name(), $xsl-prefix)">x</xsl:if>
						<xsl:text>t</xsl:text>
					</xsl:attribute>
					<xsl:value-of select="name()" />
				</span>
				<span class="m">&gt;</span>
			</div>
		</div>
	</div>
</xsl:template>

</xsl:stylesheet>
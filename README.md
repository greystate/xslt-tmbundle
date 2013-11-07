# XSLT.tmbundle

This my own tried and tested, tweaked and twisted **XSLT bundle** for **[TextMate 2][TM2]**.

[TM2]: http://macromates.com/

## Installation

	cd ~/Library/Application\ Support/Avian/Bundles/
	git clone git://github.com/greystate/xslt-tmbundle XSLT.tmbundle


## Snippets

The things I use most from this bundle are definitely the snippets - here's a couple of highlights:

* `tmpl`	: Create a new *match* template
* `tmpln`	: Create a new *named* template
* `tmplm`	: Create a new match template with a mode

* `appl`	: Create an apply-templates instruction
* `appls`	: Create an apply-templates instruction with a sort node


## Commands

### Preview Transformation

Select an XML file and an XSLT stylesheet in the project folder, and run this command, to run the transform and display the result as HTML in the Web Preview window.

### Transform and show as XML

Like the previous one, this requires an XML file and an XSLT stylesheet selected in the project - the XML is transformed with the XSLT and the results is shown as colour-coded XML.

## Notes

* Some commands still refer to scripts on my local drive, so won't work. Hopefully I'll be able to fix those along the way.


# XML-XMLParserHTML

[![Build Status](https://travis-ci.org/pharo-contributions/XML-XMLParserHTML.svg?branch=master)](https://travis-ci.org/pharo-contributions/XML-XMLParserHTML) [![Coverage Status](https://coveralls.io/repos/github/pharo-contributions/XML-XMLParserHTML/badge.svg?branch=master)](https://coveralls.io/github/pharo-contributions/XML-XMLParserHTML?branch=master)

**XMLParserHTML** provides SAX and DOM parsers in [Pharo](http://www.pharo.org) for HTML that convert possibly malformed HTML into well-formed XML.

## Installation

```Smalltalk
Metacello new
	baseline: 'XMLParserHTML';
	repository: 'github://pharo-contributions/XML-XMLParserHTML/src';
	load.
```

## Usage

A simple example on how to use the XML parser for HTML:

```Smalltalk
...
```

results in the following XML output
```HTML
...
```

## Scrapping

This library together with [XPath](https://github.com/pharo-contributions/XML-XPath) enables you to do web scrapping from the confort of the Pharo toolset.

You can learn more about how to do it reading the [Scrapping with XPath booklet](http://books.pharo.org/booklet-Scraping/html/scrapingbook.html).


## LICENSE
[MIT License](LICENSE)

## History
This project was migrated from [http://smalltalkhub.com/#!/~PharoExtras/XMLParserHTML](http://smalltalkhub.com/#!/~PharoExtras/XMLParserHTML)

"
This class is a SAX2Parser for messy HTML.
"
Class {
	#name : #SAX2HTMLParser,
	#superclass : #SAX2Parser,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #private }
SAX2HTMLParser >> driverClass [
	^ SAXHTMLParserDriver
]

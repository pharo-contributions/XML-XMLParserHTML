"
This class is a SAX2Parser for messy HTML. The DOM-basesd XMLHTMLParser should probably be preferred.
"
Class {
	#name : #SAX2HTMLParser,
	#superclass : #SAX2Parser,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #defaults }
SAX2HTMLParser >> driverClass [
	^ SAXHTMLParserDriver
]

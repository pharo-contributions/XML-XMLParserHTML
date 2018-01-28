"
This class is a SAX2Parser for messy HTML. The DOM-basesd XMLHTMLParser should probably be preferred.
"
Class {
	#name : #SAX2HTMLParser,
	#superclass : #SAX2Parser,
	#category : #'XML-ParserHTML-Core-XML-ParserHTML-Core'
}

{ #category : #defaults }
SAX2HTMLParser >> driverClass [
	^ SAXHTMLParserDriver
]

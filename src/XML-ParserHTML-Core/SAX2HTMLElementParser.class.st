"
This class is a SAX2ElementParser for messy HTML. The DOM-basesd XMLHTMLParser should probably be preferred.
"
Class {
	#name : #SAX2HTMLElementParser,
	#superclass : #SAX2ElementParser,
	#category : #'XML-ParserHTML-Core-XML-ParserHTML-Core'
}

{ #category : #defaults }
SAX2HTMLElementParser >> driverClass [
	^ SAXHTMLParserDriver
]

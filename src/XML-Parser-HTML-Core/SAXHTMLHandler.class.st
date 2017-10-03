"
This class is a SAXHandler for messy HTML. The DOM-basesd XMLHTMLParser should probably be preferred.
"
Class {
	#name : #SAXHTMLHandler,
	#superclass : #SAXHandler,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #defaults }
SAXHTMLHandler >> driverClass [
	^ SAXHTMLParserDriver
]

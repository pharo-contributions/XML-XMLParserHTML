"
This class is a SAXHandler for messy HTML.
"
Class {
	#name : #SAXHTMLHandler,
	#superclass : #SAXHandler,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #private }
SAXHTMLHandler >> driverClass [
	^ SAXHTMLParserDriver
]

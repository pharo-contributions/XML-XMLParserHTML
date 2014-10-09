"
This is class is a SAXHandler for HTML.
"
Class {
	#name : #HTMLHandler,
	#superclass : #SAXHandler,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #private }
HTMLHandler >> driverClass [
	^ HTMLParserDriver
]

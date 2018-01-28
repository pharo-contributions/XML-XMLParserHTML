"
A state for elements containing non-markup content.
"
Class {
	#name : #XMLHTMLNonHTMLSectionState,
	#superclass : #XMLContentState,
	#category : #'XML-ParserHTML-Core-Drivers'
}

{ #category : #tokenizing }
XMLHTMLNonHTMLSectionState >> nextTokenFrom: aTokenizer [
	aTokenizer nextNonHTMLSectionToken
]

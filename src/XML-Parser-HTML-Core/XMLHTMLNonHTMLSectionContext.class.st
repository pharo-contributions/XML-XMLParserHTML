"
A context for elements containing non-markup content.
"
Class {
	#name : #XMLHTMLNonHTMLSectionContext,
	#superclass : #XMLContentContext,
	#category : #'XML-Parser-HTML-Core-Drivers'
}

{ #category : #tokenizing }
XMLHTMLNonHTMLSectionContext >> nextTokenFrom: aTokenizer [
	aTokenizer nextNonHTMLSectionToken
]

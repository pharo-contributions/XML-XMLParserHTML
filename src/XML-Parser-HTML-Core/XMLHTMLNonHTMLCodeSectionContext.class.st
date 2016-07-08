"
A context for elements containing non-markup code with comments or string literals.
"
Class {
	#name : #XMLHTMLNonHTMLCodeSectionContext,
	#superclass : #XMLHTMLNonHTMLSectionContext,
	#category : #'XML-Parser-HTML-Core-Drivers'
}

{ #category : #tokenizing }
XMLHTMLNonHTMLCodeSectionContext >> nextTokenFrom: aTokenizer [
	aTokenizer nextNonHTMLCodeSectionToken
]

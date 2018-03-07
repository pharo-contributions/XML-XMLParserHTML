"
A state for elements containing non-markup code with comments or string literals.
"
Class {
	#name : #XMLHTMLNonHTMLCodeSectionState,
	#superclass : #XMLHTMLNonHTMLSectionState,
	#category : #'XML-ParserHTML-Core-Drivers'
}

{ #category : #tokenizing }
XMLHTMLNonHTMLCodeSectionState >> nextTokenFrom: aTokenizer [
	^ aTokenizer nextNonHTMLCodeSectionToken
]

"
A context for elements containing non-markup content.
"
Class {
	#name : #XMLHTMLNonHTMLSectionContext,
	#superclass : #XMLContentContext,
	#instVars : [
		'element'
	],
	#category : #'XML-Parser-HTML-Core-Drivers'
}

{ #category : #'instance creation' }
XMLHTMLNonHTMLSectionContext class >> element: anElement [
	^ self new element: anElement
]

{ #category : #accessing }
XMLHTMLNonHTMLSectionContext >> element [
	^ element
]

{ #category : #accessing }
XMLHTMLNonHTMLSectionContext >> element: anElement [
	element := anElement
]

{ #category : #tokenizing }
XMLHTMLNonHTMLSectionContext >> nextTokenFrom: aTokenizer [
	aTokenizer nextNonHTMLSectionToken
]

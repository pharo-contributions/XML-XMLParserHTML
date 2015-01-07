"
A context for elements containing non-markup.
"
Class {
	#name : #XMLHTMLNonHTMLSectionContext,
	#superclass : #XMLContentContext,
	#instVars : [
		'element'
	],
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #'instance creation' }
XMLHTMLNonHTMLSectionContext class >> element: anElementName [
	^ self new element: anElementName
]

{ #category : #accessing }
XMLHTMLNonHTMLSectionContext >> element [
	^ element
]

{ #category : #accessing }
XMLHTMLNonHTMLSectionContext >> element: anElementName [
	element := anElementName
]

{ #category : #tokenizing }
XMLHTMLNonHTMLSectionContext >> nextTokenFrom: aTokenizer [
	aTokenizer nextNonHTMLSectionToken
]
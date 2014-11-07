"
This class adds HTML-specific contexts.
"
Class {
	#name : #XMLHTMLTokenContext,
	#superclass : #XMLTokenContext,
	#instVars : [
		'nonHtmlElement'
	],
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #'changing context' }
XMLHTMLTokenContext >> enterNonHTMLSection: aTagName [
	context := #inNonHTMLSection.
	nonHtmlElement := aTagName.
]

{ #category : #testing }
XMLHTMLTokenContext >> isInContent [
	^ super isInContent or: [self isInNonHTMLSection]
]

{ #category : #testing }
XMLHTMLTokenContext >> isInNonHTMLSection [
	^ context == #inNonHTMLSection
]

{ #category : #accessing }
XMLHTMLTokenContext >> nonHtmlElement [
	^ nonHtmlElement
]

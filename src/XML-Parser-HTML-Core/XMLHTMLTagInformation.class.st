"
This class is used by the element nester to store information about specific tags and make it faster to lookup.
"
Class {
	#name : #XMLHTMLTagInformation,
	#superclass : #Object,
	#instVars : [
		'name',
		'isBodySectionTag',
		'isHeadSectionTag',
		'isNonNestable',
		'isSelfClosing',
		'mutuallyExcludingTag',
		'nestableTagGroup'
	],
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #'instance creation' }
XMLHTMLTagInformation class >> named: aName [
	^ self new name: aName
]

{ #category : #initialization }
XMLHTMLTagInformation >> initialize [
	super initialize.

	isBodySectionTag := false.
	isHeadSectionTag := false.
	isNonNestable := false.
	isSelfClosing := false.
	nestableTagGroup := #().
]

{ #category : #testing }
XMLHTMLTagInformation >> isBodySectionOnlyTag [
	^ self isBodySectionTag and: [self isHeadSectionTag not]
]

{ #category : #testing }
XMLHTMLTagInformation >> isBodySectionTag [
	^ isBodySectionTag
]

{ #category : #accessing }
XMLHTMLTagInformation >> isBodySectionTag: aBoolean [
	isBodySectionTag := aBoolean
]

{ #category : #testing }
XMLHTMLTagInformation >> isHeadOrBodyTag [
	^ name = 'body' or: [name = 'head']
]

{ #category : #testing }
XMLHTMLTagInformation >> isHeadSectionOnlyTag [
	^ self isHeadSectionTag and: [self isBodySectionTag not]
]

{ #category : #testing }
XMLHTMLTagInformation >> isHeadSectionTag [
	^ isHeadSectionTag
]

{ #category : #accessing }
XMLHTMLTagInformation >> isHeadSectionTag: aBoolean [
	isHeadSectionTag := aBoolean
]

{ #category : #testing }
XMLHTMLTagInformation >> isNonNestable [
	^ isNonNestable
]

{ #category : #accessing }
XMLHTMLTagInformation >> isNonNestable: aBoolean [
	isNonNestable := aBoolean
]

{ #category : #testing }
XMLHTMLTagInformation >> isSelfClosing [
	^ isSelfClosing
]

{ #category : #accessing }
XMLHTMLTagInformation >> isSelfClosing: aBoolean [
	isSelfClosing := aBoolean
]

{ #category : #accessing }
XMLHTMLTagInformation >> mutuallyExcludingTag [
	^ mutuallyExcludingTag
]

{ #category : #accessing }
XMLHTMLTagInformation >> mutuallyExcludingTag: aName [
	mutuallyExcludingTag := aName
]

{ #category : #accessing }
XMLHTMLTagInformation >> name [
	^ name
]

{ #category : #accessing }
XMLHTMLTagInformation >> name: aName [
	name := aName
]

{ #category : #accessing }
XMLHTMLTagInformation >> nestableTagGroup [
	^ nestableTagGroup
]

{ #category : #accessing }
XMLHTMLTagInformation >> nestableTagGroup: aNameCollection [
	nestableTagGroup := aNameCollection
]

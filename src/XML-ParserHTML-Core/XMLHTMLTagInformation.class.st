"
This class is used by the element nester to store information about tags for faster lookup.
"
Class {
	#name : #XMLHTMLTagInformation,
	#superclass : #Object,
	#instVars : [
		'name',
		'isHTMLTag',
		'isHeadTag',
		'isBodyTag',
		'isBodySectionTag',
		'isHeadSectionTag',
		'isNonNestable',
		'mutuallyExcludingTag',
		'nestableTagGroup'
	],
	#category : #'XML-ParserHTML-Core-Drivers'
}

{ #category : #'instance creation' }
XMLHTMLTagInformation class >> name: aName [
	^ self named: aName
]

{ #category : #'instance creation' }
XMLHTMLTagInformation class >> named: aName [
	^ self new name: aName
]

{ #category : #initialization }
XMLHTMLTagInformation >> initialize [
	super initialize.

	isHTMLTag := false.
	isHeadTag := false.
	isBodyTag := false.
	isBodySectionTag := false.
	isHeadSectionTag := false.
	isNonNestable := false.
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
XMLHTMLTagInformation >> isBodyTag [
	^ isBodyTag
]

{ #category : #testing }
XMLHTMLTagInformation >> isHTMLTag [
	^ isHTMLTag
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
XMLHTMLTagInformation >> isHeadTag [
	^ isHeadTag
]

{ #category : #testing }
XMLHTMLTagInformation >> isNonNestable [
	^ isNonNestable
]

{ #category : #accessing }
XMLHTMLTagInformation >> isNonNestable: aBoolean [
	isNonNestable := aBoolean
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
	name := aName.
	isHTMLTag := name = 'html'.
	isHeadTag := name = 'head'.
	isBodyTag := name = 'body'.
]

{ #category : #accessing }
XMLHTMLTagInformation >> nestableTagGroup [
	^ nestableTagGroup
]

{ #category : #accessing }
XMLHTMLTagInformation >> nestableTagGroup: aNameCollection [
	nestableTagGroup := aNameCollection
]

{ #category : #printing }
XMLHTMLTagInformation >> printOn: aStream [
	super printOn: aStream.

	aStream
		nextPutAll: '(<';
		nextPutAll: self name;
		nextPutAll: '>)'.
]

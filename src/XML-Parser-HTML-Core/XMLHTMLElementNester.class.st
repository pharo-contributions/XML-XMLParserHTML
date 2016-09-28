"
This class can handle the nesting of HTML elements missing closing tags or with opening and closing tags in the wrong order.
"
Class {
	#name : #XMLHTMLElementNester,
	#superclass : #XMLElementNester,
	#instVars : [
		'openElementsByName',
		'startedHTMLSection',
		'startedHeadSection',
		'startedBodySection'
	],
	#classVars : [
		'HTMLTagInformation',
		'RedundantEndTags',
		'VoidElements'
	],
	#category : #'XML-Parser-HTML-Core-Drivers'
}

{ #category : #private }
XMLHTMLElementNester class >> bodySectionElements [
	^ #('a' 'abbr' 'acronym' 'address' 'applet'
		'area' 'article' 'aside' 'audio' 'b'
		'basefont' 'bdi' 'bdo' 'big' 'blockquote'
		'br' 'button' 'canvas' 'caption' 'center'
		'cite' 'code' 'col' 'colgroup' 'command'
		'data' 'datagrid' 'datalist' 'dd' 'del'
		'details' 'dfn' 'dir' 'div' 'dl'
		'dt' 'em' 'embed' 'eventsource' 'fieldset'
		'figcaption' 'figure' 'font' 'footer' 'form'
		'frame' 'frameset' 'h1' 'h2' 'h3'
		'h4' 'h5' 'h6' 'header' 'hgroup'
		'hr' 'i' 'iframe' 'img' 'input'
		'ins' 'kbd' 'keygen' 'label' 'legend'
		'li' 'map' 'mark' 'menu' 'meter' 'nav'
		'noframes' 'noscript' 'object' 'ol' 'optgroup'
		'option' 'output' 'p' 'param' 'pre'
		'progress' 'q' 'rp' 'rt' 'ruby'
		's' 'samp' 'script' 'section' 'select'
		'small' 'source' 'span' 'strike' 'strong'
		'style' 'sub' 'summary' 'sup' 'table'
		'tbody' 'td' 'textarea' 'tfoot' 'th'
		'thead' 'time' 'tr' 'track' 'tt'
		'u' 'ul' 'var' 'video' 'wbr')
]

{ #category : #private }
XMLHTMLElementNester class >> headSectionElements [
	^ #('base' 'isindex' 'link' 'meta' 'noscript'
		'object' 'script' 'style' 'template' 'title')
]

{ #category : #private }
XMLHTMLElementNester class >> htmlTagInformationIn: aDictionary named: aName [
	^ aDictionary
		at: aName
		ifAbsentPut: [XMLHTMLTagInformation named: aName]
]

{ #category : #'class initialization' }
XMLHTMLElementNester class >> initialize [
	"self initialize"

	self
		initializeHTMLTagInformation;
		initializeVoidElements;
		initializeRedundantEndTags
]

{ #category : #'class initialization' }
XMLHTMLElementNester class >> initializeHTMLTagInformation [
	| temp |

	"use a temp to fully initialize it before assignment to avoid
	possible race conditions during class reinitialization"
	temp := Dictionary new.

	#('html' 'head' 'body') do: [:each |
		self
			htmlTagInformationIn: temp
			named: each].

	self bodySectionElements do: [:each |
		(self
			htmlTagInformationIn: temp
			named: each) isBodySectionTag: true].
	self headSectionElements do: [:each |
		(self
			htmlTagInformationIn: temp
			named: each) isHeadSectionTag: true].

	self mutuallyExcludingTags keysAndValuesDo: [:key :value |
		(self
			htmlTagInformationIn: temp
			named: key) mutuallyExcludingTag: value].
	self nestableTagGroups keysAndValuesDo: [:key :value |
		(self
			htmlTagInformationIn: temp
			named: key) nestableTagGroup: value].

	self nonNestableElements do: [:each |
		(self
			htmlTagInformationIn: temp
			named: each) isNonNestable: true].

	HTMLTagInformation := temp.
]

{ #category : #'class initialization' }
XMLHTMLElementNester class >> initializeRedundantEndTags [
	"assign after with #yourself to avoid possible race
	conditions when reinitializing the class"
	RedundantEndTags :=
		self voidElements asSet
			"html/body are redundant end tags because they
			should remain open until the end"
			addAll: #('html' 'body');
			yourself
]

{ #category : #'class initialization' }
XMLHTMLElementNester class >> initializeVoidElements [
	VoidElements := self voidElements asSet
]

{ #category : #private }
XMLHTMLElementNester class >> mutuallyExcludingTags [
	| mutuallyExcludingTags |

	mutuallyExcludingTags := Dictionary new.
	#(#('dd' 'dt') #('thead' 'tbody') #('th' 'td') #('rp' 'rt'))
		do: [:tagList |
			tagList do: [:tag |
				tagList do: [:each |
					(each = tag)
						ifFalse: [
							mutuallyExcludingTags
								at: each
								put: tag]]]].
	^ mutuallyExcludingTags.
]

{ #category : #private }
XMLHTMLElementNester class >> nestableTagGroups [
	| nestableTagGroups |

	nestableTagGroups := Dictionary new.
	#('dd' 'dt') do: [:each |
		nestableTagGroups
			at: each
			put: #('dl')].
	#('tr' 'th' 'td' 'thead' 'tfoot') do: [:each |
		nestableTagGroups
			at: each
			put: #('table')].
	#('rp' 'rt') do: [:each |
		nestableTagGroups
			at: each
			put: #('ruby')].
	nestableTagGroups
		at: 'li'
		put: #('ul' 'ol' 'menu' 'dir') asSet.
	^ nestableTagGroups.
]

{ #category : #private }
XMLHTMLElementNester class >> nonNestableElements [
	^ #('a' 'applet' 'audio' 'button' 'footer'
		'form' 'header' 'label' 'map' 'meter'
		'optgroup' 'option' 'ruby' 'select' 'video'),
		self nestableTagGroups keys asArray
]

{ #category : #private }
XMLHTMLElementNester class >> voidElements [
	^ #('area' 'base' 'br' 'col' 'command'
		'embed' 'frame' 'hr' 'img' 'input'
		'keygen' 'link' 'menuitem' 'meta' 'param'
		'source' 'track' 'wbr')
]

{ #category : #checking }
XMLHTMLElementNester >> beforeEnding: anElement elementsToEndDo: anElementEndingBlock [
	self openElementsReverseDo: [:each |
		each = anElement
			ifTrue: [^ self].
		anElementEndingBlock value: each].
]

{ #category : #checking }
XMLHTMLElementNester >> beforePCDataElementsToEndDo: anElementEndingBlock elementsToStartDo: anElementStartingBlock [
	(self startedHeadSection
		and: [self startedBodySection not])
		ifTrue: [
			self
				beforeEnding: 'html'
				elementsToEndDo: anElementEndingBlock].
	self startedHTMLSection
		ifFalse: [anElementStartingBlock value: 'html'].
	self startedBodySection
		ifFalse: [anElementStartingBlock value: 'body'].
]

{ #category : #checking }
XMLHTMLElementNester >> beforeStarting: anElement elementsToEndDo: anElementEndingBlock elementsToStartDo: anElementStartingBlock [
	| htmlTagInfo |

	htmlTagInfo :=
		HTMLTagInformation
			at: anElement
			ifAbsent: [XMLHTMLTagInformation named: anElement].
			
	self hasOpenElements
		ifTrue: [
			self
				elementsToEndBeforeStartTag: htmlTagInfo
				do: anElementEndingBlock].
	self
		elementsToStartBeforeStartTag: htmlTagInfo
		do: anElementStartingBlock.
]

{ #category : #private }
XMLHTMLElementNester >> cannotSelfNestTag: anHTMLTagInfo [
	anHTMLTagInfo isNonNestable
		ifTrue: [	| tagGroup |
			"tags like <td> can nest in each other if there is a <table> between
			them like <td><table><tr><td>...."
			((tagGroup := anHTMLTagInfo nestableTagGroup)
				anySatisfy: [:each | self hasOpenElement: each])
				ifFalse: [^ true].

			self openElementsReverseDo: [:each |
				each = anHTMLTagInfo name
					ifTrue: [^ true].
				(tagGroup includes: each)
					ifTrue: [^ false]]].
	^ false.
]

{ #category : #private }
XMLHTMLElementNester >> elementsToEndBeforeStartTag: anHTMLTagInfo do: anElementEndingBlock [
	| excludingTag |

	(self mustEndHeadSectionForTag: anHTMLTagInfo)
		ifTrue: [
			^ self
				beforeEnding: 'html'
				elementsToEndDo: anElementEndingBlock].

	(((self hasOpenElement: anHTMLTagInfo name)
		and: [self cannotSelfNestTag: anHTMLTagInfo])
		or: [(excludingTag := anHTMLTagInfo mutuallyExcludingTag) notNil
			and: [self hasOpenElement: excludingTag]])
		ifTrue: [
			self openElementsReverseDo: [:each |
				anElementEndingBlock value: each.
				((each = anHTMLTagInfo name)
					or: [each = excludingTag])
					ifTrue: [^ self]]].
]

{ #category : #private }
XMLHTMLElementNester >> elementsToStartBeforeStartTag: anHTMLTagInfo do: anElementStartingBlock [
	anHTMLTagInfo isHTMLTag
		ifTrue: [^ self].
	self startedHTMLSection
		ifFalse: [anElementStartingBlock value: 'html'].
	(anHTMLTagInfo isHeadTag
		or: [anHTMLTagInfo isBodyTag])
		ifTrue: [^ self]. 

	(self mustStartHeadSectionForTag: anHTMLTagInfo)
		ifTrue: [anElementStartingBlock value: 'head']
		ifFalse: [
			(self mustStartBodySectionForTag: anHTMLTagInfo)
				ifTrue: [anElementStartingBlock value: 'body']].
]

{ #category : #checking }
XMLHTMLElementNester >> endElement: anElement [
	| association |

	association :=
		self openElementsByName
			associationAt: anElement
			ifAbsent: [self openElementsByName add: (anElement -> 1)].
	association value: (association value - 1 max: 0).

	super endElement: anElement.
]

{ #category : #testing }
XMLHTMLElementNester >> hasOpenElement: anElement [
	^ (self openElementsByName
		at: anElement
		ifAbsent: [0]) > 0
]

{ #category : #initialization }
XMLHTMLElementNester >> initialize [
	super initialize.

	openElementsByName := Dictionary new.
	startedHTMLSection := false.
	startedHeadSection := false.
	startedBodySection := false.
]

{ #category : #testing }
XMLHTMLElementNester >> isRedundantEndTag: anElement [
	^ RedundantEndTags includes: anElement
]

{ #category : #testing }
XMLHTMLElementNester >> isRedundantStartTag: anElement [
	anElement = 'html'
		ifTrue: [^ self startedHTMLSection].
	anElement = 'head'
		ifTrue: [^ self startedHeadSection].
	anElement = 'body'
		ifTrue: [^ self startedBodySection].
	^ false.
]

{ #category : #testing }
XMLHTMLElementNester >> isVoidElement: anElement [
	^ VoidElements includes: anElement
]

{ #category : #private }
XMLHTMLElementNester >> mustEndHeadSectionForTag: anHTMLTagInfo [
	^ self startedBodySection not
		and: [self startedHeadSection
			and: [anHTMLTagInfo isBodyTag
				or: [anHTMLTagInfo isBodySectionOnlyTag]]]
]

{ #category : #private }
XMLHTMLElementNester >> mustStartBodySectionForTag: anHTMLTagInfo [
	^ self startedBodySection not
		and: [anHTMLTagInfo isBodySectionOnlyTag
			or: [self startedHeadSection not
				and: [anHTMLTagInfo isHeadSectionOnlyTag not]]]
]

{ #category : #private }
XMLHTMLElementNester >> mustStartHeadSectionForTag: anHTMLTagInfo [
	^ self startedBodySection not
		and: [self startedHeadSection not
			and: [anHTMLTagInfo isHeadSectionOnlyTag]]
]

{ #category : #private }
XMLHTMLElementNester >> openElementsByName [
	^ openElementsByName
]

{ #category : #checking }
XMLHTMLElementNester >> startElement: anElement [
	| association |

	association :=
		self openElementsByName
			associationAt: anElement
			ifAbsent: [self openElementsByName add: (anElement -> 0)].
	association value: association value + 1.

	self startedHTMLSection
		ifTrue: [
			self startedBodySection
				ifFalse: [
					(self startedHeadSection not
						and: [anElement = 'head']) 
						ifTrue: [startedHeadSection := true]
						ifFalse: [startedBodySection := anElement = 'body']]]
		ifFalse: [startedHTMLSection := anElement = 'html'].

	super startElement: anElement.
]

{ #category : #testing }
XMLHTMLElementNester >> startedBodySection [
	^ startedBodySection
]

{ #category : #testing }
XMLHTMLElementNester >> startedHTMLSection [
	^ startedHTMLSection
]

{ #category : #testing }
XMLHTMLElementNester >> startedHeadSection [
	^ startedHeadSection
]

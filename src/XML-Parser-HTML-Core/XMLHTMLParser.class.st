"
This class is a DOM parser that turns potentially invalid and malformed HTML into a DOM tree. All tag and attribute names are converted to lowercase and markup is unrecognized in <script>, <style>, <title>, and <textarea> sections.

(When printing the DOM tree, use printWithoutSelfClosingTagsOn: or printedWithoutSelfClosingTags instead of printOn:, printString, or asString to avoid empty elements being printed as self-closing tags, because some (like <script/>) are not handled correctly by browsers.)
"
Class {
	#name : #XMLHTMLParser,
	#superclass : #XMLDOMParser,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #private }
XMLHTMLParser >> driverClass [
	^ SAXHTMLParserDriver
]

{ #category : #'handling - content' }
XMLHTMLParser >> endElement: aQualifiedName prefix: aPrefix uri: aUri localName: aLocalName [
	self topNode
		ifNotNil: [:node |
			(node isElement
				and: [node name = aQualifiedName])
				ifTrue: [self popNode]].
]

{ #category : #private }
XMLHTMLParser >> pushInnerXMLRootNode: aRootNode [
	aRootNode ancestorNodes reverseDo: [:each | self pushNode: each].
	super pushInnerXMLRootNode: aRootNode.
]

{ #category : #'handling - content' }
XMLHTMLParser >> startElement: aQualifiedName prefix: aPrefix uri: aUri localName: aLocalName attributes: aDictionary [
	| uniqueElement |

	aQualifiedName = 'html'
		ifTrue: [uniqueElement := self uniqueHtmlElement]
		ifFalse: [
			aQualifiedName = 'head'
				ifTrue: [uniqueElement := self uniqueHeadElement]
				ifFalse: [
					aQualifiedName = 'body'
						ifTrue: [uniqueElement := self uniqueBodyElement]]].
	uniqueElement
		ifNotNil: [^ self pushNode: uniqueElement].

	super
		startElement: aQualifiedName
		prefix: aPrefix
		uri: aUri
		localName: aLocalName
		attributes: aDictionary.
]

{ #category : #private }
XMLHTMLParser >> startInnerXMLElement: anElement forParser: aParser [
	| elementNester |

	(elementNester := aParser driver elementNester)
		beforeStarting: anElement name
		elementsToEndDo: [:each | ]
		elementsToStartDo: [:each | elementNester startElement: each];
		startElement: anElement name
]

{ #category : #private }
XMLHTMLParser >> uniqueBodyElement [
	(self document notNil
		and: [self document root notNil])
		ifTrue: [^ self document root elementAt: 'body'].
	^ nil.
]

{ #category : #private }
XMLHTMLParser >> uniqueHeadElement [
	(self document notNil
		and: [self document root notNil])
		ifTrue: [^ self document root elementAt: 'head'].
	^ nil.
]

{ #category : #private }
XMLHTMLParser >> uniqueHtmlElement [
	(self document notNil
		and: [self document root notNil
			and: [self document root isNamed: 'html']])
		ifTrue: [^ self document root].
	^ nil.
]

"
This class is a DOM parser that turns invalid and malformed HTML into a DOM tree. All tag and attribute names are converted to lowercase and markup is unrecognized in <script>, <style>, <title>, and <textarea> sections.

(If printing the DOM tree, use printWithoutSelfClosingTagsOn: or printedWithoutSelfClosingTags to avoid empty elements being printed as self-closing tags, because some (like <script/>) are not handled correctly by browsers.)
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

{ #category : #content }
XMLHTMLParser >> endElement: aQualifiedName prefix: aPrefix uri: aURI localName: aLocalName [
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

{ #category : #private }
XMLHTMLParser >> startInnerXMLElement: anElement forParser: aParser [
	| elementNester |

	(elementNester := aParser driver elementNester)
		beforeStarting: anElement name
		elementsToEndDo: [:each | ]
		elementsToStartDo: [:each | elementNester startElement: each];
		startElement: anElement name
]

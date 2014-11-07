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

{ #category : #content }
XMLHTMLParser >> endElement: anElementName prefix: aPrefix uri: aUri localName: aLocalName [
	(self topNode isElement
		and: [self topNode isNamed: anElementName])
		ifTrue: [self popNode]

]

{ #category : #content }
XMLHTMLParser >> startElement: aQualifiedName prefix: aPrefix uri: aUri localName: aLocalName attributes: aDictionary [
	| element |

	(self document root notNil
		and: [(element := self uniqueElementNamed: aQualifiedName) notNil])
		ifTrue: [
			self pushNode: element.
			^ self].

	super
		startElement: aQualifiedName
		prefix: aPrefix
		uri: aUri
		localName: aLocalName
		attributes: aDictionary.
]

{ #category : #private }
XMLHTMLParser >> uniqueElementNamed: anElementName [
	^ anElementName = 'html'
		ifTrue: [self document root]
		ifFalse: [
			(anElementName = 'head' or: [anElementName = 'body'])
				ifTrue: [self document root elementAt: anElementName]
				ifFalse: [nil]]
]

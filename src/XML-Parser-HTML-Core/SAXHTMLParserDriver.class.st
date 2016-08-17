"
This is a parser driver for messy HTML. It uses XMLHTMLElementNester to make bad HTML nest correctly.
"
Class {
	#name : #SAXHTMLParserDriver,
	#superclass : #SAXParserDriver,
	#category : #'XML-Parser-HTML-Core-Drivers'
}

{ #category : #private }
SAXHTMLParserDriver >> elementNesterClass [
	^ XMLHTMLElementNester
]

{ #category : #private }
SAXHTMLParserDriver >> endElement: anElement [
	| prefix |

	self elementNester endElement: anElement.

	prefix := anElement xmlPrefixBeforeLocalName.	
	self saxHandler 
		endElement: anElement
		prefix: prefix
		uri: ''
		localName: (anElement xmlLocalNameAfterPrefix: prefix)
]

{ #category : #handling }
SAXHTMLParserDriver >> handleCData: aString [
	self handlePCData: aString
]

{ #category : #'handling - dtd' }
SAXHTMLParserDriver >> handleEndDTD [
	self saxHandler endDTD
]

{ #category : #handling }
SAXHTMLParserDriver >> handleEndDocument [
	self elementNester
		openElementsReverseDo: [:each | self endElement: each];
		endNesting.

	self saxHandler endDocument.
]

{ #category : #handling }
SAXHTMLParserDriver >> handleEndTag: anElement [
	(self elementNester isRedundantEndTag: anElement)
		ifTrue: [^ self].
	(self elementNester hasOpenElement: anElement)
		ifFalse: [self startElement: anElement].
		
	self elementNester
		beforeEnding: anElement
		elementsToEndDo: [:each | self endElement: each].
	self endElement: anElement.
]

{ #category : #handling }
SAXHTMLParserDriver >> handleNonHTMLSection: aString [
	self saxHandler characters: aString
]

{ #category : #handling }
SAXHTMLParserDriver >> handlePCData: aString [
	self elementNester
		beforePCDataElementsToEndDo: [:each | self endElement: each]
		elementsToStartDo: [:each | self startElement: each].

	self saxHandler characters: aString.
]

{ #category : #handling }
SAXHTMLParserDriver >> handlePI: aTargetString data: aDataString [
]

{ #category : #handling }
SAXHTMLParserDriver >> handleParseError: anError [
]

{ #category : #'handling - dtd' }
SAXHTMLParserDriver >> handleStartDTD: aRoot publicID: aPublicID systemID: aSystemID [
	self saxHandler
		startDTD: aRoot
		publicID: aPublicID
		systemID: aSystemID.
]

{ #category : #handling }
SAXHTMLParserDriver >> handleStartTag: anElement attributes: aDictionary [
	(self elementNester isRedundantStartTag: anElement)
		ifTrue: [^ self].

	self elementNester
		beforeStarting: anElement
		elementsToEndDo: [:each | self endElement: each]
		elementsToStartDo: [:each | self startElement: each].
	self
		startElement: anElement
		attributes: aDictionary.

	(self elementNester isVoidElement: anElement)
		ifTrue: [self endElement: anElement].
]

{ #category : #handling }
SAXHTMLParserDriver >> handleWhitespace: aString [
	self elementNester isInElement
		ifTrue: [self saxHandler characters: aString]
]

{ #category : #handling }
SAXHTMLParserDriver >> handleXMLVersion: aVersion encoding: anEncoding standalone: aYesOrNo [
	self saxHandler
		xmlVersion:
			([aVersion asNumber]
				on: Error
				do: [:error | 1.0])
		encoding: anEncoding
		standalone: false
]

{ #category : #private }
SAXHTMLParserDriver >> startElement: anElement [
	self
		startElement: anElement
		attributes: (OrderPreservingStringDictionary new: 0)
]

{ #category : #private }
SAXHTMLParserDriver >> startElement: anElement attributes: aDictionary [
	| prefix |

	self elementNester startElement: anElement.

	prefix := anElement xmlPrefixBeforeLocalName.
	self saxHandler 
		startElement: anElement
		prefix: prefix
		uri: ''
		localName: (anElement xmlLocalNameAfterPrefix: prefix)
		attributes: aDictionary.
]

{ #category : #private }
SAXHTMLParserDriver >> tokenizerClass [
	^ XMLHTMLParserTokenizer
]

"
This is the driver for the HTMLHandler. It uses the HTMLElementNester to make bad HTML nest correctly.
"
Class {
	#name : #SAXHTMLParserDriver,
	#superclass : #SAXParserDriver,
	#category : #'XML-Parser-HTML-Core'
}

{ #category : #private }
SAXHTMLParserDriver >> elementNesterClass [
	^ XMLHTMLElementNester
]

{ #category : #private }
SAXHTMLParserDriver >> endElement: anElementName [
	| prefix |

	self elementNester endElement: anElementName.

	prefix := anElementName prefixBeforeLocalName.	
	self saxHandler 
		endElement: anElementName
		prefix: prefix
		uri: ''
		localName: (anElementName localNameAfterPrefix: prefix)
]

{ #category : #handling }
SAXHTMLParserDriver >> handleCData: aString [
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
SAXHTMLParserDriver >> handleEndTag: anElementName [ 
	(self elementNester isVoidElement: anElementName)
		ifTrue: [^ self].
	(self elementNester hasOpenElement: anElementName)
		ifFalse: [self startElement: anElementName].
		
	self elementNester
		beforeEnding: anElementName
		elementsToEndDo: [:each | self endElement: each].
	self endElement: anElementName.
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
SAXHTMLParserDriver >> handleStartTag: anElementName attributes: anAttributeDictionary namespaces: aNamespaceDictionary [
	(self elementNester isOpenUniqueElement: anElementName)
		ifTrue: [^ self].

	self elementNester
		beforeStarting: anElementName
		elementsToEndDo: [:each | self endElement: each]
		elementsToStartDo: [:each | self startElement: each].
	self startElement: anElementName attributes: anAttributeDictionary.

	(self elementNester isVoidElement: anElementName)
		ifTrue: [self endElement: anElementName].
]

{ #category : #handling }
SAXHTMLParserDriver >> handleWhitespace: aString [
	self saxHandler ignorableWhitespace: aString
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
SAXHTMLParserDriver >> startElement: anElementName [
	self
		startElement: anElementName
		attributes: (OrderPreservingStringDictionary new: 5)
]

{ #category : #private }
SAXHTMLParserDriver >> startElement: anElementName attributes: anAttributeDictionary [
	| prefix |

	self elementNester startElement: anElementName.

	prefix := anElementName prefixBeforeLocalName.
	self saxHandler 
		startElement: anElementName
		prefix: prefix
		uri: ''
		localName: (anElementName localNameAfterPrefix: prefix)
		attributes: anAttributeDictionary
]

{ #category : #private }
SAXHTMLParserDriver >> tokenizerClass [
	^ XMLHTMLParserTokenizer
]

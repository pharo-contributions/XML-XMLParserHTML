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

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleCData: aString [
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleEndDTD [
	self saxHandler
		endInternalSubset;
		endDTD.
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleEndDocument [
	self elementNester
		openElementsReverseDo: [:each | self endElement: each];
		endNesting.

	self saxHandler endDocument.
]

{ #category : #'handling tokens' }
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

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleNonHTMLSection: aString [
	self saxHandler characters: aString
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handlePCData: aString [
	self elementNester
		beforePCDataElementsToEndDo: [:each | self endElement: each]
		elementsToStartDo: [:each | self startElement: each].

	self saxHandler characters: aString.
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handlePI: piTarget data: piData [
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleParseError: anError [
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleStartDTD: aRoot publicID: aPublicId systemID: aSystemId [
	self saxHandler
		startDTD: aRoot
		publicID: aPublicId
		systemID: aSystemId;
		startInternalSubset.
]

{ #category : #'handling tokens' }
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

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleWhitespace: aString [
	self saxHandler ignorableWhitespace: aString
]

{ #category : #'handling tokens' }
SAXHTMLParserDriver >> handleXMLVersion: aVersion encoding: anEncoding standalone: aYesOrNo [
	self saxHandler
		xmlVersion: ([aVersion asNumber] on: Error do: [:error | 1.0])
		encoding: (anEncoding ifEmpty: 'UTF-8')
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

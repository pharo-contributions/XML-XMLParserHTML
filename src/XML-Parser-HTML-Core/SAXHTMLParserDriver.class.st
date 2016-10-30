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

{ #category : #handling }
SAXHTMLParserDriver >> handleCData: aString [
	self handlePCData: aString
]

{ #category : #'handling - dtd' }
SAXHTMLParserDriver >> handleEndDTD [
	self saxHandler endDTD
]

{ #category : #handling }
SAXHTMLParserDriver >> handleEndTag: anElement [
	| prefix |

	prefix := anElement xmlPrefixBeforeLocalName.	
	self saxHandler 
		endElement: anElement
		prefix: prefix
		uri: ''
		localName: (anElement xmlLocalNameAfterPrefix: prefix).
]

{ #category : #handling }
SAXHTMLParserDriver >> handleNonHTMLSection: aString [
	self saxHandler characters: aString
]

{ #category : #handling }
SAXHTMLParserDriver >> handlePCData: aString [
	self saxHandler characters: aString
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
	| prefix |

	prefix := anElement xmlPrefixBeforeLocalName.
	self saxHandler 
		startElement: anElement
		prefix: prefix
		uri: ''
		localName: (anElement xmlLocalNameAfterPrefix: prefix)
		attributes: aDictionary.
]

{ #category : #handling }
SAXHTMLParserDriver >> handleWhitespace: aString [
	self saxHandler characters: aString
]

{ #category : #handling }
SAXHTMLParserDriver >> handleXMLVersion: aVersion encoding: anEncoding standalone: aYesOrNo [
	self saxHandler
		xmlVersion:
			([Float readFrom: aVersion readStream]
				on: Error
				do: [:error | 1.0])
		encoding: anEncoding
		standalone: aYesOrNo = 'yes'
]

{ #category : #private }
SAXHTMLParserDriver >> tokenizerClass [
	^ XMLHTMLParserTokenizer
]

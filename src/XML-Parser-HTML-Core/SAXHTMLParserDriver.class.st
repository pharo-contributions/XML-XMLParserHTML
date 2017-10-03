"
This is a parser driver for messy HTML. It uses XMLHTMLElementNester to make bad HTML nest correctly.
"
Class {
	#name : #SAXHTMLParserDriver,
	#superclass : #SAXParserDriver,
	#instVars : [
		'deferredEvents',
		'isDeferringEvents'
	],
	#category : #'XML-Parser-HTML-Core-Drivers'
}

{ #category : #private }
SAXHTMLParserDriver >> deferEventSelector: aSelector [
	^ self
		deferEventSelector: aSelector
		arguments: Array new
]

{ #category : #private }
SAXHTMLParserDriver >> deferEventSelector: aSelector argument: anArgument [
	^ self
		deferEventSelector: aSelector
		arguments: (Array with: anArgument)
]

{ #category : #private }
SAXHTMLParserDriver >> deferEventSelector: aSelector arguments: anArgumentArray [
	^ deferredEvents addLast:
		(MessageSend
			receiver: self saxHandler
			selector: aSelector
			arguments: anArgumentArray)
]

{ #category : #defaults }
SAXHTMLParserDriver >> elementNesterClass [
	^ XMLHTMLElementNester
]

{ #category : #handling }
SAXHTMLParserDriver >> handleCData: aString [
	self handlePCData: aString
]

{ #category : #handling }
SAXHTMLParserDriver >> handleComment: aString [
	self isDeferringEvents
		ifTrue: [
			self
				deferEventSelector: #comment:
				argument: aString]
		ifFalse: [self saxHandler comment: aString]
]

{ #category : #'handling - dtd' }
SAXHTMLParserDriver >> handleEndDTD [
	self saxHandler endDTD
]

{ #category : #handling }
SAXHTMLParserDriver >> handleEndDocument [
	self hasDeferredEvents
		ifTrue: [self processDeferredEvents].
	self saxHandler endDocument.
]

{ #category : #handling }
SAXHTMLParserDriver >> handleEndTag: anElement [
	| prefix localName |

	prefix := anElement xmlPrefixBeforeLocalName.
	localName := anElement xmlLocalNameAfterPrefix: prefix.	
	(self isDeferringEvents
		or: [anElement = 'body'])
		ifTrue: [
			isDeferringEvents := true.
			self
				deferEventSelector: #endElement:prefix:uri:localName:
				arguments:
					(Array
						with: anElement
						with: prefix
						with: ''
						with: localName)]
		ifFalse: [
			self saxHandler
				endElement: anElement
				prefix: prefix
				uri: ''
				localName: localName].
]

{ #category : #handling }
SAXHTMLParserDriver >> handlePCData: aString [
	self isDeferringEvents
		ifTrue: [self processNonTerminatingDeferredEvents].
	self saxHandler characters: aString.
]

{ #category : #handling }
SAXHTMLParserDriver >> handlePI: aTargetString data: aDataString [
	self isDeferringEvents
		ifTrue: [
			self
				deferEventSelector: #processingInstruction:data:
				arguments:
					(Array
						with: aTargetString
						with: aDataString)]
		ifFalse: [
			self saxHandler 
				processingInstruction: aTargetString
				data: aDataString]
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
SAXHTMLParserDriver >> handleStartTag: anElement attributes: anAttributeDictionary [
	| prefix localName |

	prefix := anElement xmlPrefixBeforeLocalName.
	localName := anElement xmlLocalNameAfterPrefix: prefix.
	self isDeferringEvents
		ifTrue: [self processNonTerminatingDeferredEvents].
	self saxHandler 
		startElement: anElement
		prefix: prefix
		uri: ''
		localName: localName
		attributes: anAttributeDictionary.
]

{ #category : #handling }
SAXHTMLParserDriver >> handleWhitespace: aString [
	self isDeferringEvents
		ifTrue: [
			self
				deferEventSelector: #characters:
				argument: aString]
		ifFalse: [self saxHandler characters: aString]
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

{ #category : #testing }
SAXHTMLParserDriver >> hasDeferredEvents [
	^ self isDeferringEvents
		and: [deferredEvents notEmpty]
]

{ #category : #testing }
SAXHTMLParserDriver >> isDeferringEvents [
	^ isDeferringEvents
]

{ #category : #private }
SAXHTMLParserDriver >> processDeferredEvents [
	[deferredEvents isEmpty]
		whileFalse: [deferredEvents removeFirst value]
]

{ #category : #private }
SAXHTMLParserDriver >> processNonTerminatingDeferredEvents [
	[deferredEvents isEmpty]
		whileFalse: [| deferredMessage |
			deferredMessage := deferredEvents removeFirst. 
			(deferredMessage selector == #endElement:prefix:uri:localName:
				and: [#('body' 'html') includes: deferredMessage arguments first])
				ifFalse: [deferredMessage value]]
]

{ #category : #initialization }
SAXHTMLParserDriver >> setSAXHandler: aSAXHandler [
	super setSAXHandler: aSAXHandler.

	isDeferringEvents := false.
	deferredEvents := OrderedCollection new: 5.
]

{ #category : #defaults }
SAXHTMLParserDriver >> tokenizerClass [
	^ XMLHTMLParserTokenizer
]

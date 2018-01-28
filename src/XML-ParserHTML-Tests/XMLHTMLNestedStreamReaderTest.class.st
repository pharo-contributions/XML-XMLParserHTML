Class {
	#name : #XMLHTMLNestedStreamReaderTest,
	#superclass : #XMLNestedStreamReaderTest,
	#category : #'XML-ParserHTML-Tests'
}

{ #category : #accessing }
XMLHTMLNestedStreamReaderTest >> separators [
	^ Character xmlWhitespace
]

{ #category : #accessing }
XMLHTMLNestedStreamReaderTest >> streamReaderClass [
	^ XMLHTMLNestedStreamReader
]

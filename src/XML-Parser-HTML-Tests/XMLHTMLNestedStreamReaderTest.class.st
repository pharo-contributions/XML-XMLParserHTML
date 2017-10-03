Class {
	#name : #XMLHTMLNestedStreamReaderTest,
	#superclass : #XMLNestedStreamReaderTest,
	#category : #'XML-Parser-HTML-Tests'
}

{ #category : #accessing }
XMLHTMLNestedStreamReaderTest >> separators [
	^ Character xmlWhitespace
]

{ #category : #accessing }
XMLHTMLNestedStreamReaderTest >> streamReaderClass [
	^ XMLHTMLNestedStreamReader
]

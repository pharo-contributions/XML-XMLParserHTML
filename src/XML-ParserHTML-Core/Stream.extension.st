Extension { #name : #Stream }

{ #category : #'*XML-ParserHTML-Core' }
Stream >> parseHTML [
	^ XMLHTMLParser parse: self
]

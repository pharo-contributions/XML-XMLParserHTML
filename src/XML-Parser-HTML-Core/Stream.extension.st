Extension { #name : #Stream }

{ #category : #'*XML-Parser-HTML-Core' }
Stream >> parseHTML [
	^ XMLHTMLParser parse: self
]

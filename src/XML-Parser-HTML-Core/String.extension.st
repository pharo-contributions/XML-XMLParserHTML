Extension { #name : #String }

{ #category : #'*XML-Parser-HTML-Core' }
String >> parseHTML [
	^ XMLHTMLParser parse: self
]

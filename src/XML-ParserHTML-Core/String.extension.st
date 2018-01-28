Extension { #name : #String }

{ #category : #'*XML-ParserHTML-Core' }
String >> parseHTML [
	^ XMLHTMLParser parse: self
]

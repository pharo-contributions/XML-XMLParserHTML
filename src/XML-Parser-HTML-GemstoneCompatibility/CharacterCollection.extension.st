Extension { #name : #CharacterCollection }

{ #category : #'*XML-Parser-HTML-GemstoneCompatibility' }
CharacterCollection >> parseHTML [
	^ XMLHTMLParser parse: self
]

Extension { #name : #CharacterCollection }

{ #category : #'*XML-ParserHTML-GemstoneCompatibility' }
CharacterCollection >> parseHTML [
	^ XMLHTMLParser parse: self
]

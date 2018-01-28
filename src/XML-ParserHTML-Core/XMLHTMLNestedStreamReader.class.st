"
A subclass for HTML that supports case-insensitive hex integer prefixes and a wider set of HTML separator characters.
"
Class {
	#name : #XMLHTMLNestedStreamReader,
	#superclass : #XMLNestedStreamReader,
	#category : #'XML-ParserHTML-Core-Drivers'
}

{ #category : #positioning }
XMLHTMLNestedStreamReader >> skipSeparators [
	"Should be identical to the superclass #skipSeparators, except
	it uses #isXMLWhitespace instead of the narrower, XML-specific
	#isXMLSeparator.

	This code is heavily optimized."

	| isExternalNormalizedLineEnding |

	[peekChar
		ifNil: [
			stream atEnd
				ifTrue: [
					self hasNextAfterPoppingStreamsAtEnd
						ifFalse: [^ self]].
			peekChar := stream next.
			isExternal
				ifTrue: [
					peekChar == LFCharacter
						ifTrue: [isExternalNormalizedLineEnding := true]
						ifFalse: [
							peekChar == CRCharacter
								ifTrue: [
									stream atEnd
										ifFalse: [
											stream peek == LFCharacter
												ifTrue: [stream next]].
									isExternalNormalizedLineEnding := true]
								ifFalse: [
									isExternalNormalizedLineEnding := false.
									"nil understands #isXMLWhitespace, so it
									isn't tested for first"
									peekChar isXMLWhitespace]]]
				ifFalse: [
					"nil understands #isXMLWhitespace, so it isn't tested for first"
					peekChar isXMLWhitespace]]
			ifNotNil: [
				isExternal
					ifTrue: [
						isExternalNormalizedLineEnding :=
							peekChar == normalizedLineEndingChar].
				peekChar isXMLWhitespace]]
		whileTrue: [
			"inlined from #next"
			peekChar := nil.
			isExternal
				ifTrue: [
					currentPosition := currentPosition + 1.
					isExternalNormalizedLineEnding
						ifTrue: [
							currentLineNumber := currentLineNumber + 1.
							currentLineStartPosition := currentPosition].
			readLimit
				ifNotNil: [
					(readLimit := readLimit - 1) >= 0
						ifFalse: [self errorReadLimitExceeded]]]]
]

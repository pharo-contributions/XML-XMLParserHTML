Class {
	#name : #XMLHTMLParserTest,
	#superclass : #TestCase,
	#category : #'XML-Parser-HTML-Tests'
}

{ #category : #benchmarking }
XMLHTMLParserTest >> benchmark1 [
	"
	self new benchmark1
	"
	Smalltalk garbageCollect.
	^ [4000 timesRepeat: [SAXHTMLHandler parse: XMLParserTest addressBookXML]] timeToRun
]

{ #category : #benchmarking }
XMLHTMLParserTest >> benchmark2 [
	"
	self new benchmark2
	"
	Smalltalk garbageCollect.
	^ [4000 timesRepeat: [XMLHTMLParser parse: XMLParserTest addressBookXML]] timeToRun
]

{ #category : #tests }
XMLHTMLParserTest >> testDecodingCharacters [
	self assert:
		(XMLHTMLParser parse: '&#60; &#x3C &#X3E &#62; &#0; &#-1 &#invalid; &#invalid &#')
			contentString = '< < > > &#0; &#-1 &#invalid; &#invalid &#'.
]

{ #category : #tests }
XMLHTMLParserTest >> testHTMLEntities [
	| entity character string |

	entity := 'nbsp'.
	character := XMLHTMLParserTokenizer predefinedEntities at: entity.
	string :=
		((XMLHTMLParser parse: '<p>&', entity, ';&', entity, '</p>')
			findElementNamed: 'p') contentString.
	self
		assert: string size = 2;
		assert: string first == character;
		assert: string second == character.
		
	self assert:
		((XMLHTMLParser parse: '<body>&undeclared; &undeclared &;')
			findElementNamed: 'body') contentString = '&undeclared; &undeclared &;'.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingAttributes [
	| document element |

	document := XMLHTMLParser parse: '<test one="quoted" two=''subQuoted'' three=unquoted four'.
	element := document findElementNamed: 'test'.
	self
		assert: (element attributeAt: 'one') = 'quoted';
		assert: (element attributeAt: 'two') = 'subQuoted';
		assert: (element attributeAt: 'three') = 'unquoted';
		assert: (element attributeAt: 'four') isEmpty.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingCDATA [
	| document |

	document := XMLHTMLParser parse: '<body><![CDATA[ignored]]></body>'.
	self deny: (document findElementNamed: 'body') hasChildren.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingForms [
	| document |

	document := XMLHTMLParser parse: '<form><input><form><input>'.

	self assert:
		(document allElements asArray collect: [:each | each name]) =
			#('html' 'body' 'form' 'input' 'form' 'input').

	document allElementsNamed: 'form' do: [:each |
		self
			assert: each elements size = 1;
			assert: (each firstElement isNamed: 'input')].
	document allElementsNamed: 'input' do: [:each |
		self deny: each hasChildren].
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingImplicitStartTag [
	| paragraphs |

	paragraphs := (XMLHTMLParser parse: '</p></p>') allElementsNamed: 'p'.
	self
		assert: paragraphs size = 2;
		deny: (paragraphs anySatisfy: [:each | each hasChildren]).
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingInvalidPCData [
	| document |

	#('< one & two >' '& three < four >') do: [:each |
		document := XMLHTMLParser parse: each.
		self
			assert: document allNodes size = 4;
			assert: (document findElementNamed: 'body') contentString = each].
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingNonHTMLSections [
	| document |

	document := XMLHTMLParser parse:
		'<head><Title><b>"title</b></TITLE><SCRIPT>',
		'1 < 2; 3 > 2; document.write("</Script>");</Script>
		<Style>//"</STYLE><HEAD>'.
	self
		assert: (document findElementNamed: 'title') contentString = '<b>"title</b>';
		assert: (document findElementNamed: 'script') contentString =
			'1 < 2; 3 > 2; document.write("</Script>");';
		assert: (document findElementNamed: 'style') contentString = '//"'.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingTables [
	| document tables trs tds |

	document := XMLHTMLParser parse: '<table><tr><td>one<td>two<tr><td>three<table><tr><td>four'.
	self assert:
		(document allElements asArray collect: [:each | each name]) =
			#('html' 'body' 'table' 'tr' 'td' 'td' 'tr' 'td' 'table' 'tr' 'td').

	tables := document allElementsNamed: 'table'.
	self
		assert: tables first elements size = 2;
		assert: tables second elements size = 1.
	tables do: [:each | self assert: (each elements allSatisfy: [:element | element isNamed: 'tr'])].

	trs := document allElementsNamed: 'tr'.
	self
		assert: trs first elements size = 2;
		assert: trs second elements size = 1;
		assert: trs third elements size = 1.
	trs do: [:each | self assert: (each elements allSatisfy: [:element | element isNamed: 'td'])].

	tds := document allElementsNamed: 'td'.
	self
		assert: tds first contentString = 'one';
		assert: tds second contentString = 'two';
		assert: tds third contentString = 'three four';
		assert: (tds third nodes second isNamed: 'table').
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingText [
	| document |
	
	document := XMLHTMLParser parse: 'text'.
	self
		assert: document allNodes size = 4;
		assert: (document allElementsCollect: [:each | each name]) asArray = #('html' 'body');
		assert: (document findElementNamed: 'body') contentString = 'text'.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingVoidElements [
	| document |

	document := XMLHTMLParser parse: '<body>one<img>two</img><body>three'.
	self
		assert: (document allElementsCollect: [:each | each name]) asArray = #('html' 'body' 'img');
		assert: (document findElementNamed: 'body') contentString = 'one twothree';
		deny: (document findElementNamed: 'img') hasChildren.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingXML [
	self
		shouldnt: [
			SAXHTMLHandler
				parse: XMLParserTest addressBookXML;
				parse: XMLParserTest addressBookXMLWithDTD;
				parse: XMLDOMParserTest addressBookNamespacedXML;
				parse: XMLDOMParserTest addressBookNamespacePrefixedXML]
		raise: XMLParserException
]

{ #category : #tests }
XMLHTMLParserTest >> testProcessingInstructions [
	| document |

	document := XMLHTMLParser parse: '<body><?ignored data?></body>'.
	self deny: (document findElementNamed: 'body') hasChildren.
]

{ #category : #tests }
XMLHTMLParserTest >> testReopeningHTML [
	| document |

	document := XMLHTMLParser parse: '<html><B></body></html><I>'.
	self
		assert: (document allElementsCollect: [:each | each name]) asArray = #('html' 'body' 'b' 'i');
		assert: document root nodes size = 1;
		assert: (document root firstElement elementsCollect: [:each | each name]) asArray = #('b' 'i').

	document := XMLHTMLParser parse: '<html><B>bold</body></html>normal'.
	self
		assert: (document allElementsCollect: [:each | each name]) asArray = #('html' 'body' 'b');
		assert: (document findElementNamed: 'body') contentString = 'bold normal'.
]

{ #category : #tests }
XMLHTMLParserTest >> testReopeningHeadSection [
	| document |

	document := XMLHTMLParser parse: '<head><p>text<Title>reopened'.
	self
		assert: (document root elementsCollect: [:each | each name]) asArray = #('head' 'body');
		assert: (document findElementNamed: 'head') elements size = 1;
		assert: ((document findElementNamed: 'head') elementAt: 'title') contentString = 'reopened';
		assert: (document findElementNamed: 'body') elements size = 1;
		assert: ((document findElementNamed: 'body') elementAt: 'p') contentString = 'text'.
]

{ #category : #tests }
XMLHTMLParserTest >> testXMLDeclaration [
	| document |

	document := XMLHTMLParser parse: '<?xml ?>'.
	self
		assert: document version = 1.0;
		assert: document encoding = 'UTF-8';
		deny: document isStandalone.

	document := XMLHTMLParser parse: '<?xml version="onePointZero" encoding="UTF-16" standalone="yes"?>'.
	self
		assert: document version = 1.0;
		assert: document encoding = 'UTF-16';
		deny: document isStandalone.
]

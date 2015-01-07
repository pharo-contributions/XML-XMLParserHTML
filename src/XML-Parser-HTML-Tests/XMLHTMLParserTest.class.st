Class {
	#name : #XMLHTMLParserTest,
	#superclass : #TestCase,
	#category : #'XML-Parser-HTML-Tests'
}

{ #category : #source }
XMLHTMLParserTest >> addressBookXML [
	^ XMLParserTest addressBookXML
]

{ #category : #source }
XMLHTMLParserTest >> addressBookXMLWithDTD [
	^ XMLParserTest addressBookXMLWithDTD
]

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
XMLHTMLParserTest >> testCharacterReferences [
	self assert:
		(XMLHTMLParser parse: '&#60; &#x3C &#X3E &#62; &#0; &#-1 &#invalid; &#invalid &#')
			contentString = '< < > > &#0; &#-1 &#invalid; &#invalid &#'.
]

{ #category : #tests }
XMLHTMLParserTest >> testCharacterReferencesUnreplaced [
	self assert:
		((XMLHTMLParser on: '&#60; &#x3C &#X3E &#62; &#0; &#-1 &#invalid; &#invalid &#')
			replacesContentEntityReferences: false;
			parseDocument) contentString = '&#60; &#x3C &#X3E &#62; &#0; &#-1 &#invalid; &#invalid &#'
]

{ #category : #tests }
XMLHTMLParserTest >> testHTMLEntities [
	| entity character document p |

	entity := 'nbsp'.
	character := XMLHTMLParserTokenizer predefinedEntities at: entity.
	document :=
		XMLHTMLParser parse:
			'<p>&', entity, ';&', entity, '</p>',
			'<div>&undeclared; &undeclared &;& ;'.

	p := document findElementNamed: 'p'.
	self
		assert: p contentString size = 2;
		assert: (p contentString allSatisfy: [:each | each == character]);
		assert: (document findElementNamed: 'div') contentString = '&undeclared; &undeclared &;& ;'.
]

{ #category : #tests }
XMLHTMLParserTest >> testHTMLEntitiesUnreplaced [
	| entity character document |

	entity := 'nbsp'.
	character := XMLHTMLParserTokenizer predefinedEntities at: entity.
	document :=
		(XMLHTMLParser on:
			'<p>&', entity, ';&', entity, '</p>',
			'<div>&undeclared; &undeclared &;& ;')
			replacesContentEntityReferences: false;
			parseDocument.
	self
		assert: (document findElementNamed: 'p') contentString = '&nbsp;&nbsp';
		assert: (document findElementNamed: 'div') contentString = '&undeclared; &undeclared &;& ;'.
]

{ #category : #tests }
XMLHTMLParserTest >> testIgnoringInternalSubsets [
	| html docWithSubset docWithoutSubset |

	html :=
		'<html>
			<head><title>test</title></head>
			<body><p>test</p></body>
		</html>'.
	docWithSubset := XMLHTMLParser parse: '<!DOCTYPE html [
		<!ELEMENT html ANY>
		<!ENTITY lang "en-us">
		<!ATTLIST html xml:lang CDATA #FIXED "&lang;">
		<!--end-->]>', html.
	self
		deny: docWithSubset doctypeDeclaration isNil;
		assert: docWithSubset doctypeDeclaration root = 'html';
		deny: docWithSubset doctypeDeclaration hasChildren.

	docWithoutSubset := XMLHTMLParser parse: '<!DOCTYPE html>', html.
	self
		deny: docWithoutSubset doctypeDeclaration isNil;
		assert: docWithoutSubset doctypeDeclaration root = 'html';
		deny: docWithoutSubset doctypeDeclaration hasChildren.

	self assert: docWithSubset printString = docWithoutSubset printString.
]

{ #category : #tests }
XMLHTMLParserTest >> testInnerXML [
	| document addressBook |

	document := XMLHTMLParser parse: self addressBookXML.
	addressBook := document findElementNamed: 'addressbook'.
	addressBook firstNode innerXML: 'first'.
	self assert: addressBook firstNode innerXML = 'first'.
	addressBook nodes second innerXML: '<second>second</second>'.
	self assert: addressBook nodes second innerXML = '<second>second</second>'.
	addressBook nodes third innerXML: '<!--third-->'.
	self assert: addressBook nodes third innerXML = ''.
	addressBook lastNode innerXML: '<![CDATA[ignored]]>'.
	self assert: addressBook lastNode innerXML = ''.
	self
		assert: addressBook nodes size = 4;
		assert: (addressBook nodes allSatisfy: [:each | each isElementNamed: 'person']).
]

{ #category : #tests }
XMLHTMLParserTest >> testInnerXMLElement [
	| document addressBook person personStartTag |

	document := XMLHTMLParser parse: self addressBookXML.
	addressBook := document findElementNamed: 'addressbook'.
	person := addressBook firstNode.
	personStartTag := person printString copyUpTo: $>.
	addressBook removeNode: person.
	person innerXML: '<p>new</p>'.
	self
		assert: person innerXML = '<p>new</p>';
		assert: person printString = (personStartTag, '><p>new</p></person>').
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
XMLHTMLParserTest >> testParsingDTDs [
	| xmlWithDtd document |

	xmlWithDtd :=
		'<!DOCTYPE root PUBLIC "pubid" "external.dtd" [
			<!ELEMENT root ( #PCDATA | one | two)* >
			<!ATTLIST root
						name CDATA #IMPLIED
						number ( %one; | two | three ) "three">
			<!ENTITY general "replacement">
			<!ENTITY externalGeneral PUBLIC "pubid2" "external1.dtd">
			<!ENTITY % parameter "<!ENTITY generalTwo &#32replacement&#32>">
			%parameter;
			<!ENTITY % externalParameter SYSTEM "external2.dtd">
			<!NOTATION notation SYSTEM "note.doc">]>
		<p>&generalTwo;</p>'.
	self
		shouldnt: [document := XMLHTMLParser parse: xmlWithDtd]
		raise: XMLParserException.
	self
		assert: document nodes size = 1;
		assert: (document findElementNamed: 'p') contentString = '&generalTwo;'.
	self assert:
		document printString =
			(XMLHTMLParser parse:
				'<!DOCTYPE root PUBLIC "pubid" "external.dtd"><p>&generalTwo;</p>') printString.
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
				parse: self addressBookXML;
				parse: self addressBookXMLWithDTD;
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

	document := XMLHTMLParser parse: '<?xml version="onePointZero" encoding="utf-8" standalone="yes"?>'.
	self
		assert: document version = 1.0;
		assert: document encoding = 'utf-8';
		deny: document isStandalone.
]

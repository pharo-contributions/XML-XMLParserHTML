"
Unit tests for XMLHTMLParser
"
Class {
	#name : #XMLHTMLParserTest,
	#superclass : #TestCase,
	#category : #'XML-ParserHTML-Tests'
}

{ #category : #source }
XMLHTMLParserTest >> addressBookNamespacePrefixedXML [
	^ XMLParserTest addressBookNamespacePrefixedXML
]

{ #category : #source }
XMLHTMLParserTest >> addressBookNamespacedXML [
	^ XMLParserTest addressBookNamespacedXML
]

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
XMLHTMLParserTest >> testAttributes [
	| document element |

	document :=
		XMLHTMLParser parse:
			'<test one="quoted" two=''subQuoted'' three=unquoted four'.
	element := document findElementNamed: 'test'.
	self
		assert: (element attributeAt: 'one') equals: 'quoted';
		assert: (element attributeAt: 'two') equals: 'subQuoted';
		assert: (element attributeAt: 'three') equals: 'unquoted';
		assert: (element attributeAt: 'four') equals: ''
]

{ #category : #tests }
XMLHTMLParserTest >> testCharacterReferences [
	self assert:
		(XMLHTMLParser parse: '&#60; &#x3c &#X3E &#62; &#62end &#x2Astar &#0; &#-1 &#inval; &#inval &#')
			contentString equals: '< < > > >end *star &#0; &#-1 &#inval; &#inval &#'
]

{ #category : #tests }
XMLHTMLParserTest >> testCharacterReferencesUnreplaced [
	self assert:
		((XMLHTMLParser on: '&#60; &#x3c &#X3E &#62; &#62end &#x2Astar &#0; &#-1 &#inval; &#inval &#')
			replacesContentEntityReferences: false;
			parseDocument) contentString equals:
				'&#60; &#x3c &#X3E &#62; &#62end &#x2Astar &#0; &#-1 &#inval; &#inval &#'
]

{ #category : #tests }
XMLHTMLParserTest >> testElementMixedContent [
	| xml mixedContent |

	xml := '<mixed-content> one <two/> <three/> four <five> </five> seven </mixed-content>'.
	mixedContent := (XMLHTMLParser parse: xml) findElementNamed: 'mixed-content'.
	self
		assert: mixedContent nodes size equals: 7;
		assert: (mixedContent nodes first isStringNode: ' one ');
		assert: (mixedContent nodes second isElementNamed: 'two');
		deny: mixedContent nodes second hasChildren;
		assert: (mixedContent nodes third isStringNode: ' ');
		assert: (mixedContent nodes fourth isElementNamed: 'three');
		deny: mixedContent nodes fourth hasChildren;
		assert: (mixedContent nodes fifth isStringNode: ' four ');
		assert: (mixedContent nodes sixth isElementNamed: 'five');
		assert: mixedContent nodes sixth hasChildren;
		assert: mixedContent nodes sixth nodes size equals: 1;
		assert: (mixedContent nodes sixth nodes first isStringNode: ' ');
		assert: (mixedContent nodes seventh isStringNode: ' seven ')
]

{ #category : #tests }
XMLHTMLParserTest >> testHTMLEntities [
	| entity character document p |

	entity := 'nbsp'.
	character := XMLHTMLParserTokenizer predefinedHTMLEntities at: entity.
	document :=
		XMLHTMLParser parse:
			'<p>&', entity, ';&', entity, '</p>',
			'<div>&undeclared; &undeclared &;& ;'.

	p := document findElementNamed: 'p'.
	self
		assert: p contentString size equals: 2;
		assert: (p contentString allSatisfy: [:each | each == character]);
		assert: (document findElementNamed: 'div') contentString equals: '&undeclared; &undeclared &;& ;'
]

{ #category : #tests }
XMLHTMLParserTest >> testHTMLEntitiesUnreplaced [
	| entity document |

	entity := 'nbsp'.
	document :=
		(XMLHTMLParser on:
			'<p>&', entity, ';&', entity, '</p>',
			'<div>&undeclared; &undeclared &;& ;')
			replacesContentEntityReferences: false;
			parseDocument.
	self
		assert: (document findElementNamed: 'p') contentString equals: '&nbsp;&nbsp';
		assert: (document findElementNamed: 'div') contentString equals: '&undeclared; &undeclared &;& ;'
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
		assert: docWithSubset doctypeDeclaration root equals: 'html';
		deny: docWithSubset doctypeDeclaration hasChildren.

	docWithoutSubset := XMLHTMLParser parse: '<!DOCTYPE html>', html.
	self
		deny: docWithoutSubset doctypeDeclaration isNil;
		assert: docWithoutSubset doctypeDeclaration root equals: 'html';
		deny: docWithoutSubset doctypeDeclaration hasChildren.

	self assert: docWithSubset printString equals: docWithoutSubset printString
]

{ #category : #tests }
XMLHTMLParserTest >> testInnerXML [
	| document addressBook |

	document := XMLHTMLParser parse: self addressBookXML.
	addressBook := document findElementNamed: 'addressbook'.
	addressBook firstElement innerXML: 'first'.
	self assert: addressBook firstElement innerXML equals: 'first'.
	addressBook elements second innerXML: '<second>second</second>'.
	self assert: addressBook elements second innerXML equals: '<second>second</second>'.
	addressBook elements third innerXML: '<!--third-->'.
	self assert: addressBook elements third innerXML equals: ''.
	addressBook lastElement innerXML: '<![CDATA[not ignored]]>'.
	self assert: addressBook lastElement innerXML equals: 'not ignored'.
	self
		assert: addressBook elements size equals: 4;
		assert: (addressBook elements allSatisfy: [:each | each isElementNamed: 'person'])
]

{ #category : #tests }
XMLHTMLParserTest >> testInnerXMLElement [
	| document addressBook person personStartTag |

	document := XMLHTMLParser parse: self addressBookXML.
	addressBook := document findElementNamed: 'addressbook'.
	person := addressBook firstElement.
	personStartTag := person printString copyUpTo: $>.
	addressBook removeNode: person.
	person innerXML: '<p>new</p>'.
	self
		assert: person innerXML equals: '<p>new</p>';
		assert: person printString equals: (personStartTag, '><p>new</p></person>')
]

{ #category : #tests }
XMLHTMLParserTest >> testIsInContent [
	| html handler parser |

	html := '<?xml version="1.0"?>
			<!--comment-->
			<?target data?>
			<!DOCTYPE root [<!ELEMENT root EMPTY>]>
			<!--comment-->
			<?target data?>
			<root/>'.
	handler := SAXHTMLHandler on: html.
	parser := handler parser.
	9 timesRepeat: [
		parser parseToken.
		self deny: handler isInContent].
	parser parseToken.
	self assert: handler isInContent.

	handler := SAXHTMLHandler on: 'test'.
	parser := handler parser.
	parser parseToken.
	self deny: handler isInContent.
	parser parseToken.
	self assert: handler isInContent
]

{ #category : #tests }
XMLHTMLParserTest >> testParseHTML [
	| html |

	html := '<html><body>test</body></html>'.
	self
		assert: html parseHTML printString equals: html;
		assert: html readStream parseHTML printString equals: html
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingCDATA [
	#('<![CDATA[not ignored]]>'
		'<body><![CDATA[not ignored]]></body>'
		'<!DOCTYPE><![CDATA[not ignored]]><html><body/>')
		do: [:each | | document |
			document := XMLHTMLParser parse: each.
			self assert: document contentString equals: 'not ignored']
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingComments [
	| document |

	document :=
		(XMLHTMLParser on: '<body><!--comment can have -- before end --></body>')
			preservesCommentNodes: true;
			parseDocument.
	self
		assert: (document findElementNamed: 'body') firstNode isComment;
		assert: (document findElementNamed: 'body') firstNode string equals: 'comment can have -- before end '
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingDTDs [
	| xml document |

	xml :=
		'<!DOCTYPE root PUBLIC "pubid""external.dtd" [
			<!ELEMENT root ( #PCDATA | one | two)* >
			<!ATTLIST root
						%entity;
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
		shouldnt: [document := XMLHTMLParser parse: xml]
		raise: XMLParserException.
	self
		assert: document nodes size equals: 1;
		assert: (document findElementNamed: 'p') contentString equals: '&generalTwo;'.
	self assert:
		document printString equals:
			(XMLHTMLParser parse:
				'<!DOCTYPE root PUBLIC "pubid" "external.dtd"><p>&generalTwo;</p>') printString
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingForms [
	| document |

	document := XMLHTMLParser parse: '<form><input><form><input>'.

	self assert:
		(document allElements asArray collect: [:each | each name]) equals:
			#('html' 'body' 'form' 'input' 'form' 'input').

	document allElementsNamed: 'form' do: [:each |
		self
			assert: each elements size equals: 1;
			assert: (each firstElement isNamed: 'input')].
	document allElementsNamed: 'input' do: [:each |
		self deny: each hasChildren ]
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingImplicitStartTag [
	| paragraphs |

	paragraphs := (XMLHTMLParser parse: '</p></p>') allElementsNamed: 'p'.
	self
		assert: paragraphs size equals: 2;
		deny: (paragraphs anySatisfy: [:each | each hasChildren])
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingInvalidPCData [
	| document |

	#('< one & two >' '& three < four >') do: [:each |
		document := XMLHTMLParser parse: each.
		self
			assert: document allNodes size equals: 4;
			assert: (document findElementNamed: 'body') contentString equals: each]
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingNonHTMLSections [
	| document |

	document := XMLHTMLParser parse:
		'<head><Title><b>"title&quot;</b></TITLE><SCRIPT>',
		'1 < 2; 3 > 2; document.write("&lt;</Script>");</Script>
		<Style>//"</STYLE><HEAD><body><textarea><one>&amp;<two></textarea>'.
	self
		assert: (document findElementNamed: 'title') contentString equals: '<b>"title"</b>';
		assert: (document findElementNamed: 'script') contentString equals:
			'1 < 2; 3 > 2; document.write("&lt;</Script>");';
		assert: (document findElementNamed: 'style') contentString equals: '//"';
		assert: (document findElementNamed: 'textarea') contentString equals: '<one>&<two>'
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingRedundantStartTags [
	| document html head body |

	document :=
		XMLHTMLParser parse:
			'<html>
				<head><html>
					<title>test</title><head>
					<script>test()</script><head/>
				</head><html/>
				<body>one<body>two<body/>three</body><!--ignored-->
			</html>'.
	self
		assert: document nodes size equals: 1;
		assert: (document firstNode isElementNamed: 'html').

	html := document firstNode.
	self
		assert: html nodes size equals: 5;
		assert: html nodes first isStringNode;
		assert: html nodes first isWhitespace;
		assert: (html nodes second isElementNamed: 'head');
		assert: html nodes third isStringNode;
		assert: html nodes third isWhitespace;
		assert: (html nodes fourth isElementNamed: 'body');
		assert: html nodes fifth isStringNode;
		assert: html nodes fifth isWhitespace.

	head := html nodes second.
	self
		assert: head nodes size equals: 5;
		assert: head nodes first isStringNode;
		assert: head nodes first isWhitespace;
		assert: (head nodes second isElementNamed: 'title');
		assert: head nodes second contentString equals: 'test';
		assert: head nodes third isStringNode;
		assert: head nodes third isWhitespace;
		assert: (head nodes fourth isElementNamed: 'script');
		assert: head nodes fourth contentString equals: 'test()';
		assert: head nodes fifth isStringNode;
		assert: head nodes fifth isWhitespace.

	body := html nodes fourth.
	self
		assert: body nodes size equals: 1;
		assert: body firstNode contentString equals: 'onetwothree'
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingTables [
	| document tables trs tds |

	document := XMLHTMLParser parse: '<table><tr><td>one<td>two<tr><td>three<table><tr><td>four'.
	self assert:
		(document allElements asArray collect: [:each | each name]) equals:
			#('html' 'body' 'table' 'tr' 'td' 'td' 'tr' 'td' 'table' 'tr' 'td').

	tables := document allElementsNamed: 'table'.
	self
		assert: tables first elements size equals: 2;
		assert: tables second elements size equals: 1.
	tables do: [:each | self assert: (each elements allSatisfy: [:element | element isNamed: 'tr'])].

	trs := document allElementsNamed: 'tr'.
	self
		assert: trs first elements size equals: 2;
		assert: trs second elements size equals: 1;
		assert: trs third elements size equals: 1.
	trs do: [:each | self assert: (each elements allSatisfy: [:element | element isNamed: 'td'])].

	tds := document allElementsNamed: 'td'.
	self
		assert: tds first contentString equals: 'one';
		assert: tds second contentString equals: 'two';
		assert: tds third contentString equals: 'three four';
		assert: (tds third nodes second isNamed: 'table')
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingTemplates [
	| document |

	document := XMLHTMLParser parse: '<template><b>test</b></template>'.
	self
		assert: document allElements elementNames asArray equals: #('html' 'head' 'template');
		assert: (document root firstElement isNamed: 'head');
		assert: (document root firstElement contentStringAt: 'template') equals: '<b>test</b>'.

	document := XMLHTMLParser parse: '<body><template><p>test<p></template></body>'.
	self
		assert: document allElements elementNames asArray equals: #('html' 'body' 'template');
		assert: (document root firstElement isNamed: 'body');
		assert: (document root firstElement contentStringAt: 'template') equals: '<p>test<p>'
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingText [
	| document |

	#('text' '<html>text' '<body>text') do: [:source |
		document := XMLHTMLParser parse: source.
		self
			assert: document nodes size equals: 1;
			assert: (document root isElementNamed: 'html');
			assert: document root nodes size equals: 1;
			assert: (document root firstNode isElementNamed: 'body');
			assert: document root firstNode contentString equals: 'text'].

	#('<head>text' '<html><head>text') do: [:source |
		document := XMLHTMLParser parse: '<head>text'.
		self
			assert: document nodes size equals: 1;
			assert: (document root isElementNamed: 'html');
			assert: document root nodes size equals: 2;
			assert: (document root firstNode isElementNamed: 'head');
			assert: (document root nodes second isElementNamed: 'body');
			assert: document root nodes second contentString equals: 'text']
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingUnclosedHeadSection [
	#('<head><p>text<Title>title' '<head><body><p>text<Title>title') do: [:each | | document p |
		document := XMLHTMLParser parse: each.
		self
			assert: (document root isElementNamed: 'html');
			assert: document root nodes size equals: 2;
			deny: (document findElementNamed: 'head') hasChildren;
			assert: (document findElementNamed: 'body') nodes size equals: 1.
		p := (document findElementNamed: 'body') firstElement.
		self
			assert: (p isNamed: 'p');
			assert: p nodes size equals: 2;
			assert: (p firstNode isStringNode: 'text');
			assert: (p nodes second isElementNamed: 'title');
			assert: p nodes second contentString equals: 'title']
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingUnknownTag [
	| document |
	document := XMLHTMLParser parse: '<pharo>test</pharo>'.
	self
		assert: document printString
			equals: '<html><body><pharo>test</pharo></body></html>';
		assert: document contentString equals: 'test'
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingVoidElements [
	| document body |

	document :=
		XMLHTMLParser parse:
			'<body>one<img src="a.jpg">two</img><body>three<img src="b.jpg"/>'.
	body := document findElementNamed: 'body'.
	self
		assert: body nodes size equals: 4;
		assert: (body nodes first isStringNode: 'one');
		assert: (body nodes second isElementNamed: 'img');
		assert: (body nodes second attributeAt: 'src') equals: 'a.jpg';
		assert: (body nodes third isStringNode: 'twothree');
		assert: (body nodes fourth isElementNamed: 'img');
		assert: (body nodes fourth attributeAt: 'src') equals: 'b.jpg'
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingXML [
	self
		shouldnt: [
			SAXHTMLHandler
				parse: self addressBookXML;
				parse: self addressBookXMLWithDTD;
				parse: self addressBookNamespacedXML;
				parse: self addressBookNamespacePrefixedXML]
		raise: XMLParserException
]

{ #category : #tests }
XMLHTMLParserTest >> testProcessingInstructions [
	| document html body |

	document := XMLHTMLParser parse: '<?one two?><body><?three four?></body><?five six?>'.
	self
		assert: document nodes size equals: 2;
		assert: document nodes first isPI;
		assert: document nodes first target equals: 'one';
		assert: document nodes first data equals: 'two';
		assert: (document nodes second isElementNamed: 'html').

	html := document nodes second.
	self
		assert: html nodes size equals: 2;
		assert: (html nodes first isElementNamed: 'body');
		assert: html nodes second isPI;
		assert: html nodes second target equals: 'five';
		assert: html nodes second data equals: 'six'.
	
	body := html nodes first.
	self
		assert: body nodes size equals: 1;
		assert: body nodes first isPI;
		assert: body nodes first target equals: 'three';
		assert: body nodes first data equals: 'four'
]

{ #category : #tests }
XMLHTMLParserTest >> testReopeningHTML [
	| document html body |

	document := XMLHTMLParser parse: '<html><B>one</body></html><I>two'.
	self
		assert: document nodes size equals: 1;
		assert: (document firstNode isElementNamed: 'html').

	html := document root.
	self
		assert: html nodes size equals: 1;
		assert: (html firstNode isElementNamed: 'body').

	body := html firstNode.
	self
		assert: body nodes size equals: 2;
		assert: (body nodes first isElementNamed: 'b');
		assert: body nodes first nodes size equals: 1;
		assert: (body nodes first firstNode isStringNode: 'one');
		assert: (body nodes second isElementNamed: 'i');
		assert: body nodes second contentString equals: 'two'.

	document := XMLHTMLParser parse: '<html><B>bold</body></html> '.
	self
		assert: document nodes size equals: 1;
		assert: (document firstNode isElementNamed: 'html').

	html := document root.
	self
		assert: html nodes size equals: 1;
		assert: (html firstNode isElementNamed: 'body').

	body := html firstNode.
	self
		assert: body nodes size equals: 1;
		assert: (body nodes first isElementNamed: 'b');
		assert: body nodes first nodes size equals: 1;
		assert: (body nodes first firstNode isStringNode: 'bold')
]

{ #category : #tests }
XMLHTMLParserTest >> testScriptTagEscapeParsing [
	#(
		#('<script>"one\"</script>"two</script>' '"one\"</script>"two')
		#('<script>"\one\"</script>"two</script>' '"\one\"</script>"two')
		#('<script>"one\\"two</script>' '"one\\"two')
		#('<script>"one\\\"</script>"two</script>' '"one\\\"</script>"two')
		#('<script>''one\''</script>''two</script>' '''one\''</script>''two')
		#('<script>''one\\''two</script>' '''one\\''two')
		#('<script>''one\\\''</script>''two</script>' '''one\\\''</script>''two')
	) do: [:each | | body source contentString |
		source := each first.
		contentString := each second.
		body := (XMLHTMLParser parse: source) findElementNamed: 'body'.
		self
			assert: body nodes size equals: 1;
			assert: (body firstNode isNamed: 'script');
			assert: body firstNode contentString equals: contentString ]
]

{ #category : #tests }
XMLHTMLParserTest >> testStyleTagEscapeParsing [
	#(
		#('<style>"one\"</style>"two</style>' '"one\"</style>"two')
		#('<style>"\one\"</style>"two</style>' '"\one\"</style>"two')
		#('<style>"one\\"two</style>' '"one\\"two')
		#('<style>"one\\\"</style>"two</style>' '"one\\\"</style>"two')
		#('<style>''one\''</style>''two</style>' '''one\''</style>''two')
		#('<style>''one\\''two</style>' '''one\\''two')
		#('<style>''one\\\''</style>''two</style>' '''one\\\''</style>''two')
	) do: [:each | | body source contentString |
		source := each first.
		contentString := each second.
		body := (XMLHTMLParser parse: source) findElementNamed: 'body'.
		self
			assert: body nodes size equals: 1;
			assert: (body firstNode isNamed: 'style');
			assert: body firstNode contentString equals: contentString ]
]

{ #category : #tests }
XMLHTMLParserTest >> testXMLDeclaration [
	| document |

	document := XMLHTMLParser parse: '<?xml ?>'.
	self
		assert: document version equals: 1.0;
		assert: document encoding equals: '';
		deny: document isStandalone.

	document := XMLHTMLParser parse: '<?xml version="1.1" ?>'.
	self
		assert: document version equals: 1.1;
		assert: document encoding equals: '';
		deny: document isStandalone.

	document :=
		XMLHTMLParser parse:
			'<?xml version="onePointZero" encoding="utf-8" standalone="yes"?>'.
	self
		assert: document version equals: 1.0;
		assert: document encoding equals: 'utf-8';
		assert: document isStandalone.

	document :=
		XMLHTMLParser parse:
			'<?xml version="1.1" ?>
			<?xml version="1.0" encoding="utf-8" standalone="yes"?>'.
	self
		assert: document version equals: 1.1;
		assert: document encoding equals: '';
		deny: document isStandalone;
		assert: document nodes size equals: 1;
		assert: document firstNode isPI;
		assert: document firstNode target equals: 'xml';
		assert: document firstNode data equals: 'version="1.0" encoding="utf-8" standalone="yes"'
]

Class {
	#name : #XMLHTMLParserTest,
	#superclass : #TestCase,
	#category : #'XML-Parser-HTML-Tests'
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
		assert: (element attributeAt: 'one') = 'quoted';
		assert: (element attributeAt: 'two') = 'subQuoted';
		assert: (element attributeAt: 'three') = 'unquoted';
		assert: (element attributeAt: 'four') = ''.
]

{ #category : #tests }
XMLHTMLParserTest >> testCharacterReferences [
	self assert:
		(XMLHTMLParser parse: '&#60; &#x3c &#X3E &#62; &#62end &#x2Astar &#0; &#-1 &#inval; &#inval &#')
			contentString = '< < > > >end *star &#0; &#-1 &#inval; &#inval &#'.
]

{ #category : #tests }
XMLHTMLParserTest >> testCharacterReferencesUnreplaced [
	self assert:
		((XMLHTMLParser on: '&#60; &#x3c &#X3E &#62; &#62end &#x2Astar &#0; &#-1 &#inval; &#inval &#')
			replacesContentEntityReferences: false;
			parseDocument) contentString =
				'&#60; &#x3c &#X3E &#62; &#62end &#x2Astar &#0; &#-1 &#inval; &#inval &#'
]

{ #category : #tests }
XMLHTMLParserTest >> testElementMixedContent [
	| xml mixedContent |

	xml := '<mixed-content> one <two/> <three/> four <five> </five> seven </mixed-content>'.
	mixedContent := (XMLHTMLParser parse: xml) findElementNamed: 'mixed-content'.
	self
		assert: mixedContent nodes size = 7;
		assert: (mixedContent nodes first isStringNode: ' one ');
		assert: (mixedContent nodes second isElementNamed: 'two');
		deny: mixedContent nodes second hasChildren;
		assert: (mixedContent nodes third isStringNode: ' ');
		assert: (mixedContent nodes fourth isElementNamed: 'three');
		deny: mixedContent nodes fourth hasChildren;
		assert: (mixedContent nodes fifth isStringNode: ' four ');
		assert: (mixedContent nodes sixth isElementNamed: 'five');
		assert: mixedContent nodes sixth hasChildren;
		assert: mixedContent nodes sixth nodes size = 1;
		assert: (mixedContent nodes sixth nodes first isStringNode: ' ');
		assert: (mixedContent nodes seventh isStringNode: ' seven ').
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
		assert: p contentString size = 2;
		assert: (p contentString allSatisfy: [:each | each == character]);
		assert: (document findElementNamed: 'div') contentString = '&undeclared; &undeclared &;& ;'.
]

{ #category : #tests }
XMLHTMLParserTest >> testHTMLEntitiesUnreplaced [
	| entity character document |

	entity := 'nbsp'.
	character := XMLHTMLParserTokenizer predefinedHTMLEntities at: entity.
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
	addressBook firstElement innerXML: 'first'.
	self assert: addressBook firstElement innerXML = 'first'.
	addressBook elements second innerXML: '<second>second</second>'.
	self assert: addressBook elements second innerXML = '<second>second</second>'.
	addressBook elements third innerXML: '<!--third-->'.
	self assert: addressBook elements third innerXML = ''.
	addressBook lastElement innerXML: '<![CDATA[not ignored]]>'.
	self assert: addressBook lastElement innerXML = 'not ignored'.
	self
		assert: addressBook elements size = 4;
		assert: (addressBook elements allSatisfy: [:each | each isElementNamed: 'person']).
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
		assert: person innerXML = '<p>new</p>';
		assert: person printString = (personStartTag, '><p>new</p></person>').
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
	self assert: handler isInContent.
]

{ #category : #tests }
XMLHTMLParserTest >> testParseHTML [
	| html |

	html := '<html><body>test</body></html>'.
	self
		assert: html parseHTML printString = html;
		assert: html readStream parseHTML printString = html.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingCDATA [
	#('<![CDATA[not ignored]]>'
		'<body><![CDATA[not ignored]]></body>'
		'<!DOCTYPE><![CDATA[not ignored]]><html><body/>')
		do: [:each | | document |
			document := XMLHTMLParser parse: each.
			self assert: document contentString = 'not ignored'].
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
		assert: (document findElementNamed: 'body') firstNode string = 'comment can have -- before end '
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
		assert: document nodes size = 1;
		assert: (document firstNode isElementNamed: 'html').

	html := document firstNode.
	self
		assert: html nodes size = 5;
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
		assert: head nodes size = 5;
		assert: head nodes first isStringNode;
		assert: head nodes first isWhitespace;
		assert: (head nodes second isElementNamed: 'title');
		assert: head nodes second contentString = 'test';
		assert: head nodes third isStringNode;
		assert: head nodes third isWhitespace;
		assert: (head nodes fourth isElementNamed: 'script');
		assert: head nodes fourth contentString = 'test()';
		assert: head nodes fifth isStringNode;
		assert: head nodes fifth isWhitespace.

	body := html nodes fourth.
	self
		assert: body nodes size = 1;
		assert: body firstNode contentString = 'onetwothree'.
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
XMLHTMLParserTest >> testParsingTemplates [
	| document |

	document := XMLHTMLParser parse: '<template><b>test</b></template>'.
	self
		assert: document allElements elementNames asArray = #('html' 'head' 'template');
		assert: (document root firstElement isNamed: 'head');
		assert: (document root firstElement contentStringAt: 'template') = '<b>test</b>'.

	document := XMLHTMLParser parse: '<body><template><p>test<p></template></body>'.
	self
		assert: document allElements elementNames asArray = #('html' 'body' 'template');
		assert: (document root firstElement isNamed: 'body');
		assert: (document root firstElement contentStringAt: 'template') = '<p>test<p>'.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingText [
	| document |

	#('text' '<html>text' '<body>text') do: [:source |
		document := XMLHTMLParser parse: source.
		self
			assert: document nodes size = 1;
			assert: (document root isElementNamed: 'html');
			assert: document root nodes size = 1;
			assert: (document root firstNode isElementNamed: 'body');
			assert: (document root firstNode contentString = 'text')].

	#('<head>text' '<html><head>text') do: [:source |
		document := XMLHTMLParser parse: '<head>text'.
		self
			assert: document nodes size = 1;
			assert: (document root isElementNamed: 'html');
			assert: document root nodes size = 2;
			assert: (document root firstNode isElementNamed: 'head');
			assert: (document root nodes second isElementNamed: 'body');
			assert: (document root nodes second contentString = 'text')].
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingUnclosedHeadSection [
	#('<head><p>text<Title>title' '<head><body><p>text<Title>title') do: [:each | | document p |
		document := XMLHTMLParser parse: each.
		self
			assert: (document root isElementNamed: 'html');
			assert: document root nodes size = 2;
			deny: (document findElementNamed: 'head') hasChildren;
			assert: (document findElementNamed: 'body') nodes size = 1.
		p := (document findElementNamed: 'body') firstElement.
		self
			assert: (p isNamed: 'p');
			assert: p nodes size = 2;
			assert: (p firstNode isStringNode: 'text');
			assert: (p nodes second isElementNamed: 'title');
			assert: p nodes second contentString = 'title']
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingUnknownTag [
	| document |

	self
		shouldnt: [document := XMLHTMLParser parse: '<pharo>test</pharo>']
		raise: Error.

	self
		assert: document printString = '<html><body><pharo>test</pharo></body></html>';
		assert: document contentString = 'test'.
]

{ #category : #tests }
XMLHTMLParserTest >> testParsingVoidElements [
	| document body |

	document :=
		XMLHTMLParser parse:
			'<body>one<img src="a.jpg">two</img><body>three<img src="b.jpg"/>'.
	body := document findElementNamed: 'body'.
	self
		assert: body nodes size = 4;
		assert: (body nodes first isStringNode: 'one');
		assert: (body nodes second isElementNamed: 'img');
		assert: (body nodes second attributeAt: 'src') = 'a.jpg';
		assert: (body nodes third isStringNode: 'twothree');
		assert: (body nodes fourth isElementNamed: 'img');
		assert: (body nodes fourth attributeAt: 'src') = 'b.jpg'.
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
	| document |

	document := XMLHTMLParser parse: '<body><?ignored data?></body>'.
	self deny: (document findElementNamed: 'body') hasChildren.
]

{ #category : #tests }
XMLHTMLParserTest >> testReopeningHTML [
	| document html body |

	document := XMLHTMLParser parse: '<html><B></body></html><I>test'.
	html := document root.
	self
		assert: (html isElementNamed: 'html');
		assert: html nodes size = 1.
	body := html firstNode.
	self
		assert: (body isElementNamed: 'body');
		assert: body nodes size = 1;
		assert: (body firstNode isElementNamed: 'b');
		assert: body firstNode nodes size = 1;
		assert: (body firstNode firstNode isElementNamed: 'i');
		assert: body firstNode firstNode contentString = 'test'.

	document := XMLHTMLParser parse: '<html><B>bold</body></html>bold'.
	self assert: (document findElementNamed: 'b') contentString = 'boldbold'.
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
			assert: body nodes size = 1;
			assert: (body firstNode isNamed: 'script');
			assert: body firstNode contentString = contentString]
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
			assert: body nodes size = 1;
			assert: (body firstNode isNamed: 'style');
			assert: body firstNode contentString = contentString]
]

{ #category : #tests }
XMLHTMLParserTest >> testXMLDeclaration [
	| document |

	document := XMLHTMLParser parse: '<?xml ?>'.
	self
		assert: document version = 1.0;
		assert: document encoding = '';
		deny: document isStandalone.

	document := XMLHTMLParser parse: '<?xml version="1.1" ?>'.
	self
		assert: document version = 1.1;
		assert: document encoding = '';
		deny: document isStandalone.

	document :=
		XMLHTMLParser parse:
			'<?xml version="onePointZero" encoding="utf-8" standalone="yes"?>'.
	self
		assert: document version = 1.0;
		assert: document encoding = 'utf-8';
		assert: document isStandalone.
]

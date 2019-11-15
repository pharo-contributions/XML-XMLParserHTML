"
Baseline for Parsers for HTML that convert possibly malformed HTML into well-formed XML (see https://github.com/pharo-contributions/XML-XMLParserHTML)
"
Class {
	#name : #BaselineOfXMLParserHTML,
	#superclass : #BaselineOf,
	#category : #BaselineOfXMLParserHTML
}

{ #category : #baseline }
BaselineOfXMLParserHTML >> baselineOf: spec [

	<baseline>
	spec
		for: #common
		do: [
			
			self xmlParserOn: spec.		
			
			"Packages"
			spec 
				package: 'XML-ParserHTML-Core' with: [ spec requires: #('XMLParser') ];
				package: 'XML-ParserHTML-Tests' with: [ spec requires: #('XMLParser Tests' 'XML-ParserHTML-Core') ].
			
			"Groups"
			spec
				group: 'Core' with: #('XML-ParserHTML-Core');
				group: 'Tools' with: #('XMLParser Tools'); 
				group: 'Tests' with: #('XML-ParserHTML-Tests');	
				group: 'all' with: #('Core' 'Tools' 'Tests');
				group: 'default' with: #('all')	
	]
]

{ #category : #baseline }
BaselineOfXMLParserHTML >> xmlParserOn: spec [

	spec
		baseline: 'XMLParser'
      with: [ 
			spec
				loads: #('Core');
				repository: 'github://pharo-contributions/XML-XMLParser:3.5.x/src' ]. 
				
	spec 
		project: 'XMLParser Tests' copyFrom: 'XMLParser' with: [ spec loads: #('Tests') ]; 	
		project: 'XMLParser Tools' copyFrom: 'XMLParser' with: [ spec loads: #('Tools') ] 
]

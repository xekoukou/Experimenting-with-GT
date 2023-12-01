Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input',
		'ready',
		'response',
		'announcer'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaMode >> announcer [

	^ announcer
]

{ #category : #accessing }
AgdaMode >> getResp [
	| par continue rem |
	ready
		ifFalse: [ response := LinkedList new.
			rem := ''.
			out
				pollStringWhileTrue: 20 milliseconds
				do: [ :aString | 
					rem := rem , aString.
					continue := true.
					[ continue ]
						whileTrue: [ par := self parseResp: rem.
							rem := par at: 2.
							(par at: 1) = ''
								ifTrue: [ continue := false ]
								ifFalse: [ response add: (par at: 1).
									self announcer announce: NewResponse new ] ].
					(aString findString: 'JSON>')
						in: [ :index | 
							index > 0
								ifTrue: [ ready := true.
									false ]
								ifFalse: [ true ] ] ] ]
]

{ #category : #accessing }
AgdaMode >> gtJSONDataFor: aView context: aContext [
	<gtView>
	| anIndexStyler aValueStyler |
	anIndexStyler := aContext
			at: #gtTreeIndexStyler
			ifAbsent: [ [ :aNode | aNode key gtDisplayText asRopedText foreground: Color gray ] ].
	aValueStyler := aContext
			at: #gtTreeValueStyler
			ifAbsent: [ [ :aNode | aNode value gtDisplayText ] ].

	^ aView columnedTree
		title: 'JSON DATA';
		priority: 9;
		items: [ GtTreeNode
				fromCollection: ([ STONJSON fromString: '[' , response asCommaString , ']' ]
						on: Error
						do: [ :anException | 
							OrderedDictionary new
								at: 'error' put: anException;
								at: 'description' put: 'Could not parse';
								yourself ]) ];
		children: [ :aNode | 
			(aNode value isCollection and: [ aNode value isString not ])
				ifTrue: [ GtTreeNode fromNode: aNode ]
				ifFalse: [ #() ] ];
		updateWhen: NewResponse in: self announcer;
		actionUpdateButton;
		column: 'Index'
			text: [ :aNode :anIndex | anIndexStyler cull: aNode cull: anIndex ];
		column: 'Item'
			text: [ :aNode :anIndex | aValueStyler cull: aNode cull: anIndex ]
			weight: 3;
		in: [ :theNewView | 
			aContext
				at: #gtTreeExpansionLevel
				ifPresent: [ :anObject | 
					anObject isNumber
						ifTrue: [ theNewView expandUpTo: anObject ]
						ifFalse: [ anObject = true ifTrue: [ theNewView expandAll ] ] ]
				ifAbsent: [  "ignore" ] ];
		send: [ :aNode | 
			aContext
				at: #gtTreeSend
				ifPresent: [ :aBlock | 
					aBlock
						cull: aNode value
						cull: aNode
						cull: self ]
				ifAbsent: [ aNode value ] ]
]

{ #category : #accessing }
AgdaMode >> gtJSONFor: aView [
	<gtView>

	^ aView textEditor
		title: 'JSON';
		priority: 4;
		text: [ '[' , response asCommaString , ']' ];
		styler: JSONParser gtStyler;
		aptitude: BrGlamorousCodeEditorAptitude;
		updateWhen: NewResponse in: self announcer;
		actionUpdateButton.
]

{ #category : #accessing }
AgdaMode >> initialize [
	super initialize.
	response := ''.
	agda := (GtExternalProcessBuilder new: 'agda')
			arg: '--interaction-json';
			pipeStdin;
			pipeStdout;
			pipeStderr;
			spawn.
	input := agda stdin.
	out := agda asynchronousStdout.
	err := agda asynchronousStderr.
	announcer := Announcer new.
	ready := false.
	self getResp
]

{ #category : #accessing }
AgdaMode >> isTerminated [
 ^ agda isTerminated.
]

{ #category : #accessing }
AgdaMode >> kill [
 agda kill.
]

{ #category : #accessing }
AgdaMode >> parseResp: aResp [
	| ic i1 i2 i wc q ic1 wc1 w |
	ic := ${.
	wc := $}.
	aResp size > 0
		ifFalse: [ ^ {''.
				''} ]
		ifTrue: [ i1 := aResp indexOf: $[.
			i2 := aResp indexOf: ${.
			i := i2.
			i1 = 0 & (i2 = 0)
				ifTrue: [ ^ {''.
						aResp} ].
			i1 < i2 & (i1 ~= 0)
				ifTrue: [ ic := $[.
					wc := $].
					i := i1 ].
			q := 1.
			w := i + 1.
			[ q > 0 ]
				whileTrue: [ ic1 := aResp indexOf: ic startingAt: w.
					wc1 := aResp indexOf: wc startingAt: w.
					ic1 = 0 & (wc1 = 0)
						ifTrue: [ ^ {''.
								aResp} ].
			ic1 ~= 0 & (ic1 < wc1 | (wc1 = 0))
				ifTrue: [ q := q + 1.
					w := ic1 + 1 ].
			wc1 ~= 0 & (wc1 < ic1 | (ic1 = 0))
				ifTrue: [ q := q - 1.
					w := wc1 + 1 ]].


			^ {aResp copyFrom: i to: w - 1.
				aResp copyFrom: w to: aResp size} ]
]

{ #category : #accessing }
AgdaMode >> query: aQuery [
	ready
		ifTrue: [ ready := false.
			input
				nextPutAll: aQuery asString;
				lf .
				^ true]
		ifFalse: [ ^ false ]
]

{ #category : #accessing }
AgdaMode >> query: aQuery with: aBlock [
	ready
		ifTrue: [ ready := false.
			input
				nextPutAll: aQuery asString;
				lf.
			self getRespWith: aBlock.
			^ true]
		ifFalse: [ ^ false ]
]

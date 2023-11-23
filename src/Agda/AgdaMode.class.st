Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input',
		'ready',
		'response'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaMode >> getResp [
 self getRespWith: [:aString | ]
]

{ #category : #accessing }
AgdaMode >> getRespWith: aBlock [
	| list par continue rem |
	ready
		ifFalse: [ list := LinkedList new.
			rem := ''.
			out
				pollStringWhileTrue: 20 milliseconds
				do: [ :aString | 
				Exception signal.
					rem := rem , aString.
					continue := true.
					[ continue ]
						whileTrue: [ par := self parseResp: rem.
							rem := par at: 2.
							(par at: 1) = ''
								ifTrue: [ continue := false ]
								ifFalse: [ list add: (par at: 1).
									aBlock value: (par at: 1) ] ].
					(aString findString: 'JSON>')
						in: [ :index | 
							index > 0
								ifTrue: [ response := '[' , list asCommaString , ']'.
									ready := true.
									false ]
								ifFalse: [ true ] ] ] ]
]

{ #category : #accessing }
AgdaMode >> gtJSONDataFor: aView [
	<gtView>
	^ aView forward
		title: 'JSON Data';
		priority: 10;
		object: [ response ];
		view: #gtJSONDataFor:context:
]

{ #category : #accessing }
AgdaMode >> gtJSONFor: aView [
	<gtView>
	^ aView forward
		title: 'JSON';
		priority: 9;
		object: [ response ];
		view: #gtJSONFor:context:
]

{ #category : #accessing }
AgdaMode >> initialize [
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
		ifFalse: [ ^ {'' . ''} ]
		ifTrue: [ i1 := aResp indexOf: $[.
			i2 := aResp indexOf: ${.
			i := i2.
			i1 = 0 & (i2 = 0) ifTrue: [ ^ {'' . aResp} ].
			i1 < i2 & (i1 ~= 0)
				ifTrue: [ ic := $[.
					wc := $].
					i := i1 ].
			q := 1.
			w := i + 1.
			[ q > 0 ]
				whileTrue: [ ic1 := aResp indexOf: ic startingAt: w.
					wc1 := aResp indexOf: wc startingAt: w.
					ic1 < wc1 & (ic1 ~= 0)
						ifTrue: [ q := q + 1.
							w := ic1 + 1 ].
					wc1 < ic1 & (wc1 ~= 0)
						ifTrue: [ q := q - 1.
							w := wc1 + 1 ].
					(ic1 = 0) & (wc1 = 0) ifTrue: [ ^ {'' . aResp} ] ].
			^ {aResp copyFrom: i to: (w - 1) . aResp copyFrom: w to: (aResp size)} ]
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

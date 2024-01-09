Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input',
		'ready',
		'announcer'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaMode >> initialize [
	super initialize.

	agda := (GtExternalProcessBuilder new: 'agda')
			arg: '--interaction-json';
			pipeStdin;
			pipeStdout;
			pipeStderr;
			spawn.
	input := agda stdin.
	out := agda asynchronousStdout.
	err := agda asynchronousStderr.
	ready := true.
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
							w := wc1 + 1 ] ].


			^ {aResp copyFrom: i to: w - 1.
				aResp copyFrom: w to: aResp size} ]
]

{ #category : #accessing }
AgdaMode >> query: aQuery for: anAgdaFile [
	ready
		ifTrue: [ ready := false.
			input
				nextPutAll: aQuery asString;
				lf.
			^ [ | aString continue1 continue2 rem par |
			continue1 := true.
			rem := ''.
			self inform: 'inside agda query.'.
			[ continue1 ]
				whileTrue: [ aString := out pollString.
					aString
						ifNotEmpty: [ rem := rem , aString.
							continue2 := true.
							[ continue2 ]
								whileTrue: [ par := self parseResp: rem.
									rem := par at: 2.
									(par at: 1) = ''
										ifTrue: [ continue2 := false ]
										ifFalse: [ self inform: (par at: 1).
											anAgdaFile handleResponse: (STONJSON fromString: (par at: 1)) ] ] ].

					(rem findString: 'JSON>')
						in: [ :index | index > 0 ifTrue: [ continue1 := false ] ] ].
			ready := true ] asAsyncFuture ]
		ifFalse: [ ^ [  ] asAsyncFuture ]
]

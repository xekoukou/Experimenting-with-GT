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
	| v |
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
	ready := false.
	100 milliSeconds wait.
	v := out pollString.
	
	self assert: [ v = 'JSON> ' ].
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
AgdaMode >> query: aQuery [
	ready
		ifTrue: [ ready := false.
			input
				nextPutAll: aQuery asString;
				lf.
			^ [ self response: '' ] asAsyncFuture ]
		ifFalse: [ ^ nil ]
]

{ #category : #accessing }
AgdaMode >> response: aRem [
	| aString rem par |
	rem := aRem.

	[ par := self parseResp: rem.
	(par at: 1) = ''
		ifTrue: [ (rem findString: 'JSON>')
				in: [ :index | 
					index > 0
						ifTrue: [ ready := true.
							^ nil ] ].
			aString := out pollString.
			rem := rem , aString ]
		ifFalse: [ ^ {STONJSON fromString: (par at: 1).
				[ self response: (par at: 2) ] asAsyncFuture} ] ] repeat
]

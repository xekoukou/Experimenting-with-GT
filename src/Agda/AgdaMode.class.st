Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input',
		'io',
		'ready',
		'monitor',
		'announcer',
		'rem'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaMode >> announcer [
^ announcer.
]

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
	monitor := Monitor new.
	monitor critical: [ ready := true. ].
	announcer := Announcer new.

	io := IOAsyncStream process: agda buff: out.
	self receiveResponse.
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
		ifTrue: [ input
				nextPutAll: aQuery asString;
				lf.
			monitor critical: [ ready := false ]. ].
]

{ #category : #accessing }
AgdaMode >> receiveResponse [
	[ (io next
		map: [ :aString | 
			self inform: aString]) wait ] asAsyncFuture await
]

{ #category : #accessing }
AgdaMode >> receiveResponse2 [
	(agdaStream next
		map: [ :anItem | 
			| obj |
			self inform: anItem.
			obj := STONJSON fromString: anItem.
			(obj includesKey: 'AgdaMode')
				ifTrue: [ ((obj at: 'msg') includesKey: 'ready')
						ifTrue: [ monitor critical: [ ready := true ] ] ]
				ifFalse: [ monitor critical: [ announcer announce: (NewResponse with: obj) ] ] ])
		asAsyncPromise asyncThen: [ :n | self receiveResponse ]
]

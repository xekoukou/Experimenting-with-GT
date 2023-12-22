Class {
	#name : #AgdaStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'out',
		'stream',
		'rem',
		'previous'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaStream class >> stream: anOutStream [
	^ self new stream: anOutStream
]

{ #category : #accessing }
AgdaStream >> initialize [
super initialize.
rem := ''.
previous := LinkedList new.
]

{ #category : #accessing }
AgdaStream >> parseResp: aResp [
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

{ #category : #'api - stream' }
AgdaStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."

	<return: #AsyncPoll>
	previous size > 0 ifTrue: [ ^ AsyncPoll ready: previous removeFirst ].

	(rem findString: 'JSON>')
		in: [ :index | 
			index > 0
				ifTrue: [ rem := ''.
					AsyncPoll ready: '{"AgdaMode" : true , "msg" : {"ready" : true} }' ] ].

	(stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			| continue par |
			aReadyPoll value
				ifSome: [ :aString | 
					rem := rem , aString.
					continue := true.
					[ continue ]
						whileTrue: [ par := self parseResp: rem.
							rem := par at: 2.
							(par at: 1) = ''
								ifTrue: [ continue := false ]
								ifFalse: [ previous add: (par at: 1) ] ].


					previous size > 0 ifTrue: [ ^ AsyncPoll ready: previous removeFirst ].
					^ AsyncPoll pending ]
				ifNone: [ ^ aReadyPoll ] ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #accessing }
AgdaStream >> stream: anOutStream [
	stream := anOutStream
]

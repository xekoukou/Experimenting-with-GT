Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input',
		'io',
		'agdaStream',
		'ready',
		'monitor',
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
	monitor := Monitor new.
	monitor critical: [ ready := true. ].
	announcer := Announcer new.

	io := IOAsyncStream process: agda buff: out.
	agdaStream := AgdaStream stream: io.
	"self receiveResponse"
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
	[ [ (agdaStream next
		map: [ :anItem | 
			STONJSON fromString: anItem.
			self inform: 'hi' ]) wait ] repeat ] asAsyncFuture await.
]

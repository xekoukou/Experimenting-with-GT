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
	response := '['.
	out
		pollStringWhileTrue: 20 milliseconds
		do: [ :aString | 
			(aString findString: 'JSON>')
				in: [ :index | 
					index > 0
						ifTrue: [ | temp |
							temp := aString copyFrom: 1 to: index - 1.
							temp size > 0 ifTrue: [ temp := temp truncateTo: (temp size) - 1 ].
							response := response , temp , ']'.
							response := response copyReplaceAll: String lf with: ','.
							aBlock value: response.
							ready := true.
							false ]
						ifFalse: [ response := response , aString.
							true ] ] ]
]

{ #category : #accessing }
AgdaMode >> initialize [

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
	self getResp.
]

{ #category : #accessing }
AgdaMode >> kill [
 agda kill.
]

{ #category : #accessing }
AgdaMode >> query: aQuery [

	ready
		ifTrue: [ ready := false.
			input
				nextPutAll: aQuery asString;
				lf.
				]
		ifFalse: [ ^ ready ]

]

{ #category : #accessing }
AgdaMode >> query: aQuery with: aBlock [
	ready
		ifTrue: [ ready := false.
			input
				nextPutAll: aQuery asString;
				lf.
				self getRespWith: aBlock.
				]
		ifFalse: [ ^ ready ]
]

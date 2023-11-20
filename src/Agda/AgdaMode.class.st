Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input',
		'response'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaMode >> getResp [
	response := ''.
	out pollStringWhileTrue: 20 milliseconds do: [ :aString |
	 (aString findString: 'JSON>')
		in: [ :index | index > 0 ifTrue: [ response := response , (aString copyFrom: 1 to: index - 1). false ] ifFalse: [ response := response , aString. true ]]].
		
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
	err := agda asynchronousStderr
]

{ #category : #accessing }
AgdaMode >> query: aQuery [

 input nextPutAll: aQuery asString ; lf.

]

Class {
	#name : #AgdaMode,
	#superclass : #Object,
	#instVars : [
		'agda',
		'out',
		'err',
		'input'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaMode >> getResp [
 ^ out pollString
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
AgdaMode >> query: aString [ 

 input nextPutAll: aString; lf.
]

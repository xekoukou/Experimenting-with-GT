Class {
	#name : #IOFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'asyncBuffer',
		'childProcess'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
IOFuture class >> process: aChildProcess buff: aBuffer [
	^ self new process: aChildProcess buff: aBuffer
]

{ #category : #'api - future' }
IOFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>
	| string |
	string := asyncBuffer pollString.
	string
		ifEmpty: [ childProcess isTerminated
				ifTrue: [ ChildProcessTerminated new ]
				ifFalse: [ ^ AsyncPoll pending ] ]
		ifNotEmpty: [ :aString | ^ AsyncPoll ready: aString ]
]

{ #category : #accessing }
IOFuture >> process: aChildProcess buff: aBuffer [
	childProcess := aChildProcess.
	asyncBuffer := aBuffer
]

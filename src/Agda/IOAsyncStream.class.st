Class {
	#name : #IOAsyncStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'asyncBuffer',
		'childProcess',
		'waker'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
IOAsyncStream class >> process: aChildProcess buff: aBuffer [
	^ self new process: aChildProcess buff: aBuffer
]

{ #category : #accessing }
IOAsyncStream >> initialize [
	super initialize.
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : #'api - stream' }
IOAsyncStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."

	<return: #AsyncPoll>
	| string |
	waker register: anAsynchronousContext waker.
	string := asyncBuffer pollString.
	string
		ifEmpty: [ childProcess isTerminated
				ifTrue: [ AsyncPoll ready: AsyncOptionalValue none ]
				ifFalse: [ [ 10 milliSeconds wait. waker wakeUp ] asAsyncFuture await . ^ AsyncPoll pending ] ]
		ifNotEmpty: [ :aString | ^ AsyncPoll ready: (AsyncOptionalValue some: aString) ]
]

{ #category : #accessing }
IOAsyncStream >> process: aChildProcess buff: aBuffer [
	childProcess := aChildProcess.
	asyncBuffer := aBuffer
]

Class {
	#name : #AgdaFile,
	#superclass : #Object,
	#instVars : [
		'path'
	],
	#classVars : [
		'agda'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaFile class >> path: aPath [
agda ifNotNil: [agda isTerminated ifTrue: [agda := AgdaMode new.]] ifNil: [agda := AgdaMode new.].
^ self new path: aPath.
]

{ #category : #accessing }
AgdaFile >> gtContentsFor: aView [
	<gtView>
	^ aView forward
		title: 'contents';
		priority: 10;
		object: [ path asFileReference ];
		view: #gtContentsFor:
]

{ #category : #accessing }
AgdaFile >> path: aPath [ 
 path := aPath
]

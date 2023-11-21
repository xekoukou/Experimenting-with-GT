Class {
	#name : #AgdaQuery,
	#superclass : #Object,
	#instVars : [
		'highlightingLevel',
		'highlightingMethod',
		'interaction',
		'filePath'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaQuery >> Direct [
 highlightingMethod := 'Direct'.
]

{ #category : #accessing }
AgdaQuery >> InDirect [
 highlightingMethod := 'Indirect'.
]

{ #category : #accessing }
AgdaQuery >> Interactive [
 highlightingLevel := 'Interactive'.
]

{ #category : #accessing }
AgdaQuery >> NonInteractive [
 highlightingLevel := 'NonInteractive'.
]

{ #category : #accessing }
AgdaQuery >> None [
 highlightingLevel := 'None'.
]

{ #category : #accessing }
AgdaQuery >> asString [
 ^ 'IOTCM ' , '"' , filePath pathString , '" ' , highlightingLevel , ' ' , highlightingMethod , ' (' , interaction , ')'.
]

{ #category : #accessing }
AgdaQuery >> gtQueryFor: aView [
	<gtView>
	^ aView forward
		title: 'query';
		priority: 10;
		object: [ self asString ];
		view: #gtStringFor:
]

{ #category : #accessing }
AgdaQuery >> initialize [
 self NonInteractive ;
 Direct;
 load: Path * ''.
]

{ #category : #accessing }
AgdaQuery >> load [

 interaction := 'Cmd_load "' , filePath pathString , '" []'.
]

{ #category : #accessing }
AgdaQuery >> load: aFilePath [
 
 filePath := aFilePath.
 interaction := 'Cmd_load "' , filePath pathString , '" []'.
]

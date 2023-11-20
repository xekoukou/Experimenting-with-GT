Class {
	#name : #AgdaQuery,
	#superclass : #Object,
	#instVars : [
		'result',
		'highlightingLevel',
		'highlightingMethod',
		'interaction',
		'filePath'
	],
	#category : #'ExperimentingWithGT-agda'
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
AgdaQuery >> initialize [
 highlightingLevel := 'Interactive'.
 highlightingMethod := 'Indirect'.
 interaction := 'Cmd_constrains'.
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

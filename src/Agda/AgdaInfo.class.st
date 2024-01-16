Class {
	#name : #AgdaInfo,
	#superclass : #BrEditor,
	#instVars : [
		'agdaF'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaInfo class >> new: anAgdaFile [
    
	^ self new initialize:anAgdaFile
]

{ #category : #accessing }
AgdaInfo >> handleEvents [
	agdaF announcer when: NewInfo do: [  self updateText ]
]

{ #category : #accessing }
AgdaInfo >> initialize: anAgdaFile [ 
super initialize.
agdaF := anAgdaFile.
self updateText.
self handleEvents.
self shortcuts.
]

{ #category : #accessing }
AgdaInfo >> shortcuts [


]

{ #category : #accessing }
AgdaInfo >> updateText [
self inUIProcessDo: [ self editor text: (agdaF infoTabGroup) glamorousCodeFont ].
]

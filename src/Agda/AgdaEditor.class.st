Class {
	#name : #AgdaEditor,
	#superclass : #BrEditor,
	#instVars : [
		'agdaF'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> new: anAgdaFile [
    
	^ self new initialize:anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> handeEvents [
	self editor
		when: BrTextEditorInsertedEvent
			do: [ agdaF changeBlock value: self parent value: self ];
		when: BrTextEditorDeletedEvent
			do: [ agdaF changeBlock value: self parent value: self ];
		when: BlInfiniteDataSourceChanged
			do: [ agdaF changeBlock value: self parent value: self ].
]

{ #category : #accessing }
AgdaEditor >> initialize: anAgdaFile [ 
super initialize.
agdaF := anAgdaFile.
self handeEvents.
]

Class {
	#name : #AgdaEditor,
	#superclass : #BrEditor,
	#instVars : [
		'path',
		'agdaFile',
		'numberOfChanges'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> agdaFile: anAgdaFile [
	^ self new agdaFile: anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> agdaFile: anAgdaFile [
	agdaFile := anAgdaFile.
	numberOfChanges := 0.
	self
		aptitude: BrEditorAptitude new;
		text: agdaFile ropedText unstyle;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self ifEditable.
	self handleChange.
	self defaultEvents
]

{ #category : #accessing }
AgdaEditor >> defaultEvents [
	| block |
	block := [ numberOfChanges > 10
			ifTrue: [ self save ]
			ifFalse: [ numberOfChanges := numberOfChanges + 1 ] ].
	self editor
		when: BrTextEditorInsertedEvent do: block;
		when: BrTextEditorDeletedEvent do: block;
		when: BlInfiniteDataSourceChanged do: block
]

{ #category : #accessing }
AgdaEditor >> handleChange [
agdaFile announcer when: EditableChanged send: #ifEditable to: self.
]

{ #category : #accessing }
AgdaEditor >> ifEditable [
	agdaFile isEditable
		ifTrue: [ self beEditable ]
		ifFalse: [ self beReadOnlyWithSelection ]
]

{ #category : #accessing }
AgdaEditor >> save [
	numberOfChanges := 0.
	agdaFile save: self text.
	self assert: self text = agdaFile ropedText
]

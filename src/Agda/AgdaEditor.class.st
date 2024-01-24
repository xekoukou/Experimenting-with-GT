Class {
	#name : #AgdaEditor,
	#superclass : #BrEditor,
	#instVars : [
		'path',
		'agdaFile'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> agdaFile: anAgdaFile [
	self new agdaFile: anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> agdaFile: anAgdaFile [
	agdaFile := anAgdaFile.
	self
		aptitude: BrEditorAptitude new;
		text: agdaFile ropedText unstyle;
		constraintsDo: [ :c | 
			c horizontal matchParent
			c vertical matchParent ].
	self ifEditable.
	self handleChange.
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

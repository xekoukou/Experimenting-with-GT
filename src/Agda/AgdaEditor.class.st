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
AgdaEditor >> changeBlock [
	^ [ self parent
		childNamed: #modificationBar
		ifFound: [ :elmt | 
			elmt
				inUIProcessDo: [ elmt
						background: ((self editor text equalsIgnoringAttributes: agdaF savedText)
								ifTrue: [ Color transparent ]
								ifFalse: [ elmt theme status changesBackgroundColor ]) ] ] ]
]

{ #category : #accessing }
AgdaEditor >> handeEvents [
	self editor
		when: BrTextEditorInsertedEvent do: self changeBlock;
		when: BrTextEditorDeletedEvent do: self changeBlock;
		when: BlInfiniteDataSourceChanged do: self changeBlock.
]

{ #category : #accessing }
AgdaEditor >> initialize: anAgdaFile [ 
super initialize.
agdaF := anAgdaFile.
self handeEvents.
]

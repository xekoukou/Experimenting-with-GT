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
			agdaF announcer when: NewHighLight do: [self inUIProcessDo: [self updateText]].
]

{ #category : #accessing }
AgdaEditor >> initialize: anAgdaFile [ 
super initialize.
agdaF := anAgdaFile.
self editor text: (agdaF savedText) glamorousCodeFont.
self handeEvents.
self shortcuts.
]

{ #category : #accessing }
AgdaEditor >> shortcuts [
	self
		addShortcut: (BlShortcutWithAction new
				combination: BlKeyCombination primaryS;
				action: [ agdaF saveBlock value: self parent value: self] ).
	self
		addShortcut: (BlShortcutWithAction new
				combination: BlKeyCombination primaryC;
				action: [ | query |
					agdaF saveBlock value: self parent value: self.
					query := AgdaQuery new load: (agdaF path).
					agdaF query: query ]).
	

]

{ #category : #accessing }
AgdaEditor >> updateText [
self editor text: (agdaF savedText) glamorousCodeFont.
]

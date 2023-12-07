Class {
	#name : #AgdaEditor,
	#superclass : #BrEditor,
	#instVars : [
		'agdaF',
		'saveSC',
		'loadSC'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> new: anAgdaFile [
    
	^ self new initialize:anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> handleEvents [
	self editor
		when: BrTextEditorInsertedEvent
			do: [ agdaF changeBlock value: self parent value: self ];
		when: BrTextEditorDeletedEvent
			do: [ agdaF changeBlock value: self parent value: self ];
		when: BlInfiniteDataSourceChanged
			do: [ agdaF changeBlock value: self parent value: self ].
	agdaF announcer
		when: NewHighLight
		do: [ self updateText.
			self addShortcut: loadSC ]
]

{ #category : #accessing }
AgdaEditor >> initialize: anAgdaFile [ 
super initialize.
agdaF := anAgdaFile.
self editor text: (agdaF savedText) glamorousCodeFont.
self handleEvents.
self shortcuts.
]

{ #category : #accessing }
AgdaEditor >> shortcuts [
	saveSC := BlShortcutWithAction new
			combination: BlKeyCombination primaryS;
			action: [ agdaF saveBlock value: self parent value: self ].
	loadSC := BlShortcutWithAction new
			combination: BlKeyCombination primaryC;
			action: [ | query |
				agdaF saveBlock value: self parent value: self.
				query := AgdaQuery new load: agdaF path.
				agdaF query: query.
				self removeShortcut: loadSC ].

	self addShortcut: saveSC.
	self addShortcut: loadSC
]

{ #category : #accessing }
AgdaEditor >> updateText [
	self
		inUIProcessDo: [ self editor text: agdaF savedText glamorousCodeFont.
			agdaF changeBlock value: self parent value: self ]
]

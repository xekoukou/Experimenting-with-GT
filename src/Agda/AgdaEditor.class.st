Class {
	#name : #AgdaEditor,
	#superclass : #BlElement,
	#instVars : [
		'agdaF',
		'label',
		'editor',
		'savedText',
		'vpane',
		'info',
		'numberOfChanges'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> for: anAgdaFile [
    
	^ self new for:anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> editor [
	editor := BrEditor new.
	editor
		aptitude: BrEditorAptitude new;
		text: (savedText unstyle);
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self editorShortCuts.
	self editorEvents.
	^ editor
]

{ #category : #accessing }
AgdaEditor >> editorEvents [
	| block |
	block := [ self numberOfChanges > 10
			ifTrue: [ self numberOfChanges: 0.
				agdaF save: editor text asString ]
			ifFalse: [ self numberOfChanges: self numberOfChanges + 1 ] ].
	editor editor
		when: BrTextEditorInsertedEvent do: block;
		when: BrTextEditorDeletedEvent do: block;
		when: BlInfiniteDataSourceChanged do: block
]

{ #category : #accessing }
AgdaEditor >> editorShortCuts [
	| load |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ | future |
				agdaF save: editor text asString.
				future := agdaF load.
				self recurseFuture: future ].
	editor addShortcut: load
]

{ #category : #accessing }
AgdaEditor >> for: anAgdaFile [
	super initialize.
	agdaF := anAgdaFile.
	savedText := agdaF savedText.
	vpane := BrVerticalPane new matchParent.
	numberOfChanges := 0.
	self editor.
	vpane addChild: editor as: 'editor'.
	vpane addChild: self horBorder as: 'border'.
	vpane addChild: self info as: 'info'.
	self addChild: vpane.
	self
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : #accessing }
AgdaEditor >> horBorder [
	| border |
	border := BlElement new
			height: 5;
			constraintsDo: [ :c | c horizontal matchParent ];
			background: Color gray;
			yourself.
	^ border
]

{ #category : #accessing }
AgdaEditor >> info [
	info := BrEditor new.
	info
		aptitude: BrEditorAptitude new;
		text: 'Welcome to Agda';
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent. ];
		beReadOnlyWithoutSelection..
	^ info
]

{ #category : #accessing }
AgdaEditor >> numberOfChanges [
^ numberOfChanges
]

{ #category : #accessing }
AgdaEditor >> numberOfChanges: anInteger [
	numberOfChanges := anInteger
]

{ #category : #accessing }
AgdaEditor >> recurseFuture: aFuture [
	aFuture
		ifNotNil: [ | nextFuture |
			self
				withAsyncFutureDo: [ :anElementFuture | 
					anElementFuture
						whenSuccess: [ :celement :resp | 
							| ceditor cinfo |
							ceditor := self childNamed: 'editor'.
							cinfo := self childNamed: 'info'.
							resp
								ifNotNil: [ nextFuture := resp at: 2.
									agdaF handleResponse: (resp at: 1).
									self recurseFuture: nextFuture ]
								ifNil: [ ceditor beEditable ] ];
						whenError: [ :celement :anError | 
							| ceditor cinfo |
							ceditor := self childNamed: 'editor'.
							cinfo := self childNamed: 'info'.
							ceditor text: anError printString ];
						whenPending: [ :celement | 
							| ceditor cinfo |
							ceditor := self childNamed: 'editor'.
							cinfo := self childNamed: 'info'.
							ceditor beReadOnlyWithSelection ].
					anElementFuture future: aFuture ] ]
]

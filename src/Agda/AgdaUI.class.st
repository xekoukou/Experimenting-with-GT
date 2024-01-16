Class {
	#name : #AgdaUI,
	#superclass : #BlElement,
	#instVars : [
		'agdaF',
		'label',
		'editor',
		'vpane',
		'numberOfChanges',
		'displayInfo',
		'infoTabGroup',
		'runningInfo'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaUI class >> for: anAgdaFile [
    
	^ self new for:anAgdaFile
]

{ #category : #accessing }
AgdaUI >> editor [
	editor := BrEditor new.
	editor
		aptitude: BrEditorAptitude new;
		text: agdaF ropedText unstyle;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical matchParent ].
	self editorShortCuts.
	self editorEvents.
	^ editor
]

{ #category : #accessing }
AgdaUI >> editorEvents [
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
AgdaUI >> editorShortCuts [
	| load save |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ | future |
				agdaF save: editor text .
				self assert: (editor text = agdaF ropedText).
				editor text: agdaF ropedText.
				future := agdaF load.
				self recurseFuture: future ].
	save := BlShortcutWithAction new
			combination: BlKeyCombination primaryS;
			action: [ self numberOfChanges: 0.
				agdaF save: editor text. ].

	editor addShortcut: load.
	editor addShortcut: save.
]

{ #category : #accessing }
AgdaUI >> for: anAgdaFile [
	super initialize.
	agdaF := anAgdaFile.
	vpane := BrVerticalPane new matchParent.
	numberOfChanges := 0.
	self editor.
	vpane addChild: editor as: 'editor'.
	vpane addChild: self horBorder as: 'border'.
	vpane addChild: self infoTabGroup as: 'info'.
	self addChild: vpane.
	self
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : #accessing }
AgdaUI >> gtJSONDataFor: aView context: aContext [
	<gtView>
	aContext at: #gtTreeExpansionLevel put: 1.
	aContext
		at: #gtTreeValueStyler
		put: [ :aNode | 
			aNode key = 'kind'
				ifFalse: [ aNode value gtDisplayText ]
				ifTrue: [ aNode value asRopedText highlight: Color yellow darker ] ].


	^ aView forward
		title: 'Agda Msgs';
		priority: 1;
		object: [ agdaF agdaMsgs ];
		view: #gtTreeFor:context:
]

{ #category : #accessing }
AgdaUI >> gtModelFor: aView [
	<gtView>
	^ aView explicit
		title: 'Meta Model';
		priority: 1;
		stencil: [ (GtCoderElement forObject: agdaF) disablePlayPage ]
]

{ #category : #accessing }
AgdaUI >> horBorder [
	| border |
	border := BlElement new
			height: 5;
			constraintsDo: [ :c | c horizontal matchParent ];
			background: Color gray;
			yourself.
	^ border
]

{ #category : #accessing }
AgdaUI >> infoTabGroup [
	infoTabGroup := BrTabGroup new.
	infoTabGroup
		aptitude: BrGlamorousTabGroupAptitude new;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent ].

	displayInfo := BrEditor new.
	displayInfo
		aptitude: BrEditorAptitude new;
		text: agdaF displayInfo;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent ];
		beReadOnlyWithSelection.

	runningInfo := BrEditor new.
	runningInfo
		aptitude: BrEditorAptitude new;
		text: agdaF runningInfo;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent ];
		beReadOnlyWithSelection.

	infoTabGroup
		addTab: (BrTab new
				aptitude: BrGlamorousTabAptitude new;
				label: 'display info';
				stencil: [ displayInfo ]);
		addTab: (BrTab new
				aptitude: BrGlamorousTabAptitude new;
				label: 'running info';
				stencil: [ runningInfo ]).





	^ infoTabGroup
]

{ #category : #accessing }
AgdaUI >> numberOfChanges [
^ numberOfChanges
]

{ #category : #accessing }
AgdaUI >> numberOfChanges: anInteger [
	numberOfChanges := anInteger
]

{ #category : #accessing }
AgdaUI >> recurseFuture: aFuture [
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

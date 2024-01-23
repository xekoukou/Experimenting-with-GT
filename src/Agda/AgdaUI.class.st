Class {
	#name : #AgdaUI,
	#superclass : #BlElement,
	#instVars : [
		'label',
		'editors',
		'vpane',
		'numberOfChanges',
		'displayInfo',
		'infoTabGroup',
		'runningInfo',
		'hpane',
		'agdaModel'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaUI class >> for: anAgdaModel [
    
	^ self new for:anAgdaModel
]

{ #category : #accessing }
AgdaUI >> editorEvents: anEditor [
	| block |
	block := [ self numberOfChanges > 10
			ifTrue: [ self numberOfChanges: 0.
				agdaModel save: anEditor text asString ]
			ifFalse: [ self numberOfChanges: self numberOfChanges + 1 ] ].
	anEditor editor
		when: BrTextEditorInsertedEvent do: block;
		when: BrTextEditorDeletedEvent do: block;
		when: BlInfiniteDataSourceChanged do: block
]

{ #category : #accessing }
AgdaUI >> editorFor: aPath [
	| editor |
	editor := BrEditor new.
	editor
		aptitude: BrEditorAptitude new;
		text: (agdaModel agdaFiles at: aPath) ropedText unstyle;
		constraintsDo: [ :c | 
			c horizontal exact: 700.
			c vertical matchParent ].
	self editorShortCuts: editor.
	self editorEvents: editor.
	^ editor
]

{ #category : #accessing }
AgdaUI >> editorShortCuts: anEditor [
	| load save |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ | future |
				infoTabGroup selectTabWithLabelString: 'running info'.
				agdaModel save: anEditor text.
				self assert: anEditor text = agdaModel ropedText.
				future := agdaModel load.
				self
					recurseFuture: future
					final: [ infoTabGroup selectTabWithLabelString: 'display info' ] ].
	save := BlShortcutWithAction new
			combination: BlKeyCombination primaryS;
			action: [ self numberOfChanges: 0.
				agdaModel save: anEditor text ].

	anEditor addShortcut: load.
	anEditor addShortcut: save
]

{ #category : #accessing }
AgdaUI >> for: anAgdaModel [
	super initialize.
	agdaModel := anAgdaModel.
	vpane := BrVerticalPane new matchParent.
	hpane := BrHorizontalPane new matchParent.
	numberOfChanges := 0.
	hpane addChild: (self editorFor: agdaModel mpath) as: 'main editor'.
	hpane addChild: self verBorder as: 'verBorder'.
	vpane addChild: hpane as: 'hpane'.
	vpane addChild: self horBorder as: 'horBorder'.
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
	^ aView forward
		title: 'Agda Msgs';
		priority: 1;
		object: [ agdaModel ];
		view: #gtJSONDataFor:context:
]

{ #category : #accessing }
AgdaUI >> gtMetaFor: aView [
	<gtView>
	^ aView explicit
		title: 'Meta';
		priority: 1;
		stencil: [ (GtCoderElement forObject: self) disablePlayPage ]
]

{ #category : #accessing }
AgdaUI >> gtModelMetaFor: aView [
	<gtView>
	^ aView explicit
		title: 'Model Meta';
		priority: 1;
		stencil: [ (GtCoderElement forObject: agdaModel) disablePlayPage ]
]

{ #category : #accessing }
AgdaUI >> gtModelRawFor: aView [
	<gtView>
	^ aView forward
		title: 'Model Raw';
		priority: 1;
		object: [ agdaModel ];
		view: #gtRawFor:
]

{ #category : #accessing }
AgdaUI >> horBorder [
	| border |
	border := BlElement new
			height: 2;
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
		text: agdaModel displayInfo;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical fitContent ];
		beReadOnlyWithSelection.

	runningInfo := BrEditor new.
	runningInfo
		aptitude: BrEditorAptitude new;
		text: agdaModel runningInfo;
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
	self recurseFuture: aFuture final: [  ]
]

{ #category : #accessing }
AgdaUI >> recurseFuture: aFuture final: aBlock [
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
									agdaModel handleResponse: (resp at: 1).
									self recurseFuture: nextFuture final: aBlock ]
								ifNil: [ aBlock value.
									ceditor beEditable ] ];
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

{ #category : #accessing }
AgdaUI >> verBorder [
	| border |
	border := BlElement new
			width: 2;
			constraintsDo: [ :c | c vertical matchParent ];
			background: Color gray;
			yourself.
	^ border
]

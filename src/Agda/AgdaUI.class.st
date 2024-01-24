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
		'agdaModel',
		'editorIdtoPath'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaUI class >> for: anAgdaModel [
	self new for: anAgdaModel
]

{ #category : #accessing }
AgdaUI >> addEditorOnHpane: aPath on: anId [
	hpane addChild: (self editorFor: aPath) as: anId.
	editorIdtoPath at: anId put: aPath
]

{ #category : #accessing }
AgdaUI >> editorEventsFor: anEditor path: aPath [
	| block |
	block := [ self numberOfChanges > 10
			ifTrue: [ self numberOfChanges: 0.
				(agdaModel agdaFiles at: aPath) save: anEditor text asString ]
			ifFalse: [ self numberOfChanges: self numberOfChanges + 1 ] ].
	anEditor editor
		when: BrTextEditorInsertedEvent do: block;
		when: BrTextEditorDeletedEvent do: block;
		when: BlInfiniteDataSourceChanged do: block
]

{ #category : #accessing }
AgdaUI >> editorFor: aPath [
	| editor agdaF |
	agdaF := agdaModel agdaFiles at: aPath.
	editor := BrEditor new.
	editor
		aptitude: BrEditorAptitude new;
		text: (agdaModel agdaFiles at: aPath) ropedText unstyle;
		constraintsDo: [ :c | 
			c horizontal exact: 700.
			c vertical matchParent ].
	agdaF isEditable
		ifTrue: [ editor beEditable ]
		ifFalse: [ editor beReadOnlyWithSelection ].
	self editorShortCutsFor: editor path: aPath.
	self editorEventsFor: editor path: aPath.
	^ editor
]

{ #category : #accessing }
AgdaUI >> editorShortCutsFor: anEditor path: aPath [
	| load save |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ | future |
				infoTabGroup selectTabWithLabelString: 'running info'.
				(agdaModel agdaFiles at: aPath) save: anEditor text.
				self assert: anEditor text = (agdaModel agdaFiles at: aPath) ropedText.
				future := agdaModel load.
				self
					recurseFuture: future
					whenSuccess: [ :celement :resp | agdaModel handleResponse: resp ]
					final: [ infoTabGroup selectTabWithLabelString: 'display info' ] ].
	save := BlShortcutWithAction new
			combination: BlKeyCombination primaryS;
			action: [ self numberOfChanges: 0.
				(agdaModel agdaFiles at: aPath) save: anEditor text ].

	anEditor addShortcut: load.
	anEditor addShortcut: save
]

{ #category : #accessing }
AgdaUI >> for: anAgdaModel [
	agdaModel := anAgdaModel
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
AgdaUI >> initialize [
	super initialize.
	agdaModel ifNil: [ agdaModel := AgdaModel new ].
	editorIdtoPath := Dictionary new.
	vpane := BrVerticalPane new matchParent.
	hpane := BrHorizontalPane new matchParent.
	numberOfChanges := 0.
	self addEditorOnHpane: agdaModel fpath on: 'main editor'.
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
AgdaUI >> numberOfChanges [
^ numberOfChanges
]

{ #category : #accessing }
AgdaUI >> numberOfChanges: anInteger [
	numberOfChanges := anInteger
]

{ #category : #accessing }
AgdaUI >> recurseFuture: aFuture whenSuccess: aSucessBlock final: aBlock [
	aFuture
		ifNotNil: [ | nextFuture |
			self
				withAsyncFutureDo: [ :anElementFuture | 
					anElementFuture
						whenSuccess: [ :celement :resp | 
							| ceditor |
							ceditor := celement childNamed: 'main editor'.
							resp
								ifNotNil: [ nextFuture := resp at: 2.
									aSucessBlock cull: celement cull: (resp at: 1).
									self
										recurseFuture: nextFuture
										whenSuccess: aSucessBlock
										final: aBlock ]
								ifNil: [ aBlock value.
									editorIdtoPath
										valuesDo: [ :aPath | 
											| agdaF |
											agdaF := agdaModel agdaFiles at: aPath.
											agdaF isEditable
												ifTrue: [ agdaF beEditable ]
												ifFalse: [ agdaF beReadOnly ] ] ] ];
						whenError: [ :celement :anError | 
							| ceditor |
							ceditor := celement childNamed: 'main editor'.

							ceditor text: anError printString ];
						whenPending: [ :celement | 
							editorIdtoPath
								valuesDo: [ :aPath | 
									| agdaF |
									agdaF := agdaModel agdaFiles at: aPath.
									agdaF beReadOnly ] ].
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

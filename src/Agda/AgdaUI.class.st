Class {
	#name : #AgdaUI,
	#superclass : #BlElement,
	#instVars : [
		'vpane',
		'displayInfo',
		'infoTabGroup',
		'runningInfo',
		'hpane',
		'agdaModel',
		'editorIdtoPath',
		'moreVpane'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaUI class >> for: aPath [
	^ self new for: aPath
]

{ #category : #accessing }
AgdaUI >> agdaShortCutsFor: anEditor [
	| load save |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ | future |
				infoTabGroup selectTabWithLabelString: 'running info'.
				anEditor save.
				future := agdaModel load: (editorIdtoPath at: anEditor id asSymbol asString).
				self
					recurseFuture: future
					whenSuccess: [ :celement :resp | agdaModel handleResponse: resp ]
					final: [ infoTabGroup selectTabWithLabelString: 'display info' ] ].
	save := BlShortcutWithAction new
			combination: BlKeyCombination primaryS;
			action: [ anEditor save ].

	anEditor addShortcut: load.
	anEditor addShortcut: save
]

{ #category : #accessing }
AgdaUI >> editorFor: aPath as: anId do: aBlock [
	| editor agdaF |
	agdaF := agdaModel newFile: aPath.
	editor := AgdaEditor agdaFile: agdaF.
	editorIdtoPath at: anId put: aPath.
	aBlock value: anId value: editor
]

{ #category : #accessing }
AgdaUI >> for: aPath [
	self
		editorFor: aPath
		as: 'main editor'
		do: [ :anId :anEditor | 
			anEditor
				constraintsDo: [ :c | 
					c horizontal exact: 700.
					c vertical matchParent ].
			hpane addChildFirst: anEditor as: anId.
			self agdaShortCutsFor: anEditor ]
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
AgdaUI >> handleChange [
	agdaModel announcer
		when: UpdateOpenLinks
		send: #openLinks
		to: self
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
	agdaModel := AgdaModel new.
	editorIdtoPath := Dictionary new.
	vpane := BrVerticalPane new matchParent.
	moreVpane := BrVerticalPane new matchParent.
	hpane := BrHorizontalPane new matchParent.
	hpane addChild: self verBorder as: 'verBorder'.
	hpane addChild: moreVpane.
	vpane addChild: hpane as: 'hpane'.
	vpane addChild: self horBorder as: 'horBorder'.
	vpane addChild: self infoTabGroup as: 'info'.
	self addChild: vpane.
	self
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self handleChange
]

{ #category : #accessing }
AgdaUI >> openLinks [
	moreVpane removeChildren.
	agdaModel openLinks
		do: [ :each | 
			| pathString position |
			pathString := each at: 1.
			position := each at: 2.
			self
				editorFor: (Path from: pathString)
				as: pathString , position asString
				do: [ :anId :anEditor | 
					| accordion hh removeButton |
					hh := BrHorizontalPane new matchParent.
					accordion := BrAccordion new.
					accordion
						constraintsDo: [ :c | 
							c horizontal matchParent.
							c vertical matchParent ];
						aptitude: BrGlamorousAccordionAptitude2 new;
						header: [ BrButton new
								aptitude: BrMaterialToggleLabelledAptitude new;
								label: 'hellofdgfdg fdg fdg fdf';
								action: [ accordion toggleExpanded ] ];
						content: [ anEditor
								constraintsDo: [ :c | 
									c horizontal exact: 700.
									c vertical matchParent ] ].
					removeButton := BrButton new
							aptitude: BrGlamorousButtonLabelAptitude new;
							label: 'remove';
							action: [ accordion toggleExpanded ].
					hh
						addChild: accordion;
						addChild: removeButton.
					moreVpane addChild: hh ] ]
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
								keysDo: [ :anId | 
									| editor |
									editor := self childNamed: anId.
									editor beReadOnlyWithSelection ] ].
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

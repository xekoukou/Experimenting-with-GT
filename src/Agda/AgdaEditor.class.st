Class {
	#name : #AgdaEditor,
	#superclass : #Object,
	#instVars : [
		'path',
		'editor',
		'file',
		'savedText',
		'editorPane',
		'agda'
	],
	#classVars : [
		'agdaC'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> path: aPath [
agdaC ifNotNil: [agdaC isTerminated ifTrue: [agdaC := AgdaMode new.]] ifNil: [agdaC := AgdaMode new.].
^ self new initialize: aPath.
]

{ #category : #accessing }
AgdaEditor >> changeHappened [
	editorPane
		childNamed: #modificationBar
		ifFound: [ :elmt | 
			elmt
				inUIProcessDo: [ elmt
						background: ((editor editor text equalsIgnoringAttributes: savedText)
								ifTrue: [ Color transparent ]
								ifFalse: [ elmt theme status changesBackgroundColor ]) ] ]
]

{ #category : #accessing }
AgdaEditor >> createShortcuts [
	editor
		addShortcut: (BlShortcutWithAction new
				combination: BlKeyCombination primaryS;
				action: [ self save ]).

]

{ #category : #accessing }
AgdaEditor >> discard [
editor editor text: (BlRunRopedText file: file) glamorousRegularFont.
					self changeHappened.
]

{ #category : #accessing }
AgdaEditor >> gtContentsFor: aView [
	<gtView>
	| eventLoop |
	file isFile ifFalse: [ ^ aView empty ].
	[ file readStreamDo: [ :s | s next: 1000 ] ]
		on: ZnInvalidUTF8
		do: [ ^ aView empty ].

	eventLoop := file watcher startLoop.

	^ aView explicit
		title: 'Contents' translated;
		priority: 3;
		updateWhen: GtFileWatcherModificationAnnouncement in: eventLoop announcer;
		stencil: [ self gtEditorView ]
]

{ #category : #accessing }
AgdaEditor >> gtEditorView [
	| pane toolbar|
	pane := BrVerticalPane new matchParent.
	editorPane matchParent.
	editorPane padding: (BlInsets all:5).
	editor matchParent.
	editor editor
		when: BrTextEditorInsertedEvent do: [ self changeHappened ];
		when: BrTextEditorDeletedEvent do: [ self changeHappened ];
		when: BlInfiniteDataSourceChanged do: [ self changeHappened ].
	editorPane
		addChild: (BlElement new
					width: 5;
					constraintsDo: [ :c | c vertical matchParent ];
					yourself)
			as: #modificationBar;
		addChild: editor as: #editor.
	toolbar := BrToolbar new
			fitContent;
			margin: (BlInsets bottom: 5).
	toolbar
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				beSmallSize;
				icon: BrGlamorousVectorIcons accept;
				label: 'Save';
				action: [ self save ])
		as: #saveButton.
	toolbar
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				beSmallSize;
				icon: BrGlamorousVectorIcons cancel;
				label: 'Cancel';
				action: [ self discard ])
		as: #cancelButton.
	pane addChild: editorPane.
	pane addChild: toolbar as: #toolbar.
	^ pane
			
]

{ #category : #accessing }
AgdaEditor >> gtJSONDataFor: aView [
	<gtView>
	^ aView forward
		title: 'JSON Data';
		priority: 10;
		object: [ agda ];
		view: #gtJSONDataFor:
]

{ #category : #accessing }
AgdaEditor >> handleResponse: aResp [
]

{ #category : #accessing }
AgdaEditor >> initialize: aPath [
    agda := agdaC.
    path := aPath.
	file := path asFileReference.
	savedText := BlRunRopedText file: file.
	editorPane := BrHorizontalPane new.
	editor := BrEditor new.
	editor editor text: savedText.
	self createShortcuts.
]

{ #category : #accessing }
AgdaEditor >> save [

	file gtSaveContents: (editor editor text asString).
	savedText := BlRunRopedText file: file.
	
	self changeHappened.
]

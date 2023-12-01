Class {
	#name : #AgdaEditor,
	#superclass : #Object,
	#instVars : [
		'path',
		'file',
		'savedText',
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
	| pane editor editorPane changeBlock toolbar saveBlock |
	savedText := BlRunRopedText file: file.
	pane := BrVerticalPane new matchParent.
	editorPane := BrHorizontalPane new matchParent.
	editorPane padding: (BlInsets all: 5).
	editor := BrEditor new matchParent.
	changeBlock := [ editorPane
			childNamed: #modificationBar
			ifFound: [ :elmt | 
				elmt
					inUIProcessDo: [ elmt
							background: ((editor editor text equalsIgnoringAttributes: savedText)
									ifTrue: [ Color transparent ]
									ifFalse: [ elmt theme status changesBackgroundColor ]) ] ] ].
	saveBlock := [ file gtSaveContents: editor text asString.
		savedText := BlRunRopedText file: file.
		changeBlock value ].
	editor editor
		when: BrTextEditorInsertedEvent do: changeBlock;
		when: BrTextEditorDeletedEvent do: changeBlock;
		when: BlInfiniteDataSourceChanged do: changeBlock.
	editor
		addShortcut: (BlShortcutWithAction new
				combination: BlKeyCombination primaryS;
				action: saveBlock).
	editor editor text: (BlRunRopedText file: file) glamorousRegularFont.
		editorPane
		addChild: (BlElement new
					width: 5;
					constraintsDo: [ :c | c vertical matchParent ];
					yourself)
			as: #modificationBar;
		addChild: editor as: #editor.
	toolbar := BrToolbar new
			aptitude: (BrGlamorousToolbarAptitude new spacing: 5);
			fitContent;
			margin: (BlInsets bottom: 5).
	toolbar
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				beSmallSize;
				icon: BrGlamorousVectorIcons accept;
				label: 'Save';
				action: saveBlock)
		as: #saveButton.
	toolbar
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				beSmallSize;
				icon: BrGlamorousVectorIcons cancel;
				label: 'Cancel';
				action: [ editor editor text: (BlRunRopedText file: self) glamorousRegularFont.
					changeBlock value ])
		as: #cancelButton.
	pane addChild: editorPane.
	pane addChild: toolbar as: #toolbar.
	^ pane
	
]

{ #category : #accessing }
AgdaEditor >> gtJSONDataFor: aView context: aContext [
	<gtView>
	^ aView forward
		title: 'JSON DATA';
		priority: 5;
		object: [ agda ];
		view: #gtJSONDataFor:context:
]

{ #category : #accessing }
AgdaEditor >> handleResponse: aResp [
]

{ #category : #accessing }
AgdaEditor >> initialize: aPath [
	super initialize.
	agda := agdaC.
	path := aPath.
	file := path asFileReference.
	savedText := BlRunRopedText file: file
]

{ #category : #accessing }
AgdaEditor >> save [

	file gtSaveContents: (editor editor text asString).
	savedText := BlRunRopedText file: file.
	
	self changeHappened.
]
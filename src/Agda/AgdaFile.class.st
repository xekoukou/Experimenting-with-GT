Class {
	#name : #AgdaFile,
	#superclass : #Object,
	#instVars : [
		'path',
		'file',
		'savedText',
		'agda',
		'response',
		'respPos',
		'announcer'
	],
	#classVars : [
		'agdaC'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaFile class >> path: aPath [
agdaC ifNotNil: [agdaC isTerminated ifTrue: [agdaC := AgdaMode new.]] ifNil: [agdaC := AgdaMode new.].
^ self new initialize: aPath.
]

{ #category : #accessing }
AgdaFile >> agda [
^ agda
]

{ #category : #accessing }
AgdaFile >> changeBlock [
	^ [:editorPane :editor | editorPane
			childNamed: #modificationBar
			ifFound: [ :elmt | 
				elmt
					inUIProcessDo: [ elmt
							background: ((editor editor text equalsIgnoringAttributes: savedText)
									ifTrue: [ Color transparent ]
									ifFalse: [ elmt theme status changesBackgroundColor ]) ] ] ].
]

{ #category : #accessing }
AgdaFile >> gtContentsFor: aView [
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
AgdaFile >> gtEditorView [
	| pane editorPane editor toolbar |
	pane := BrVerticalPane new matchParent.
	editorPane := BrHorizontalPane new matchParent.
	editorPane padding: (BlInsets all: 5).
	editor := (AgdaEditor new: self) matchParent.
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
				action: [ self saveBlock value: editorPane value: editor])
		as: #saveButton.
	toolbar
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithIconAptitude;
				beSmallSize;
				icon: BrGlamorousVectorIcons cancel;
				label: 'Cancel';
				action: [ editor editor text: (BlRunRopedText file: self) glamorousCodeFont.
					self changeBlock value: editorPane value: editor ])
		as: #cancelButton.
	pane addChild: editorPane.
	pane addChild: toolbar as: #toolbar.
	^ pane
]

{ #category : #accessing }
AgdaFile >> gtJSONDataFor: aView context: aContext [
	<gtView>
	^ aView forward
		title: 'JSON DATA';
		priority: 5;
		object: [ agda ];
		view: #gtJSONDataFor:context:
]

{ #category : #accessing }
AgdaFile >> handleResponse [
	| data |
	[ respPos < response size ]
		whileTrue: [ respPos := respPos + 1.
			data := STONJSON fromString: (response at: respPos).
			(data at: 'kind') = 'HighlightingInfo' ifTrue: [self highlight: (data at: 'info' at: 'payload').] ]
]

{ #category : #accessing }
AgdaFile >> highlight: anArray [
	savedText unstyle.
	anArray
		do: [ :info | 
			| text range type atoms comp missing |
			missing := true.
			range := info at: 'range'.
			text := savedText from: (range at: 1) to: ((range at: 2) min: savedText size).
			atoms := info at: 'atoms'.
			type := atoms at: 1.
			comp := [ :co | atoms size > 1 ifFalse: [ false ] ifTrue: [ (atoms at: 2) = co ] ].

			type = 'markup'
				ifTrue: [ text foreground: Color red muchDarker.
					missing := false ].
			type = 'symbol'
				ifTrue: [ text foreground: Color black.
					missing := false ].
			type = 'keyword'
				ifTrue: [ text foreground: Color orange muchDarker.
					missing := false ].
			type = 'pragma'
				ifTrue: [ text foreground: Color black.
					missing := false ].
			type = 'comment'
				ifTrue: [ text foreground: Color red muchDarker.
					missing := false ].
			type = 'module'
				ifTrue: [ text foreground: Color purple muchDarker.
					missing := false ].
			type = 'datatype' & (atoms size = 1)
				ifTrue: [ text foreground: Color blue muchDarker.
					missing := false ].
			type = 'datatype' & (comp value: 'operator')
				ifTrue: [ text foreground: Color blue muchDarker.
					missing := false ].
			type = 'primitive'
				ifTrue: [ text foreground: Color blue muchDarker.
					missing := false ].
			type = 'function' & (comp value: 'operator')
				ifTrue: [ text foreground: Color blue muchDarker.
					missing := false ].
			type = 'inductiveconstructor'
				ifTrue: [ text foreground: Color green muchDarker.
					missing := false ].
			type = 'function' & (atoms size = 1)
				ifTrue: [ text foreground: Color blue muchDarker.
					missing := false ].
			type = 'generalizable'
				ifTrue: [ text foreground: Color black.
					missing := false ].
			type = 'bound'
				ifTrue: [ text foreground: Color black.
					missing := false ].
								type = 'background'
				ifTrue: [ text foreground: Color yellow muchDarker.
					missing := false ].
								type = 'record'
				ifTrue: [ text foreground: Color blue muchDarker.
					missing := false ].
								type = 'field'
				ifTrue: [ text foreground: Color red darker.
					missing := false ].
								type = 'number'
				ifTrue: [ text foreground: Color purple muchDarker.
					missing := false ].
			missing ifTrue: [ self inform: 'missing highlight: ' , type ] ]
]

{ #category : #accessing }
AgdaFile >> initialize: aPath [
	super initialize.
	agda := agdaC.
	response := agda response.
	path := aPath.
	file := path asFileReference.
	savedText := BlRunRopedText file: file.
	agda announcer when: NewResponse do: [ self handleResponse ]
]

{ #category : #accessing }
AgdaFile >> path [
^ path
]

{ #category : #accessing }
AgdaFile >> query: aQuery [
	(agda query: aQuery)
		ifTrue: [ respPos := 0.
			agda getResp ]
]

{ #category : #accessing }
AgdaFile >> saveBlock [
	^ [:editorPane :editor | file gtSaveContents: editor text asString.
		savedText := BlRunRopedText file: file.
		self changeBlock value: editorPane value: editor ].
]

{ #category : #accessing }
AgdaFile >> savedText [
^ savedText
]

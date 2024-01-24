Class {
	#name : #AgdaFile,
	#superclass : #Object,
	#instVars : [
		'path',
		'file',
		'ropedText',
		'editable',
		'announcer'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaFile class >> path: aPath [
	^ self new path: aPath
]

{ #category : #accessing }
AgdaFile >> announcer [
	^ announcer
]

{ #category : #accessing }
AgdaFile >> beEditable [
	editable := true.
	announcer announce: EditableChanged.
]

{ #category : #accessing }
AgdaFile >> beReadOnly [
	editable := false.
	announcer announce: EditableChanged.
]

{ #category : #accessing }
AgdaFile >> clearHighlighting [
ropedText unstyle.
]

{ #category : #accessing }
AgdaFile >> highlight: anArray [
	| note |
	anArray
		do: [ :info | 
			| definitionSite text range type atoms comp missing |
			missing := true.
			range := info at: 'range'.
			definitionSite := info at: 'definitionSite'.
			note := info at: 'note'.
			text := ropedText from: (range at: 1) to: (range at: 2) - 1.
			atoms := info at: 'atoms'.
			atoms size > 0
				ifTrue: [ type := atoms at: 1.
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
					type = 'hole'
						ifTrue: [ text highlight: Color green darker.
							missing := false ].
					type = 'operator' ifTrue: [ missing := false ].
					type = 'error'
						ifTrue: [ text highlight: Color yellow darker.
							missing := false ].
					missing ifTrue: [ self inform: 'missing highlight: ' , type ].
					note = '' ifFalse: [ self inform: 'note' , note ].
					definitionSite
						ifNotNil: [ text attributesBuilder
								attribute: (BrTextDoubleClickAttribute new
										action: [ :aTBrTextEditorTextualPiece :aTarget :aTextEditor :anEvent | anEvent currentTarget phlow spawnObject: (AgdaUI for: self)	"(AgdaModel agda: agda path: Path / (definitionSite at: 'filepath')" ]) ] ] ]
]

{ #category : #accessing }
AgdaFile >> isEditable [
	^ editable
]

{ #category : #accessing }
AgdaFile >> path: aPath [
	path := aPath.
	file := path asFileReference.
	ropedText := BlRunRopedText file: file.
	ropedText fontName: 'mononoki'.
	editable := false.
	announcer := Announcer new.
]

{ #category : #accessing }
AgdaFile >> ropedText [
^ ropedText.
]

{ #category : #accessing }
AgdaFile >> save: newContents [
	| string |
	string := newContents asString.
	(file fullName , '.backup') asFileReference ensureDelete.
	file copyTo: (file fullName , '.backup') asFileReference.
	file
		ensureDelete;
		writeStreamDo: [ :s | s nextPutAll: string ].
]

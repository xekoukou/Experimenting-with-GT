Class {
	#name : #AgdaFile,
	#superclass : #Object,
	#instVars : [
		'agda',
		'path',
		'savedText',
		'file',
		'announcer'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaFile class >> agda: anAgda path: aPath [
^ self new agda: anAgda path: aPath.
]

{ #category : #accessing }
AgdaFile >> agda: anAgda path: aPath [
	agda := anAgda.
	path := aPath.
	file := path asFileReference.
	announcer := Announcer new.
	savedText := BlRunRopedText file: file.
	savedText fontName: 'mononoki'.
]

{ #category : #accessing }
AgdaFile >> announcer [
^ announcer.
]

{ #category : #accessing }
AgdaFile >> handleResponse: aNewResponse [
	| data |
	data := aNewResponse.
	self inform: 'inside handleResponse.'.
	(data at: 'kind') = 'HighlightingInfo'
		ifTrue: [ self highlight: (data at: 'info' at: 'payload') ]
]

{ #category : #accessing }
AgdaFile >> highlight: anArray [
	savedText unstyle.
	self inform: 'Inside highlight.'.
	anArray
		do: [ :info | 
			| text range type atoms comp missing |
			missing := true.
			range := info at: 'range'.
			text := savedText from: (range at: 1) to: ((range at: 2) min: savedText size).
			atoms := info at: 'atoms'.
			atoms size > 0
				ifTrue: [ type := atoms at: 1.
					comp := [ :co | atoms size > 1 ifFalse: [ false ] ifTrue: [ (atoms at: 2) = co ] ].

					type = 'markup'
						ifTrue: [ text foreground: Color red muchDarker.
							self inform: 'markup'.
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
					type = 'error'
						ifTrue: [ text background: Color yellow muchDarker.
							missing := false ].
					missing ifTrue: [ self inform: 'missing highlight: ' , type ] ] ].
	self inform: 'Inside highlight.'
]

{ #category : #accessing }
AgdaFile >> load [
	^ self query: (AgdaQuery new load: path)
]

{ #category : #accessing }
AgdaFile >> query: aQuery [
	^ agda query: aQuery for: self
]

{ #category : #accessing }
AgdaFile >> save: newContents [
	(file fullName , '.backup') asFileReference ensureDelete.
	file copyTo: (file fullName , '.backup') asFileReference.
	^ file
		ensureDelete;
		writeStreamDo: [ :s | s nextPutAll: newContents ]
]

{ #category : #accessing }
AgdaFile >> savedText [
^ savedText.
]

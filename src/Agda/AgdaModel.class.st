Class {
	#name : #AgdaModel,
	#superclass : #Object,
	#instVars : [
		'agda',
		'path',
		'file',
		'ropedText',
		'runningInfo',
		'displayInfo',
		'agdaMsgs'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaModel class >> agda: anAgda path: aPath [
^ self new agda: anAgda path: aPath.
]

{ #category : #accessing }
AgdaModel >> agda: anAgda path: aPath [
	agda := anAgda.
	path := aPath.
	file := path asFileReference.
	ropedText := BlRunRopedText file: file.
	ropedText fontName: 'mononoki'.
	runningInfo := 'Idle.' asRopedText.
	displayInfo := 'Welcome to Agda.' asRopedText.
	agdaMsgs := LinkedList new.
]

{ #category : #accessing }
AgdaModel >> agdaMsgs [
^ agdaMsgs
]

{ #category : #accessing }
AgdaModel >> clearHighlighting [
ropedText unstyle.
]

{ #category : #accessing }
AgdaModel >> clearRunningInfo [
	runningInfo size = 0 ifFalse: [ runningInfo := runningInfo deleteAll ]
]

{ #category : #accessing }
AgdaModel >> displayInfo [
^ displayInfo
]

{ #category : #accessing }
AgdaModel >> displayInfo: info [
	(info at: 'kind') = 'AllGoalsWarnings'
		ifTrue: [ (info at: 'visibleGoals') do: [ :goal | self displayVisibleGoal ].
			(info at: 'invisibleGoals') do: [ :goal | self displayInvisibleGoal ].
			(info at: 'warnings') do: [ :goal | self displayWarnings ] ]
]

{ #category : #accessing }
AgdaModel >> displayInvisibleGoal [
]

{ #category : #accessing }
AgdaModel >> displayVisibleGoal [
]

{ #category : #accessing }
AgdaModel >> displayWarnings [
]

{ #category : #accessing }
AgdaModel >> gtJSONDataFor: aView context: aContext [
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
		object: [ agdaMsgs ];
		view: #gtTreeFor:context:.
]

{ #category : #accessing }
AgdaModel >> handleResponse: aNewResponse [
	| data |
	data := aNewResponse.
	agdaMsgs add: data.
	(data at: 'kind') = 'HighlightingInfo'
		ifTrue: [ self highlight: (data at: 'info' at: 'payload') ].
	(data at: 'kind') = 'ClearRunningInfo' ifTrue: [ self clearRunningInfo ].
	(data at: 'kind') = 'ClearHighlighting'
		ifTrue: [ self clearHighlighting ].
	(data at: 'kind') = 'RunningInfo' ifTrue: [ self moreRunningInfo: (data at: 'message'). ].
	(data at: 'kind') = 'DisplayInfo'
		ifTrue: [ self displayInfo: (data at: 'info') ]
]

{ #category : #accessing }
AgdaModel >> highlight: anArray [
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
										action: [ :aTBrTextEditorTextualPiece :aTarget :aTextEditor :anEvent | 
											anEvent currentTarget phlow
												spawnObject: (AgdaUI for: (AgdaModel agda: agda path: Path / (definitionSite at: 'filepath'))) ]) ] ] ]
]

{ #category : #accessing }
AgdaModel >> load [
	agdaMsgs removeAll.
	^ self query: (AgdaQuery new load: path)
]

{ #category : #accessing }
AgdaModel >> moreRunningInfo: aMessage [
runningInfo := runningInfo , (aMessage asRopedText)
]

{ #category : #accessing }
AgdaModel >> query: aQuery [
	^ agda query: aQuery
]

{ #category : #accessing }
AgdaModel >> ropedText [
^ ropedText.
]

{ #category : #accessing }
AgdaModel >> runningInfo [
^ runningInfo
]

{ #category : #accessing }
AgdaModel >> save: newContents [
	| string |
	string := newContents asString.
	(file fullName , '.backup') asFileReference ensureDelete.
	file copyTo: (file fullName , '.backup') asFileReference.
	file
		ensureDelete;
		writeStreamDo: [ :s | s nextPutAll: string ].
]

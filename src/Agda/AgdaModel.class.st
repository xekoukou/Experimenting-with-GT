Class {
	#name : #AgdaModel,
	#superclass : #Object,
	#instVars : [
		'agda',
		'runningInfo',
		'displayInfo',
		'agdaMsgs',
		'agdaFiles',
		'fpath',
		'openedCodeLinks',
		'announcer'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaModel >> agdaFiles [
	^ agdaFiles
]

{ #category : #accessing }
AgdaModel >> agdaMsgs [
^ agdaMsgs
]

{ #category : #accessing }
AgdaModel >> announcer [
	^ announcer
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
		ifTrue: [ (agdaFiles at: fpath)
				highlight: (data at: 'info' at: 'payload')
				withModel: self ].
	(data at: 'kind') = 'ClearRunningInfo' ifTrue: [ self clearRunningInfo ].
	(data at: 'kind') = 'ClearHighlighting'
		ifTrue: [ (agdaFiles at: fpath) clearHighlighting ].
	(data at: 'kind') = 'RunningInfo'
		ifTrue: [ self moreRunningInfo: (data at: 'message') ].
	(data at: 'kind') = 'DisplayInfo'
		ifTrue: [ self displayInfo: (data at: 'info') ]
]

{ #category : #accessing }
AgdaModel >> initialize [
	super initialize.
	agda := AgdaMode new.
	agdaFiles := Dictionary new.
	openedCodeLinks := Set new.
	runningInfo := 'Idle.' asRopedText.
	displayInfo := 'Welcome to Agda.' asRopedText.
	agdaMsgs := LinkedList new.
	announcer := Announcer new.
]

{ #category : #accessing }
AgdaModel >> load [
	agdaMsgs removeAll.
	^ self query: (AgdaQuery new load: fpath)
]

{ #category : #accessing }
AgdaModel >> load: aPath [
	fpath := aPath.
	agdaMsgs removeAll.
	^ self query: (AgdaQuery new load: fpath)
]

{ #category : #accessing }
AgdaModel >> moreRunningInfo: aMessage [
runningInfo := runningInfo , (aMessage asRopedText)
]

{ #category : #accessing }
AgdaModel >> newFile: aPath [
	agdaFiles at: aPath ifAbsentPut: [ AgdaFile path: aPath ].
	^ agdaFiles at: aPath
]

{ #category : #accessing }
AgdaModel >> openLink: title path: aPathString position: aPosition [
	| agdaFile |
	agdaFile := self newFile: (Path from: aPathString).
	openedCodeLinks
		add: {title.
				aPathString.
				aPosition}.
	announcer announce: UpdateOpenLinks new
]

{ #category : #accessing }
AgdaModel >> openLinks [
	^ openedCodeLinks
]

{ #category : #accessing }
AgdaModel >> query: aQuery [
	^ agda query: aQuery
]

{ #category : #accessing }
AgdaModel >> runningInfo [
^ runningInfo
]

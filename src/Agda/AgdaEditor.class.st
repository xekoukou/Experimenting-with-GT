Class {
	#name : #AgdaEditor,
	#superclass : #BlElement,
	#instVars : [
		'agdaF',
		'label',
		'editor',
		'savedText'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> for: anAgdaFile [
    
	^ self new for:anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> editor [
	editor := BrEditor new.
	editor
		aptitude: BrEditorAptitude new;
		text: savedText;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self editorShortCuts.
	^ editor
]

{ #category : #accessing }
AgdaEditor >> editorShortCuts [
	| load |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ | future |
				future := agdaF load.
				self recurseFuture: future ].
	editor addShortcut: load
]

{ #category : #accessing }
AgdaEditor >> for: anAgdaFile [
	super initialize.
	agdaF := anAgdaFile.
	savedText := agdaF savedText.
	self editor.
	self addChild: editor as: 'editor'.
	self
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
]

{ #category : #accessing }
AgdaEditor >> recurseFuture: aFuture [
	aFuture
		ifNotNil: [ | nextFuture |
			editor
				withAsyncFutureDo: [ :anElementFuture | 
					anElementFuture
						whenSuccess: [ :ceditor :resp | 
							resp
								ifNotNil: [ nextFuture := resp at: 2.
									agdaF handleResponse: (resp at: 1).
									self recurseFuture: nextFuture ]
								ifNil: [ editor beEditable ] ];
						whenError: [ :ceditor :anError | ceditor text: anError printString ];
						whenPending: [ :ceditor | ceditor beReadOnlyWithSelection ].
					anElementFuture future: aFuture ] ]
]

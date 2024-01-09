Class {
	#name : #AgdaEditor,
	#superclass : #BlElement,
	#instVars : [
		'agdaF',
		'editor'
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
		text: agdaF savedText;
		background: Color white;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].

	^ editor
]

{ #category : #accessing }
AgdaEditor >> editorShortCuts [
	| load |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ self
					withAsyncFutureDo: [ :aFutureElement | 
						aFutureElement
							whenSuccess: [ :currentEditor | currentEditor text: agdaF savedText ].
						aFutureElement future: agdaF load ] ].
	editor addShortcut: load
]

{ #category : #accessing }
AgdaEditor >> for: anAgdaFile [
	super initialize.
	agdaF := anAgdaFile.
	self editor.
	self addChild: editor .
	self
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self handleEvents.
]

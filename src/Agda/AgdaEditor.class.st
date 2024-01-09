Class {
	#name : #AgdaEditor,
	#superclass : #BlElement,
	#instVars : [
		'agdaF',
		'label'
	],
	#category : #'Agda-agda'
}

{ #category : #accessing }
AgdaEditor class >> for: anAgdaFile [
    
	^ self new for:anAgdaFile
]

{ #category : #accessing }
AgdaEditor >> editor [
	| editor |
	editor := BrEditor new.
	editor
		aptitude: BrEditorAptitude new;
		background: Color white;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self editorShortCuts: editor.
	^ editor
]

{ #category : #accessing }
AgdaEditor >> editorShortCuts [
	| load |
	self inform: 'out1'.
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ self inform: 'action'.
				label
					withAsyncFutureDo: [ :anElementFuture | 
						anElementFuture
							whenSuccess: [ :currentButton | currentButton text: 'Success' ];
							whenError: [ :currentButton :anError | currentButton text: 'Error: ' , anError printString ];
							whenPending: [ :currentButton | currentButton text: ('Pending...' asRopedText foreground: Color gray) ].
						anElementFuture
							future: [ self inform: 'Starting wait'.
								Time now minutes odd ifTrue: [ self error: 'You got unlucky' ].
								5 seconds wait.
								self inform: 'Completed wait' ] asAsyncFuture ] ].
								self inform: 'out2'.
	label addShortcut: load
]

{ #category : #accessing }
AgdaEditor >> editorShortCuts: anElement [
	| load |
	load := BlShortcutWithAction new
			combination: BlKeyCombination primaryL;
			action: [ self
					future: [ 0.5 seconds wait.
							'Alice' ]
						initialValue: 'placeholder';
					stencil: [ BrLabel new
			aptitude: BrGlamorousLabelAptitude ];
					dataBinder: [ :anEditor :aDataSnapshot | 
						aDataSnapshot
							ifSuccess: [ :aName | 
								self inform: 'success'.
								anEditor text: aName ]
							ifError: [ :anError | 
								self inform: 'pending'.
								anEditor text: (anError description asRopedText foreground: Color red) ]
							ifPending: [ :anInitialValue | 
								self inform: 'pending'.
								anEditor text: anInitialValue ] ].].
	anElement addShortcut: load
]

{ #category : #accessing }
AgdaEditor >> for: anAgdaFile [
	super initialize.
	agdaF := anAgdaFile.
	self label.
	self addChild: label as: 'label'.
	self
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ].
	self editorShortCuts
]

{ #category : #accessing }
AgdaEditor >> label [
	label := BrLabel new aptitude: BrGlamorousLabelAptitude.
	label text: 'hi'.
]

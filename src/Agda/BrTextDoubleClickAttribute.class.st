Class {
	#name : #BrTextDoubleClickAttribute,
	#superclass : #BrTextEventHandlerAttribute,
	#instVars : [
		'action'
	],
	#category : #'Agda-Attributes'
}

{ #category : #accessing }
BrTextDoubleClickAttribute >> action [
	^ action
]

{ #category : #accessing }
BrTextDoubleClickAttribute >> action: aValuable [
	self 
		assert: [ aValuable notNil ] 
		description: [ 'Action should be initialized' ].

	action := aValuable
]

{ #category : #events }
BrTextDoubleClickAttribute >> handleEvent: anEvent in: aTextEditor on: aTBrTextEditorTextualPiece [
	self performAction: anEvent in: aTextEditor on: aTBrTextEditorTextualPiece
]

{ #category : #initialization }
BrTextDoubleClickAttribute >> initialize [
	super initialize.
	
	action := [ :aTBrTextEditorTextualPiece :aTextElement :aTextEditor :anEvent | ]
]

{ #category : #private }
BrTextDoubleClickAttribute >> performAction: anEvent in: aTextEditor on: aTBrTextEditorTextualPiece [
	self action gtValueWithArgs: {
		aTBrTextEditorTextualPiece. "first we pass text"
		anEvent currentTarget. "then the text piece (word) element"
		aTextEditor. "then the whole text editor"
		anEvent "the event itself"
	}
]

{ #category : #events }
BrTextDoubleClickAttribute >> wantsEvent: anEvent in: aTextEditor [
	^ anEvent isKindOf: BlDoubleClickEvent
]

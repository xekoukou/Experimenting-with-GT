Class {
	#name : #NewResponse,
	#superclass : #Announcement,
	#instVars : [
		'value'
	],
	#category : #'Agda-agda'
}

{ #category : #'as yet unclassified' }
NewResponse class >> with: aValue [.
self new with: aValue.
]

{ #category : #accessing }
NewResponse >> value [
^ value.
]

{ #category : #accessing }
NewResponse >> with: aValue [
value := aValue
]

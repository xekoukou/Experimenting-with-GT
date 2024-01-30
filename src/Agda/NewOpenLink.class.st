Class {
	#name : #NewOpenLink,
	#superclass : #Announcement,
	#instVars : [
		'link'
	],
	#category : #'Agda-Announcement'
}

{ #category : #accessing }
NewOpenLink class >> link: anOpenLink [
	^ self new link: anOpenLink
]

{ #category : #accessing }
NewOpenLink >> link [
	^ link
]

{ #category : #accessing }
NewOpenLink >> link: anOpenLink [
	link := anOpenLink
]

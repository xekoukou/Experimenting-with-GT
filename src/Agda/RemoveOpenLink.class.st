Class {
	#name : #RemoveOpenLink,
	#superclass : #Announcement,
	#instVars : [
		'link'
	],
	#category : #'Agda-Announcement'
}

{ #category : #accessing }
RemoveOpenLink class >> link: anOpenLink [
	^ self new link: anOpenLink
]

{ #category : #accessing }
RemoveOpenLink >> link [
	^ link
]

{ #category : #accessing }
RemoveOpenLink >> link: anOpenLink [
	link := anOpenLink
]

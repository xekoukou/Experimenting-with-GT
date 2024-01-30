Class {
	#name : #BrGlamorousAccordionWithBorderAptitude2,
	#superclass : #BrGlamorousAccordionAptitude2,
	#instVars : [
		'headerTopBorder',
		'contentBottomBorder',
		'rightBorder'
	],
	#category : #'Agda-Accordion'
}

{ #category : #accessing }
BrGlamorousAccordionWithBorderAptitude2 >> borderWidth [
	^ 3
]

{ #category : #initialization }
BrGlamorousAccordionWithBorderAptitude2 >> initialize [
	super initialize.

	contentBottomBorder := self newContentBottomBorder.
	rightBorder := self newRightBorder.

	self
		addAll: {BrStyleCommonAptitude new
					default: [ :aStyler | 
						{contentBottomBorder.
							rightBorder} do: #removeFromParent ];
					expanded: [ :aStyler | 
						contentContainer addChild: contentBottomBorder.
						wrapper addChild: rightBorder ]}
]

{ #category : #'instance creation' }
BrGlamorousAccordionWithBorderAptitude2 >> newContentBottomBorder [
	<return: #BlElement>

	^ BlElement new
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c ignored vertical alignBottom.
			c vertical fitContent.
			c horizontal matchParent.
			c padding: (BlInsets left: self headerBarWidth) ];
		addChild: (self newBar
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: self borderWidth ])
]

{ #category : #'instance creation' }
BrGlamorousAccordionWithBorderAptitude2 >> newHeaderTopBorder [
	<return: #BlElement>

	^ BlElement new
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c vertical fitContent.
			c horizontal matchParent.
			c padding: (BlInsets left: self headerBarWidth) ];
		addChild: (self newBar
			constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical exact: self borderWidth ])
]

{ #category : #'instance creation' }
BrGlamorousAccordionWithBorderAptitude2 >> newRightBorder [
	<return: #BlElement>

	^ BlElement new
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c ignored horizontal alignRight.
			c vertical matchParent.
			c horizontal fitContent.
			c padding: (BlInsets top: self borderWidth bottom: self borderWidth) ];
		addChild: (self newBar
			constraintsDo: [ :c |
				c vertical matchParent.
				c horizontal exact: self borderWidth ])
]

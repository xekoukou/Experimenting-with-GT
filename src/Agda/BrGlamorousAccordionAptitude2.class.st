Class {
	#name : #BrGlamorousAccordionAptitude2,
	#superclass : #BrAccordionAptitude2,
	#instVars : [
		'contentContainer',
		'bar',
		'wrapper',
		'headerContainer',
		'headerBar',
		'contentBar'
	],
	#category : #'Agda-Accordion'
}

{ #category : #accessing }
BrGlamorousAccordionAptitude2 >> contentBarWidth [
	^ 10
]

{ #category : #accessing }
BrGlamorousAccordionAptitude2 >> headerBar [
	<return: #BlElement>

	^ headerBar
]

{ #category : #accessing }
BrGlamorousAccordionAptitude2 >> headerBarWidth [
	^ 10
]

{ #category : #initialization }
BrGlamorousAccordionAptitude2 >> initialize [
	super initialize.
	wrapper := self newWrapper.
	headerBar := self newHeaderBar.
	contentBar := self newContentBar.
	headerContainer := self newHeaderContainer.
	headerContainer addChild: headerBar.
	contentContainer := self newContentContainer.
	contentContainer addChild: contentBar.
	wrapper addChild: headerContainer as: #header.
	wrapper addChild: contentContainer as: #content.
	self
		addChangeProperty: #(widget layout)
		with: [ BlLinearLayout horizontal ].
	self addChangeAddChildAs: #(content wrapper) with: [ wrapper ].
	self
		add:
			(BrStyleCommonAptitude new
				@ headerBar;
				default: [ :aStyle | aStyle background: (Color gray alpha: 0.4) ];
				focused:
						[ :aStyle | aStyle background: (self theme default primaryBorderColor) ]).
	self
		add:
			(BrStyleCommonAptitude new
				@ contentBar;
				default: [ :aStyle | 
					aStyle
						gone;
						background: (Color gray alpha: 0.2) ];
				focused:
						[ :aStyle | aStyle background: (self theme default primaryBorderColor) ];
				expanded: [ :aStyle | aStyle visible ]).
	self
		add:
			(BrLayoutResizerAptitude new
				inherit: wrapper;
				inherit: contentContainer).
	self
		add:
			(BrLayoutResizerAptitude new
				inherit: [ :aBlock | aBlock value: (contentElement ifNil: [ BlElement new ]) ])
]

{ #category : #'instance creation' }
BrGlamorousAccordionAptitude2 >> newBar [
	<return: #BlElement>

	^ BlElement new
		background: (Color gray alpha: 0.2);
		constraintsDo: [ :c |
			c horizontal exact: 10.
			c vertical matchParent ]
]

{ #category : #'instance creation' }
BrGlamorousAccordionAptitude2 >> newContentBar [
	<return: #BlElement>

	^ self newBar
		width: self contentBarWidth;
		margin: (BlInsets left: (self headerBarWidth - self contentBarWidth))
]

{ #category : #'instance creation' }
BrGlamorousAccordionAptitude2 >> newContentContainer [
	<return: #BlElement>
	^ BlElement new
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical exact: 100 ];
		addAptitude: BrGlamorousWithVerticalResizerAptitude new
]

{ #category : #'instance creation' }
BrGlamorousAccordionAptitude2 >> newHeaderBar [
	<return: #BlElement>

	^ self newBar
		width: self headerBarWidth
]

{ #category : #'instance creation' }
BrGlamorousAccordionAptitude2 >> newHeaderContainer [
	<return: #BlElement>
	^ BlElement new
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ]
]

{ #category : #'instance creation' }
BrGlamorousAccordionAptitude2 >> newWrapper [
	<return: #BlElement>
	^ BlElement new
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c | 
			c horizontal fitContent.
			c vertical fitContent ]
]

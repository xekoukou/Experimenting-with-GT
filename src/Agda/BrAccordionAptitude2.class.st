Class {
	#name : #BrAccordionAptitude2,
	#superclass : #BrAptitude,
	#instVars : [
		'contentElement',
		'contentStencil',
		'headerStencil',
		'headerElement'
	],
	#category : #'Agda-Accordion - Look'
}

{ #category : #hooks }
BrAccordionAptitude2 >> accordionCollapsed [
	contentElement ifNotNil: [ contentElement removeFromParent ]
]

{ #category : #hooks }
BrAccordionAptitude2 >> accordionExpanded [

	contentElement ifNil: [ contentElement := self contentStencil asElement ].
	contentElement removeFromParent.
	self widgetAccordionContent addChild: contentElement
]

{ #category : #accessing }
BrAccordionAptitude2 >> contentStencil [
	 ^ contentStencil
]

{ #category : #accessing }
BrAccordionAptitude2 >> contentStencil: aBrStencil [

	self
		assert: [ aBrStencil isNotNil ]
		description: [ 'Stencil must not be nil' ].

	contentStencil := aBrStencil asStencil.

	contentElement ifNotNil: [ contentElement removeFromParent ].
	contentElement := nil.
	self request: BrExpansionStateRequest new
]

{ #category : #accessing }
BrAccordionAptitude2 >> headerStencil [
	 ^ headerStencil
]

{ #category : #accessing }
BrAccordionAptitude2 >> headerStencil: aBrStencil [

	self
		assert: [ aBrStencil isNotNil ]
		description: [ 'Stencil must not be nil' ].

	headerStencil := aBrStencil asStencil.

	headerElement ifNotNil: [ headerElement removeFromParent ].
	headerElement := headerStencil asElement.
	self widgetAccordionHeader addChild: headerElement
]

{ #category : #initialization }
BrAccordionAptitude2 >> initialize [
	super initialize.
	
	contentStencil := BlElement new.
	headerStencil := BlElement new
]

{ #category : #initialization }
BrAccordionAptitude2 >> initializeListeners [
	super initializeListeners.

	self when: BrExpandedEvent do: [ :anEvent | self accordionExpanded ].
	self when: BrCollapsedEvent do: [ :anEvent | self accordionCollapsed ].
	self when: BrAccordionContentStencilChanged do: [ :anEvent | self contentStencil: anEvent stencil ].
	self when: BrAccordionHeaderStencilChanged do: [ :anEvent | self headerStencil: anEvent stencil ]
]

{ #category : #initialization }
BrAccordionAptitude2 >> initializeRequests [
	super initializeRequests.
	
	self request: BrAccordionContentStencilRequest new.
	self request: BrAccordionHeaderStencilRequest new.
	self request: BrExpansionStateRequest new
]

{ #category : #accessing }
BrAccordionAptitude2 >> widgetAccordionContent [
	"Return widget's content container element"
	<return: #BlElement>

	self
		assert: [ widget isNotNil ]
		description: [ 'I must be attached to the widget first' ].

	"if widget does not have explicit #header container, we treat widget as a container itself"
	^ widget
		childNamed: #content
		ifFound: [ :anElement | anElement ]
		ifNone: [ widget ]
]

{ #category : #accessing }
BrAccordionAptitude2 >> widgetAccordionHeader [
	"Return widget's header container element"
	<return: #BlElement>

	self
		assert: [ widget isNotNil ]
		description: [ 'I must be attached to the widget first' ].

	"if widget does not have explicit #header container, we treat widget as a container itself"
	^ widget
		childNamed: #header
		ifFound: [ :anElement | anElement ]
		ifNone: [ widget ]
]

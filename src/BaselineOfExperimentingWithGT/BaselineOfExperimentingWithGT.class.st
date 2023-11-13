Class {
	#name : #BaselineOfExperimentingWithGT,
	#superclass : #BaselineOf,
	#category : #BaselineOfExperimentingWithGT
}

{ #category : #loading }
BaselineOfExperimentingWithGT class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'Experimenting-with-GT' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : #baseline }
BaselineOfExperimentingWithGT >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'ExperimentingWithGT'
		]
]

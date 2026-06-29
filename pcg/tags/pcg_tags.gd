extends GameplayTagDefinition
class_name PCGTags

class OutputType:
	const Points = "points"
	const Primitives = "primitives"
	const Actor = "actor"

class Ops:
	class Generate:
		const SampleSpline = "sample_spline"
		const ScatterPoints = "scatter_points"
		
class Attributes:
	const Density = "density"
	const SplineProgress = "spline_progress"
	const Normal = "normal"
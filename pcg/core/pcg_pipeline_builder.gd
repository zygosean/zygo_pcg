extends RefCounted
class_name PCGPipelineBuilder

var _pipeline := PCGPipeline.new()

func add(op : PCGOp) -> PCGPipelineBuilder:
	_pipeline.opps.append(op)
	return self
	
func done() -> PCGPipeline:
	return _pipeline
@tool
extends Resource
class_name PCGContext

var pcg_seed: int = 0
var bounds : AABB = AABB()
var user_parameters : Dictionary[String, Variant]
var splines : Array[Path3D] = []
var physics_space : PhysicsDirectSpaceState3D = null
var collision_meshes : Array[CollisionShape3D] = []
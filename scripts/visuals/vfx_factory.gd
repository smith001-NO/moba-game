extends RefCounted
class_name VFXFactory

static func spawn_ring(parent: Node, pos: Vector3, color: Color, radius: float = 1.0, duration: float = 0.35) -> Node3D:
    var root: Node3D = Node3D.new()
    root.name = "VFXRing"
    root.global_position = pos
    parent.add_child(root)
    var mesh: CylinderMesh = CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = 0.04
    mesh.radial_segments = 48
    var mat: StandardMaterial3D = StandardMaterial3D.new()
    mat.albedo_color = Color(color.r, color.g, color.b, 0.55)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 1.2
    var ring: MeshInstance3D = MeshInstance3D.new()
    ring.mesh = mesh
    ring.set_surface_override_material(0, mat)
    root.add_child(ring)
    var light: OmniLight3D = OmniLight3D.new()
    light.light_color = color
    light.light_energy = 1.4
    light.omni_range = radius * 3.0
    root.add_child(light)
    var tween: Tween = root.create_tween()
    tween.set_parallel(true)
    tween.tween_property(root, "scale", Vector3(1.7, 1.0, 1.7), duration)
    tween.tween_property(light, "light_energy", 0.0, duration)
    tween.tween_property(mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), duration)
    tween.set_parallel(false)
    tween.tween_callback(root.queue_free)
    return root

static func spawn_burst(parent: Node, pos: Vector3, color: Color, count: int = 8, duration: float = 0.36) -> void:
    var root: Node3D = Node3D.new()
    root.name = "VFXBurst"
    root.global_position = pos
    parent.add_child(root)
    for i in range(count):
        var mesh: BoxMesh = BoxMesh.new()
        mesh.size = Vector3(0.08, 0.08, 0.72)
        var mat: StandardMaterial3D = StandardMaterial3D.new()
        mat.albedo_color = color
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.4
        var piece: MeshInstance3D = MeshInstance3D.new()
        piece.mesh = mesh
        piece.set_surface_override_material(0, mat)
        piece.rotation_degrees = Vector3(0.0, float(i) * (360.0 / float(count)), 0.0)
        root.add_child(piece)
        var dir: Vector3 = Vector3(cos(float(i) * TAU / float(count)), 0.25, sin(float(i) * TAU / float(count))).normalized()
        var tween: Tween = piece.create_tween()
        tween.set_parallel(true)
        tween.tween_property(piece, "position", dir * 1.6, duration)
        tween.tween_property(piece, "scale", Vector3(0.05, 0.05, 0.05), duration)
    var light: OmniLight3D = OmniLight3D.new()
    light.light_color = color
    light.light_energy = 2.0
    light.omni_range = 4.0
    root.add_child(light)
    var done: Tween = root.create_tween()
    done.tween_property(light, "light_energy", 0.0, duration)
    done.tween_callback(root.queue_free)

static func spawn_afterimage(parent: Node, pos: Vector3, dir: Vector3, color: Color, duration: float = 0.24) -> void:
    var root: Node3D = Node3D.new()
    root.name = "DashAfterimage"
    root.global_position = pos + Vector3.UP * 0.8
    parent.add_child(root)
    var mesh: BoxMesh = BoxMesh.new()
    mesh.size = Vector3(0.22, 1.8, 0.06)
    var mat: StandardMaterial3D = StandardMaterial3D.new()
    mat.albedo_color = Color(color.r, color.g, color.b, 0.42)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 0.9
    var blade: MeshInstance3D = MeshInstance3D.new()
    blade.mesh = mesh
    blade.set_surface_override_material(0, mat)
    root.add_child(blade)
    if dir.length() > 0.01:
        root.look_at(root.global_position + dir.normalized(), Vector3.UP, true)
    var tween: Tween = root.create_tween()
    tween.set_parallel(true)
    tween.tween_property(root, "scale", Vector3(1.8, 1.0, 1.0), duration)
    tween.tween_property(mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), duration)
    tween.set_parallel(false)
    tween.tween_callback(root.queue_free)

static func spawn_projectile_trail(parent: Node, pos: Vector3, color: Color, duration: float = 0.22) -> void:
    var mesh: SphereMesh = SphereMesh.new()
    mesh.radius = 0.18
    mesh.height = 0.36
    mesh.radial_segments = 12
    mesh.rings = 6
    var mat: StandardMaterial3D = StandardMaterial3D.new()
    mat.albedo_color = Color(color.r, color.g, color.b, 0.42)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 1.0
    var dot: MeshInstance3D = MeshInstance3D.new()
    dot.name = "ProjectileTrail"
    dot.mesh = mesh
    dot.global_position = pos
    dot.set_surface_override_material(0, mat)
    parent.add_child(dot)
    var tween: Tween = dot.create_tween()
    tween.set_parallel(true)
    tween.tween_property(dot, "scale", Vector3(0.12, 0.12, 0.12), duration)
    tween.tween_property(mat, "albedo_color", Color(color.r, color.g, color.b, 0.0), duration)
    tween.set_parallel(false)
    tween.tween_callback(dot.queue_free)


static func spawn_floating_text(parent: Node, pos: Vector3, text: String, color: Color = Color(1, 1, 1, 1), duration: float = 0.75) -> void:
    if parent == null:
        return
    var label := Label3D.new()
    label.name = "FloatingCombatText"
    label.text = text
    label.font_size = 36
    label.modulate = color
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.global_position = pos
    parent.add_child(label)
    var tween := label.create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "global_position", pos + Vector3.UP * 1.25, duration)
    tween.tween_property(label, "modulate", Color(color.r, color.g, color.b, 0.0), duration)
    tween.set_parallel(false)
    tween.tween_callback(label.queue_free)

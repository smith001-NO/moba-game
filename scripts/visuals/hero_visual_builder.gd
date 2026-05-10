extends RefCounted
class_name HeroVisualBuilder

const TOON_SHADER: Shader = preload("res://shaders/toon_shader.gdshader")

static func build(hero: Node3D, theme: String) -> Node3D:
    var root := Node3D.new()
    root.name = "HeroVisuals"
    root.scale = Vector3(1.22, 1.22, 1.22)
    hero.add_child(root)
    if theme == "crimson":
        _build_crimson(root)
    else:
        _build_azure(root)
    return root

static func _build_azure(root: Node3D) -> void:
    var skin := _toon(Color(0.92, 0.72, 0.56), Color(0.46, 0.28, 0.22), Color(0.95, 0.80, 0.64))
    var hair := _toon(Color(0.05, 0.08, 0.16), Color(0.0, 0.02, 0.05), Color(0.20, 0.45, 1.0))
    var cloth := _toon(Color(0.08, 0.22, 0.72), Color(0.02, 0.06, 0.22), Color(0.26, 0.62, 1.0))
    var cloth_light := _toon(Color(0.18, 0.42, 1.0), Color(0.04, 0.10, 0.32), Color(0.5, 0.86, 1.0))
    var metal := _metal(Color(0.70, 0.76, 0.86), Color(0.22, 0.25, 0.33))
    var dark := _toon(Color(0.04, 0.06, 0.12), Color(0.0, 0.0, 0.02), Color(0.20, 0.34, 0.78))
    var glow := _glow(Color(0.24, 0.75, 1.0), 1.35)

    _part(root, "BodySuit", _capsule(0.25, 1.55), Vector3(0, 0.22, 0), Vector3.ZERO, dark)
    _part(root, "ChestPlate", _box(Vector3(0.62, 0.44, 0.20)), Vector3(0, 0.48, -0.09), Vector3(-5, 0, 0), metal)
    _part(root, "BlueChestInset", _box(Vector3(0.42, 0.34, 0.06)), Vector3(0, 0.49, -0.205), Vector3(-5, 0, 0), cloth)
    _part(root, "CrystalEmblem", _sphere(0.105), Vector3(0, 0.55, -0.25), Vector3(0, 0, 0), glow, Vector3(0.8, 1.35, 0.35))
    _part(root, "WaistArmor", _box(Vector3(0.52, 0.18, 0.22)), Vector3(0, -0.17, -0.02), Vector3.ZERO, metal)
    _part(root, "FrontTabard", _box(Vector3(0.28, 0.82, 0.035)), Vector3(0, -0.62, -0.18), Vector3(8, 0, 0), cloth)
    _part(root, "LeftHipPanel", _box(Vector3(0.16, 0.72, 0.035)), Vector3(-0.28, -0.53, -0.05), Vector3(6, 0, -8), cloth_light)
    _part(root, "RightHipPanel", _box(Vector3(0.16, 0.72, 0.035)), Vector3(0.28, -0.53, -0.05), Vector3(6, 0, 8), cloth_light)

    _part(root, "Head", _sphere(0.22), Vector3(0, 1.42, 0), Vector3.ZERO, skin, Vector3(0.88, 1.05, 0.86))
    _part(root, "HairCap", _sphere(0.245), Vector3(0, 1.51, 0.035), Vector3.ZERO, hair, Vector3(1.0, 0.8, 0.95))
    _part(root, "HairBackLayer", _box(Vector3(0.42, 0.34, 0.09)), Vector3(0, 1.38, 0.18), Vector3(18, 0, 0), hair)
    for i in range(6):
        var x := -0.20 + 0.08 * float(i)
        var rot := -26.0 + 10.0 * float(i)
        _part(root, "AzureHairSpike%d" % i, _box(Vector3(0.055, 0.26, 0.045)), Vector3(x, 1.48, -0.18), Vector3(18, 0, rot), hair)
    _part(root, "BlueHairStreak", _box(Vector3(0.035, 0.28, 0.035)), Vector3(0.11, 1.49, -0.19), Vector3(16, 0, 14), cloth_light)

    _limb(root, "LeftUpperArm", Vector3(-0.40, 0.41, 0), 0.12, 0.62, Vector3(0, 0, 14), dark)
    _limb(root, "RightUpperArm", Vector3(0.40, 0.41, 0), 0.12, 0.62, Vector3(0, 0, -14), dark)
    _limb(root, "LeftForearm", Vector3(-0.52, 0.03, -0.01), 0.105, 0.58, Vector3(0, 0, 9), metal)
    _limb(root, "RightForearm", Vector3(0.52, 0.03, -0.01), 0.105, 0.58, Vector3(0, 0, -9), metal)
    _part(root, "LeftHand", _sphere(0.09), Vector3(-0.55, -0.31, -0.01), Vector3.ZERO, skin, Vector3(0.8, 1.0, 0.75))
    _part(root, "RightHand", _sphere(0.09), Vector3(0.55, -0.31, -0.01), Vector3.ZERO, skin, Vector3(0.8, 1.0, 0.75))
    _part(root, "LargeAsymShoulder", _box(Vector3(0.46, 0.18, 0.36)), Vector3(-0.38, 0.85, -0.02), Vector3(0, 0, 18), metal)
    _part(root, "LargeShoulderBlade", _box(Vector3(0.54, 0.08, 0.26)), Vector3(-0.50, 0.93, -0.03), Vector3(0, 0, 28), metal)
    _part(root, "SmallShoulder", _box(Vector3(0.30, 0.14, 0.28)), Vector3(0.36, 0.80, -0.02), Vector3(0, 0, -14), metal)
    _part(root, "LeftBracerGem", _sphere(0.045), Vector3(-0.56, 0.07, -0.13), Vector3.ZERO, glow, Vector3(1, 1.4, 0.4))
    _part(root, "RightBracerGem", _sphere(0.045), Vector3(0.56, 0.07, -0.13), Vector3.ZERO, glow, Vector3(1, 1.4, 0.4))

    _limb(root, "LeftThigh", Vector3(-0.15, -0.72, 0), 0.13, 0.82, Vector3(0, 0, -2), dark)
    _limb(root, "RightThigh", Vector3(0.15, -0.72, 0), 0.13, 0.82, Vector3(0, 0, 2), dark)
    _limb(root, "LeftGreave", Vector3(-0.15, -1.28, -0.01), 0.115, 0.78, Vector3.ZERO, metal)
    _limb(root, "RightGreave", Vector3(0.15, -1.28, -0.01), 0.115, 0.78, Vector3.ZERO, metal)
    _part(root, "LeftBoot", _box(Vector3(0.20, 0.16, 0.34)), Vector3(-0.15, -1.72, -0.05), Vector3.ZERO, metal)
    _part(root, "RightBoot", _box(Vector3(0.20, 0.16, 0.34)), Vector3(0.15, -1.72, -0.05), Vector3.ZERO, metal)

    _part(root, "ScarfWrap", _torus_like_box(Vector3(0.54, 0.16, 0.18)), Vector3(0, 1.08, -0.04), Vector3(0, 0, 0), cloth_light)
    _part(root, "ScarfTailLong", _box(Vector3(0.14, 1.55, 0.06)), Vector3(-0.64, 0.52, 0.20), Vector3(0, 22, 65), cloth_light)
    _part(root, "ScarfTailThin", _box(Vector3(0.08, 1.35, 0.05)), Vector3(-0.95, 0.40, 0.08), Vector3(0, 28, 82), cloth)
    _part(root, "BackCloth", _box(Vector3(0.36, 1.18, 0.045)), Vector3(0, -0.10, 0.25), Vector3(-8, 0, 0), cloth)

    _part(root, "SwordGrip", _cylinder(0.035, 0.50), Vector3(0.62, -0.34, -0.13), Vector3(0, 0, -52), dark)
    _part(root, "SwordGuard", _box(Vector3(0.42, 0.075, 0.14)), Vector3(0.72, -0.14, -0.16), Vector3(0, 0, -52), metal)
    _part(root, "EnergyBladeCore", _box(Vector3(0.105, 1.70, 0.055)), Vector3(1.08, 0.37, -0.20), Vector3(0, 0, -52), glow)
    _part(root, "EnergyBladeEdge", _box(Vector3(0.04, 1.85, 0.04)), Vector3(1.14, 0.43, -0.205), Vector3(0, 0, -52), _glow(Color(0.74, 0.95, 1.0), 1.8))

static func _build_crimson(root: Node3D) -> void:
    var skin := _toon(Color(0.95, 0.72, 0.60), Color(0.48, 0.28, 0.22), Color(1.0, 0.82, 0.65))
    var hair := _toon(Color(0.70, 0.06, 0.09), Color(0.22, 0.0, 0.02), Color(1.0, 0.30, 0.20))
    var white := _toon(Color(0.94, 0.92, 0.88), Color(0.46, 0.41, 0.38), Color(1.0, 0.86, 0.58))
    var red := _toon(Color(0.74, 0.08, 0.10), Color(0.25, 0.02, 0.03), Color(1.0, 0.42, 0.22))
    var gold := _metal(Color(0.95, 0.70, 0.28), Color(0.38, 0.20, 0.06))
    var dark := _toon(Color(0.22, 0.04, 0.05), Color(0.04, 0.0, 0.0), Color(0.8, 0.18, 0.10))
    var glow := _glow(Color(1.0, 0.24, 0.12), 1.5)

    _part(root, "BodySuit", _capsule(0.23, 1.47), Vector3(0, 0.22, 0), Vector3.ZERO, white)
    _part(root, "RedCorset", _box(Vector3(0.56, 0.42, 0.18)), Vector3(0, 0.47, -0.10), Vector3(-5, 0, 0), red)
    _part(root, "GoldChestFiligree", _box(Vector3(0.38, 0.065, 0.035)), Vector3(0, 0.58, -0.205), Vector3(0, 0, 0), gold)
    _part(root, "EmberHeart", _sphere(0.095), Vector3(0, 0.50, -0.235), Vector3.ZERO, glow, Vector3(0.9, 1.25, 0.35))
    _part(root, "WaistGold", _box(Vector3(0.48, 0.16, 0.20)), Vector3(0, -0.15, -0.01), Vector3.ZERO, gold)
    _part(root, "FrontSkirt", _box(Vector3(0.30, 0.88, 0.035)), Vector3(0, -0.67, -0.19), Vector3(10, 0, 0), red)
    _part(root, "SideSkirtL", _box(Vector3(0.18, 0.78, 0.035)), Vector3(-0.29, -0.58, -0.04), Vector3(6, 0, -9), white)
    _part(root, "SideSkirtR", _box(Vector3(0.18, 0.78, 0.035)), Vector3(0.29, -0.58, -0.04), Vector3(6, 0, 9), white)
    _part(root, "SkirtTrim", _box(Vector3(0.36, 0.06, 0.04)), Vector3(0, -1.10, -0.21), Vector3(10, 0, 0), gold)

    _part(root, "Head", _sphere(0.215), Vector3(0, 1.41, 0), Vector3.ZERO, skin, Vector3(0.87, 1.04, 0.86))
    _part(root, "HairCap", _sphere(0.24), Vector3(0, 1.50, 0.04), Vector3.ZERO, hair, Vector3(1.0, 0.8, 0.95))
    _part(root, "HighPonyBase", _sphere(0.105), Vector3(0, 1.67, 0.16), Vector3.ZERO, gold, Vector3(1, 0.75, 1))
    _part(root, "PonytailMain", _capsule(0.075, 1.28), Vector3(0, 1.12, 0.40), Vector3(72, 0, 0), hair)
    _part(root, "PonytailFlow", _box(Vector3(0.13, 1.30, 0.055)), Vector3(-0.10, 0.95, 0.44), Vector3(76, -8, -8), hair)
    for i in range(5):
        var x := -0.14 + 0.07 * float(i)
        _part(root, "CrimsonBang%d" % i, _box(Vector3(0.05, 0.24, 0.04)), Vector3(x, 1.48, -0.16), Vector3(18, 0, -18 + i * 9), hair)
    _part(root, "CrownFront", _box(Vector3(0.34, 0.055, 0.07)), Vector3(0, 1.61, -0.08), Vector3(-10, 0, 0), gold)

    _limb(root, "LeftUpperArm", Vector3(-0.38, 0.42, 0), 0.105, 0.60, Vector3(0, 0, 12), red)
    _limb(root, "RightUpperArm", Vector3(0.38, 0.42, 0), 0.105, 0.60, Vector3(0, 0, -12), red)
    _limb(root, "LeftForearm", Vector3(-0.50, 0.03, -0.01), 0.095, 0.58, Vector3(0, 0, 9), gold)
    _limb(root, "RightForearm", Vector3(0.50, 0.03, -0.01), 0.095, 0.58, Vector3(0, 0, -9), gold)
    _part(root, "LeftShoulderWing", _box(Vector3(0.42, 0.14, 0.30)), Vector3(-0.35, 0.84, -0.02), Vector3(0, 0, 18), gold)
    _part(root, "RightShoulderWing", _box(Vector3(0.42, 0.14, 0.30)), Vector3(0.35, 0.84, -0.02), Vector3(0, 0, -18), gold)
    _part(root, "LeftHand", _sphere(0.085), Vector3(-0.53, -0.31, -0.01), Vector3.ZERO, skin)
    _part(root, "RightHand", _sphere(0.085), Vector3(0.53, -0.31, -0.01), Vector3.ZERO, skin)

    _limb(root, "LeftThigh", Vector3(-0.14, -0.74, 0), 0.115, 0.78, Vector3.ZERO, white)
    _limb(root, "RightThigh", Vector3(0.14, -0.74, 0), 0.115, 0.78, Vector3.ZERO, white)
    _limb(root, "LeftGreave", Vector3(-0.14, -1.30, -0.01), 0.105, 0.82, Vector3.ZERO, gold)
    _limb(root, "RightGreave", Vector3(0.14, -1.30, -0.01), 0.105, 0.82, Vector3.ZERO, gold)
    _part(root, "LeftBoot", _box(Vector3(0.19, 0.16, 0.32)), Vector3(-0.14, -1.74, -0.05), Vector3.ZERO, gold)
    _part(root, "RightBoot", _box(Vector3(0.19, 0.16, 0.32)), Vector3(0.14, -1.74, -0.05), Vector3.ZERO, gold)

    _part(root, "CapePanelL", _box(Vector3(0.24, 1.25, 0.04)), Vector3(-0.22, -0.05, 0.23), Vector3(-8, 8, -7), red)
    _part(root, "CapePanelR", _box(Vector3(0.24, 1.25, 0.04)), Vector3(0.22, -0.05, 0.23), Vector3(-8, -8, 7), red)
    _part(root, "CapeGoldCrest", _box(Vector3(0.22, 0.045, 0.035)), Vector3(0, 0.36, 0.27), Vector3(-8, 0, 0), gold)

    _part(root, "SpearShaft", _cylinder(0.028, 2.35), Vector3(0.76, 0.20, -0.13), Vector3(0, 0, -22), dark)
    _part(root, "SpearGripGold", _cylinder(0.045, 0.32), Vector3(0.66, -0.12, -0.13), Vector3(0, 0, -22), gold)
    _part(root, "SpearGuard", _box(Vector3(0.44, 0.08, 0.14)), Vector3(0.93, 0.72, -0.16), Vector3(0, 0, -22), gold)
    _part(root, "SpearCrystal", _box(Vector3(0.22, 0.70, 0.095)), Vector3(1.10, 1.08, -0.18), Vector3(0, 0, -22), glow)
    _part(root, "SpearTipWhite", _box(Vector3(0.08, 0.46, 0.065)), Vector3(1.21, 1.40, -0.19), Vector3(0, 0, -22), _glow(Color(1.0, 0.75, 0.55), 1.4))

static func _part(parent: Node3D, name: String, mesh: Mesh, pos: Vector3, rot_deg: Vector3, material: Material, scale_value: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = mesh
    node.position = pos
    node.rotation_degrees = rot_deg
    node.scale = scale_value
    node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    node.set_surface_override_material(0, material)
    parent.add_child(node)
    return node

static func _limb(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, rot_deg: Vector3, material: Material) -> void:
    _part(parent, name, _capsule(radius, height), pos, rot_deg, material)

static func _box(size: Vector3) -> BoxMesh:
    var mesh := BoxMesh.new()
    mesh.size = size
    return mesh

static func _sphere(radius: float) -> SphereMesh:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 24
    mesh.rings = 12
    return mesh

static func _capsule(radius: float, height: float) -> CapsuleMesh:
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    mesh.radial_segments = 24
    mesh.rings = 8
    return mesh

static func _cylinder(radius: float, height: float) -> CylinderMesh:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 18
    return mesh

static func _torus_like_box(size: Vector3) -> BoxMesh:
    return _box(size)

static func _toon(base: Color, shadow: Color, rim: Color) -> ShaderMaterial:
    var mat := ShaderMaterial.new()
    mat.shader = TOON_SHADER
    mat.set_shader_parameter("base_color", base)
    mat.set_shader_parameter("shadow_color", shadow)
    mat.set_shader_parameter("rim_color", rim)
    mat.set_shader_parameter("emission_color", Color(0.0, 0.0, 0.0, 1.0))
    mat.set_shader_parameter("emission_strength", 0.0)
    mat.set_shader_parameter("metallic", 0.0)
    mat.set_shader_parameter("roughness", 0.55)
    mat.set_shader_parameter("rim_strength", 0.45)
    return mat

static func _metal(base: Color, shadow: Color) -> ShaderMaterial:
    var mat := _toon(base, shadow, Color(1.0, 0.92, 0.72, 1.0))
    mat.set_shader_parameter("metallic", 0.35)
    mat.set_shader_parameter("roughness", 0.32)
    mat.set_shader_parameter("rim_strength", 0.62)
    return mat

static func _glow(color: Color, strength: float) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = strength
    mat.roughness = 0.18
    return mat

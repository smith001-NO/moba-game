extends Node3D
class_name GameMap

@export var blue_spawn: Marker3D
@export var red_spawn: Marker3D
@export var main_path: Path3D
@export var navigation_region: NavigationRegion3D

const MAP_SIZE: float = 120.0
const HALF_MAP: float = 60.0

func _ready() -> void:
    if not blue_spawn:
        blue_spawn = get_node_or_null("BlueSpawn") as Marker3D
    if not red_spawn:
        red_spawn = get_node_or_null("RedSpawn") as Marker3D
    if not main_path:
        main_path = get_node_or_null("Path") as Path3D
    if not navigation_region:
        navigation_region = get_node_or_null("NavigationRegion") as NavigationRegion3D
    _setup_path_curve()
    _setup_navigation_mesh()
    _tune_world()
    _create_background_details()

func _setup_path_curve() -> void:
    if not main_path:
        return
    var curve := Curve3D.new()
    curve.add_point(Vector3(-42, 0.5, 0))
    curve.add_point(Vector3(-24, 0.5, -1.2))
    curve.add_point(Vector3(0, 0.5, 0))
    curve.add_point(Vector3(24, 0.5, 1.2))
    curve.add_point(Vector3(42, 0.5, 0))
    main_path.curve = curve

func _setup_navigation_mesh() -> void:
    if not navigation_region:
        return
    var nav_mesh := navigation_region.navigation_mesh
    if not nav_mesh:
        nav_mesh = NavigationMesh.new()
        navigation_region.navigation_mesh = nav_mesh
    nav_mesh.vertices = PackedVector3Array([
        Vector3(-HALF_MAP, 0, -HALF_MAP),
        Vector3(HALF_MAP, 0, -HALF_MAP),
        Vector3(HALF_MAP, 0, HALF_MAP),
        Vector3(-HALF_MAP, 0, HALF_MAP),
    ])
    nav_mesh.clear_polygons()
    nav_mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))

func get_blue_spawn_position() -> Vector3:
    return blue_spawn.global_position if blue_spawn else Vector3(-42, 0.6, 0)

func get_red_spawn_position() -> Vector3:
    return red_spawn.global_position if red_spawn else Vector3(42, 0.6, 0)

func get_main_path_curve() -> Curve3D:
    return main_path.curve if main_path else null

func _tune_world() -> void:
    var env_node := get_node_or_null("WorldEnvironment") as WorldEnvironment
    if env_node and env_node.environment:
        var env := env_node.environment
        env.ambient_light_energy = 1.25
        env.tonemap_exposure = 1.15
        env.fog_enabled = true
        env.fog_light_energy = 0.7
        env.fog_density = 0.0028
        env.fog_sky_affect = 0.4
        env.glow_enabled = true
        env.glow_intensity = 0.12
        env.ssao_enabled = true
        env.ssao_radius = 1.6
        env.ssao_intensity = 1.7
        env.ssr_enabled = true
        env.ssr_max_steps = 32
    var sun := get_node_or_null("DirectionalLight") as DirectionalLight3D
    if sun:
        sun.light_energy = 1.5
        sun.shadow_enabled = true
        sun.directional_shadow_max_distance = 180.0
        sun.position = Vector3(0.0, 20.0, 0.0)
        sun.rotation = Vector3(-0.9, 0.72, 0.0)

func _create_background_details() -> void:
    if has_node("Decorations"):
        return
    var decorations := Node3D.new()
    decorations.name = "Decorations"
    add_child(decorations)
    _add_ground_layers(decorations)
    _add_lane_foundation(decorations)
    _add_river_and_bridge(decorations)
    _add_jungle_and_cliffs(decorations)
    _add_ruins_and_banners(decorations)
    _add_base_architecture(decorations)
    _add_lane_lights(decorations)
    _add_premium_arena_pass(decorations)

func _mat(color: Color, roughness: float = 0.8, emission: bool = false, metallic: float = 0.0, emission_strength: float = 0.4) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    if emission:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = emission_strength
    return material

func _add_mesh(parent: Node, name: String, mesh: Mesh, pos: Vector3, material: Material, scale_value: Vector3 = Vector3.ONE, rotation: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = mesh
    node.position = pos
    node.scale = scale_value
    node.rotation = rotation
    node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    node.set_surface_override_material(0, material)
    parent.add_child(node)
    return node

func _add_ground_layers(parent: Node3D) -> void:
    var grass_plane := PlaneMesh.new()
    grass_plane.size = Vector2(120.0, 120.0)
    _add_mesh(parent, "GrassUnderlay", grass_plane, Vector3(0, 0.01, 0), _mat(Color(0.10, 0.34, 0.12, 1.0), 0.95))
    var grass_plane_2 := PlaneMesh.new()
    grass_plane_2.size = Vector2(98.0, 98.0)
    _add_mesh(parent, "GrassMid", grass_plane_2, Vector3(0, 0.012, 0), _mat(Color(0.14, 0.40, 0.15, 1.0), 0.9))
    var vignette := CylinderMesh.new()
    vignette.top_radius = 56.0
    vignette.bottom_radius = 56.0
    vignette.height = 0.08
    _add_mesh(parent, "CenterField", vignette, Vector3(0, 0.018, 0), _mat(Color(0.12, 0.30, 0.13, 1.0), 0.95))

func _add_lane_foundation(parent: Node3D) -> void:
    var lane_base := PlaneMesh.new()
    lane_base.size = Vector2(96.0, 14.0)
    _add_mesh(parent, "LaneBase", lane_base, Vector3(0, 0.04, 0), _mat(Color(0.24, 0.22, 0.20, 1.0), 0.82))
    var lane_center := PlaneMesh.new()
    lane_center.size = Vector2(96.0, 7.0)
    _add_mesh(parent, "LaneCenter", lane_center, Vector3(0, 0.05, 0), _mat(Color(0.34, 0.33, 0.32, 1.0), 0.55))
    var curb := BoxMesh.new()
    curb.size = Vector3(96.0, 0.18, 0.36)
    _add_mesh(parent, "LaneCurbNorth", curb, Vector3(0.0, 0.11, -7.0), _mat(Color(0.46, 0.42, 0.36, 1.0), 0.48))
    _add_mesh(parent, "LaneCurbSouth", curb, Vector3(0.0, 0.11, 7.0), _mat(Color(0.46, 0.42, 0.36, 1.0), 0.48))
    var inner_strip := PlaneMesh.new()
    inner_strip.size = Vector2(96.0, 1.4)
    _add_mesh(parent, "LaneInnerGlow", inner_strip, Vector3(0.0, 0.065, 0.0), _mat(Color(0.20, 0.32, 0.48, 1.0), 0.25, true, 0.0, 0.3))

    var tile_mesh := BoxMesh.new()
    tile_mesh.size = Vector3(2.2, 0.08, 3.0)
    for x in range(-42, 43, 6):
        var z_offsets = [-4.0, 0.0, 4.0]
        for z in z_offsets:
            _add_mesh(parent, "LaneTile", tile_mesh, Vector3(float(x), 0.09, z), _mat(Color(0.52, 0.48, 0.42, 1.0), 0.58), Vector3.ONE, Vector3(0.0, float((x + int(z)) % 4) * 0.08, 0.0))

func _add_river_and_bridge(parent: Node3D) -> void:
    var river_bed := PlaneMesh.new()
    river_bed.size = Vector2(14.0, 120.0)
    _add_mesh(parent, "RiverBed", river_bed, Vector3(0.0, 0.02, 0.0), _mat(Color(0.07, 0.16, 0.18, 1.0), 0.6))
    var river_water := PlaneMesh.new()
    river_water.size = Vector2(10.0, 120.0)
    _add_mesh(parent, "RiverWater", river_water, Vector3(0.0, 0.05, 0.0), _mat(Color(0.10, 0.46, 0.72, 0.9), 0.2, true, 0.0, 0.55))
    var bank := BoxMesh.new()
    bank.size = Vector3(1.4, 0.32, 120.0)
    _add_mesh(parent, "RiverBankWest", bank, Vector3(-5.8, 0.16, 0.0), _mat(Color(0.34, 0.30, 0.24, 1.0), 0.7))
    _add_mesh(parent, "RiverBankEast", bank, Vector3(5.8, 0.16, 0.0), _mat(Color(0.34, 0.30, 0.24, 1.0), 0.7))

    var plaza := CylinderMesh.new()
    plaza.top_radius = 10.5
    plaza.bottom_radius = 10.5
    plaza.height = 0.18
    _add_mesh(parent, "MidPlaza", plaza, Vector3(0.0, 0.09, 0.0), _mat(Color(0.48, 0.44, 0.38, 1.0), 0.48))
    var sigil := CylinderMesh.new()
    sigil.top_radius = 3.6
    sigil.bottom_radius = 3.6
    sigil.height = 0.04
    _add_mesh(parent, "MidSigil", sigil, Vector3(0.0, 0.13, 0.0), _mat(Color(0.24, 0.62, 0.92, 1.0), 0.18, true, 0.0, 0.8))

    var bridge := BoxMesh.new()
    bridge.size = Vector3(14.0, 0.24, 8.0)
    _add_mesh(parent, "CenterBridge", bridge, Vector3(0.0, 0.16, 0.0), _mat(Color(0.50, 0.47, 0.43, 1.0), 0.45))

func _add_jungle_and_cliffs(parent: Node3D) -> void:
    var boundary := BoxMesh.new()
    boundary.size = Vector3(120.0, 5.0, 3.0)
    _add_mesh(parent, "NorthCliff", boundary, Vector3(0.0, 2.5, -59.0), _mat(Color(0.18, 0.22, 0.24, 1.0), 0.92))
    _add_mesh(parent, "SouthCliff", boundary, Vector3(0.0, 2.5, 59.0), _mat(Color(0.18, 0.22, 0.24, 1.0), 0.92))
    var side_boundary := BoxMesh.new()
    side_boundary.size = Vector3(3.0, 5.0, 120.0)
    _add_mesh(parent, "WestCliff", side_boundary, Vector3(-59.0, 2.5, 0.0), _mat(Color(0.16, 0.20, 0.23, 1.0), 0.92))
    _add_mesh(parent, "EastCliff", side_boundary, Vector3(59.0, 2.5, 0.0), _mat(Color(0.16, 0.20, 0.23, 1.0), 0.92))

    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.18
    trunk_mesh.bottom_radius = 0.28
    trunk_mesh.height = 2.6
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.4
    crown_mesh.height = 2.6
    var shrub_mesh := SphereMesh.new()
    shrub_mesh.radius = 0.7
    shrub_mesh.height = 1.2

    var tree_positions = [
        Vector3(-45, 1.3, -20), Vector3(-38, 1.3, -30), Vector3(-28, 1.3, 26), Vector3(-18, 1.3, -34),
        Vector3(-10, 1.3, 30), Vector3(10, 1.3, -32), Vector3(18, 1.3, 28), Vector3(28, 1.3, -28),
        Vector3(36, 1.3, 30), Vector3(46, 1.3, 18), Vector3(-46, 1.3, 18), Vector3(40, 1.3, -18)
    ]
    for pos in tree_positions:
        _add_mesh(parent, "TreeTrunk", trunk_mesh, pos, _mat(Color(0.33, 0.20, 0.12, 1.0), 0.85))
        _add_mesh(parent, "TreeCrown", crown_mesh, pos + Vector3(0, 2.1, 0), _mat(Color(0.08, 0.34, 0.12, 1.0), 0.98))
        _add_mesh(parent, "Shrub", shrub_mesh, pos + Vector3(1.6, 0.55, 0.8), _mat(Color(0.10, 0.42, 0.13, 1.0), 0.95), Vector3(0.7, 0.6, 0.8))

    var rock_mesh := BoxMesh.new()
    rock_mesh.size = Vector3(1.4, 1.0, 1.8)
    var rock_positions = [
        Vector3(-18, 0.5, -14), Vector3(-8, 0.55, 16), Vector3(12, 0.6, 13), Vector3(20, 0.45, -16),
        Vector3(-35, 0.65, 13), Vector3(34, 0.65, -12), Vector3(-48, 0.8, -8), Vector3(48, 0.8, 8)
    ]
    for i in range(rock_positions.size()):
        var scale_value := Vector3(1.0 + float(i % 3) * 0.35, 1.0 + float(i % 2) * 0.25, 0.9 + float(i % 4) * 0.18)
        _add_mesh(parent, "Rock", rock_mesh, rock_positions[i], _mat(Color(0.28, 0.31, 0.34, 1.0), 0.88), scale_value, Vector3(0.0, float(i) * 0.28, 0.0))

func _add_ruins_and_banners(parent: Node3D) -> void:
    var column_mesh := CylinderMesh.new()
    column_mesh.top_radius = 0.38
    column_mesh.bottom_radius = 0.46
    column_mesh.height = 3.8
    var banner_mesh := BoxMesh.new()
    banner_mesh.size = Vector3(0.08, 2.2, 1.4)
    var crystal_mesh := SphereMesh.new()
    crystal_mesh.radius = 0.36
    crystal_mesh.height = 0.72

    var ruin_positions = [Vector3(-24, 1.9, -10), Vector3(-24, 1.9, 10), Vector3(24, 1.9, -10), Vector3(24, 1.9, 10)]
    for pos in ruin_positions:
        _add_mesh(parent, "RuinColumn", column_mesh, pos, _mat(Color(0.60, 0.58, 0.54, 1.0), 0.55))
        _add_mesh(parent, "RuinColumn", column_mesh, pos + Vector3(4.0, 0.0, 0.0), _mat(Color(0.60, 0.58, 0.54, 1.0), 0.55))

    _add_mesh(parent, "BlueBanner", banner_mesh, Vector3(-30, 2.3, -8), _mat(Color(0.10, 0.40, 0.96, 1.0), 0.42, true, 0.0, 0.25))
    _add_mesh(parent, "BlueBanner", banner_mesh, Vector3(-30, 2.3, 8), _mat(Color(0.10, 0.40, 0.96, 1.0), 0.42, true, 0.0, 0.25))
    _add_mesh(parent, "RedBanner", banner_mesh, Vector3(30, 2.3, -8), _mat(Color(0.92, 0.14, 0.12, 1.0), 0.42, true, 0.0, 0.25))
    _add_mesh(parent, "RedBanner", banner_mesh, Vector3(30, 2.3, 8), _mat(Color(0.92, 0.14, 0.12, 1.0), 0.42, true, 0.0, 0.25))

    _add_mesh(parent, "MidCrystalBlue", crystal_mesh, Vector3(-6.0, 0.6, -8.0), _mat(Color(0.24, 0.72, 1.0, 1.0), 0.2, true, 0.0, 0.9), Vector3(1.0, 2.4, 1.0))
    _add_mesh(parent, "MidCrystalBlue", crystal_mesh, Vector3(-6.0, 0.6, 8.0), _mat(Color(0.24, 0.72, 1.0, 1.0), 0.2, true, 0.0, 0.9), Vector3(1.0, 2.4, 1.0))
    _add_mesh(parent, "MidCrystalRed", crystal_mesh, Vector3(6.0, 0.6, -8.0), _mat(Color(1.0, 0.38, 0.28, 1.0), 0.2, true, 0.0, 0.9), Vector3(1.0, 2.4, 1.0))
    _add_mesh(parent, "MidCrystalRed", crystal_mesh, Vector3(6.0, 0.6, 8.0), _mat(Color(1.0, 0.38, 0.28, 1.0), 0.2, true, 0.0, 0.9), Vector3(1.0, 2.4, 1.0))

func _add_base_architecture(parent: Node3D) -> void:
    var platform_mesh := CylinderMesh.new()
    platform_mesh.top_radius = 9.0
    platform_mesh.bottom_radius = 9.0
    platform_mesh.height = 0.40
    _add_mesh(parent, "BlueBasePlatform", platform_mesh, Vector3(-42, 0.20, 0), _mat(Color(0.34, 0.36, 0.44, 1.0), 0.48))
    _add_mesh(parent, "RedBasePlatform", platform_mesh, Vector3(42, 0.20, 0), _mat(Color(0.44, 0.34, 0.34, 1.0), 0.48))

    var glow_ring := CylinderMesh.new()
    glow_ring.top_radius = 6.4
    glow_ring.bottom_radius = 6.4
    glow_ring.height = 0.06
    _add_mesh(parent, "BlueBaseRing", glow_ring, Vector3(-42, 0.43, 0), _mat(Color(0.10, 0.40, 1.0, 1.0), 0.28, true, 0.0, 0.85))
    _add_mesh(parent, "RedBaseRing", glow_ring, Vector3(42, 0.43, 0), _mat(Color(1.0, 0.18, 0.12, 1.0), 0.28, true, 0.0, 0.85))

    var obelisk_body := CylinderMesh.new()
    obelisk_body.top_radius = 0.45
    obelisk_body.bottom_radius = 0.65
    obelisk_body.height = 4.8
    var obelisk_tip := SphereMesh.new()
    obelisk_tip.radius = 0.32
    obelisk_tip.height = 0.64
    for pos in [Vector3(-48, 2.4, -7), Vector3(-48, 2.4, 7), Vector3(-36, 2.4, -7), Vector3(-36, 2.4, 7)]:
        _add_mesh(parent, "BlueObelisk", obelisk_body, pos, _mat(Color(0.60, 0.66, 0.78, 1.0), 0.42, false, 0.2))
        _add_mesh(parent, "BlueObeliskTip", obelisk_tip, pos + Vector3(0, 2.6, 0), _mat(Color(0.22, 0.72, 1.0, 1.0), 0.2, true, 0.0, 0.7), Vector3(1.0, 2.0, 1.0))
    for pos in [Vector3(48, 2.4, -7), Vector3(48, 2.4, 7), Vector3(36, 2.4, -7), Vector3(36, 2.4, 7)]:
        _add_mesh(parent, "RedObelisk", obelisk_body, pos, _mat(Color(0.78, 0.62, 0.54, 1.0), 0.42, false, 0.2))
        _add_mesh(parent, "RedObeliskTip", obelisk_tip, pos + Vector3(0, 2.6, 0), _mat(Color(1.0, 0.35, 0.22, 1.0), 0.2, true, 0.0, 0.7), Vector3(1.0, 2.0, 1.0))

func _add_lane_lights(parent: Node3D) -> void:
    var positions = [Vector3(-30, 1.4, -6.4), Vector3(-18, 1.4, 6.4), Vector3(-6, 1.4, -6.4), Vector3(6, 1.4, 6.4), Vector3(18, 1.4, -6.4), Vector3(30, 1.4, 6.4)]
    for i in range(positions.size()):
        var light := OmniLight3D.new()
        light.name = "LaneLight%d" % i
        light.position = positions[i]
        light.light_energy = 0.7
        light.omni_range = 5.5
        light.light_color = Color(0.4, 0.7, 1.0, 1.0) if i % 2 == 0 else Color(1.0, 0.48, 0.36, 1.0)
        parent.add_child(light)


func _add_premium_arena_pass(parent: Node3D) -> void:
    _add_brush_fields(parent)
    _add_base_gates(parent)
    _add_tiered_cliff_caps(parent)
    _add_lane_statues(parent)

func _add_brush_fields(parent: Node3D) -> void:
    var grass_blade := BoxMesh.new()
    grass_blade.size = Vector3(0.08, 0.72, 0.05)
    var mat_a := _mat(Color(0.05, 0.32, 0.09, 1.0), 0.95)
    var mat_b := _mat(Color(0.12, 0.46, 0.12, 1.0), 0.95)
    var centers = [Vector3(-22, 0.36, -18), Vector3(-22, 0.36, 18), Vector3(22, 0.36, -18), Vector3(22, 0.36, 18), Vector3(-40, 0.36, -12), Vector3(40, 0.36, 12)]
    for c in centers:
        for i in range(18):
            var dx: float = float((i * 37) % 11) * 0.42 - 2.1
            var dz: float = float((i * 53) % 9) * 0.46 - 1.8
            var mat: Material = mat_a if i % 2 == 0 else mat_b
            _add_mesh(parent, "BrushBlade", grass_blade, c + Vector3(dx, 0.0, dz), mat, Vector3(1.0, 0.8 + float(i % 3) * 0.22, 1.0), Vector3(0.0, float(i) * 0.31, float(i % 5) * 0.08))

func _add_base_gates(parent: Node3D) -> void:
    var pillar := BoxMesh.new()
    pillar.size = Vector3(1.2, 5.2, 1.2)
    var arch := BoxMesh.new()
    arch.size = Vector3(8.0, 0.9, 1.2)
    var blue_stone := _mat(Color(0.45, 0.50, 0.62, 1.0), 0.45, false, 0.15)
    var red_stone := _mat(Color(0.60, 0.44, 0.38, 1.0), 0.45, false, 0.15)
    for side in [-1, 1]:
        _add_mesh(parent, "BlueGatePillar", pillar, Vector3(-42, 2.6, float(side) * 10.0), blue_stone)
        _add_mesh(parent, "RedGatePillar", pillar, Vector3(42, 2.6, float(side) * 10.0), red_stone)
    _add_mesh(parent, "BlueGateArch", arch, Vector3(-42, 5.2, 0), blue_stone)
    _add_mesh(parent, "RedGateArch", arch, Vector3(42, 5.2, 0), red_stone)
    var crystal := SphereMesh.new()
    crystal.radius = 0.5
    crystal.height = 1.0
    _add_mesh(parent, "BlueGateCrystal", crystal, Vector3(-42, 6.05, 0), _mat(Color(0.20, 0.70, 1.0, 1.0), 0.18, true, 0.0, 1.1), Vector3(1.0, 1.8, 1.0))
    _add_mesh(parent, "RedGateCrystal", crystal, Vector3(42, 6.05, 0), _mat(Color(1.0, 0.24, 0.16, 1.0), 0.18, true, 0.0, 1.1), Vector3(1.0, 1.8, 1.0))

func _add_tiered_cliff_caps(parent: Node3D) -> void:
    var slab := BoxMesh.new()
    slab.size = Vector3(32.0, 0.55, 7.0)
    var mat := _mat(Color(0.22, 0.25, 0.26, 1.0), 0.88)
    var placements = [
        Vector3(-36, 0.55, -48), Vector3(0, 0.55, -48), Vector3(36, 0.55, -48),
        Vector3(-36, 0.55, 48), Vector3(0, 0.55, 48), Vector3(36, 0.55, 48)
    ]
    for p in placements:
        _add_mesh(parent, "LayeredCliffCap", slab, p, mat)
    var side := BoxMesh.new()
    side.size = Vector3(7.0, 0.55, 32.0)
    for p in [Vector3(-48, 0.55, -34), Vector3(-48, 0.55, 0), Vector3(-48, 0.55, 34), Vector3(48, 0.55, -34), Vector3(48, 0.55, 0), Vector3(48, 0.55, 34)]:
        _add_mesh(parent, "SideCliffCap", side, p, mat)

func _add_lane_statues(parent: Node3D) -> void:
    var base := CylinderMesh.new()
    base.top_radius = 1.2
    base.bottom_radius = 1.45
    base.height = 0.65
    var body := CapsuleMesh.new()
    body.radius = 0.35
    body.height = 1.8
    var blade := BoxMesh.new()
    blade.size = Vector3(0.16, 1.7, 0.18)
    var stone := _mat(Color(0.62, 0.60, 0.56, 1.0), 0.62, false, 0.1)
    var positions = [Vector3(-16, 0.35, -9.5), Vector3(-16, 0.35, 9.5), Vector3(16, 0.35, -9.5), Vector3(16, 0.35, 9.5)]
    for i in range(positions.size()):
        var pos: Vector3 = positions[i]
        _add_mesh(parent, "LaneStatueBase", base, pos, stone)
        _add_mesh(parent, "LaneStatueBody", body, pos + Vector3(0, 1.05, 0), stone)
        _add_mesh(parent, "LaneStatueBlade", blade, pos + Vector3(0.55 if i % 2 == 0 else -0.55, 1.45, 0), stone, Vector3.ONE, Vector3(0.0, 0.0, -18.0 if i % 2 == 0 else 18.0))

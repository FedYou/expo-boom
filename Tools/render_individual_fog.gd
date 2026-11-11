extends SceneTree

## Renderiza el elemento IndividualFog (Sprite2D + IndividualFog.gdshader) a un PNG.
##
## Dibuja el sprite en un SubViewport transparente del mismo tamaño que la
## textura (128x64) usando el pipeline real de render de Godot (mismo shader,
## mismos parámetros del ShaderMaterial de "Game/Fog/individual_fog .tscn"
## y filtro Nearest, igual que el proyecto), y guarda el resultado como
## textura lista para usar.
##
## Uso:
##   godot --path . --script res://Tools/render_individual_fog.gd --resolution 1x1 --borderless --position 0,0

const VIEWPORT_SIZE := Vector2i(128, 64)

const SOURCE_TEXTURE := "res://Assets/Textures/Fog/IndividualFog.png"
const SOURCE_SHADER := "res://Game/Shaders/IndividualFog.gdshader"
const OUT_PATH := "res://Assets/Textures/Fog/IndividualFog_baked.png"

# Parámetros del ShaderMaterial en Game/Fog/individual_fog .tscn
const BLUR_RADIUS := 9.222000390545
const BLUR_STRENGTH := 1.0
const CLOUD_SOFTNESS := 1.2010000537876202
const SCATTERING := 1.070000050825
const EDGE_THRESHOLD := 0.130000006175

const WAIT_FRAMES := 6

var _vp: SubViewport
var _texture: Texture2D
var _frames := 0


func _initialize() -> void:
	_texture = load(SOURCE_TEXTURE)
	var shader: Shader = load(SOURCE_SHADER)

	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("blur_radius", BLUR_RADIUS)
	mat.set_shader_parameter("blur_strength", BLUR_STRENGTH)
	mat.set_shader_parameter("cloud_softness", CLOUD_SOFTNESS)
	mat.set_shader_parameter("scattering", SCATTERING)
	mat.set_shader_parameter("edge_threshold", EDGE_THRESHOLD)

	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.material = mat
	sprite.texture = _texture
	# Centrado en el viewport -> mapeo 1:1 con los texels de la textura.
	sprite.position = VIEWPORT_SIZE / 2.0
	# El proyecto usa default_texture_filter = Nearest (project.godot);
	# se marca explícito para que el bake sea idéntico.
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	_vp = SubViewport.new()
	_vp.name = "FogBakeViewport"
	_vp.size = VIEWPORT_SIZE
	_vp.transparent_bg = true
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_vp.add_child(sprite)
	root.add_child(_vp)

	process_frame.connect(_on_frame)


func _on_frame() -> void:
	_frames += 1
	if _frames < WAIT_FRAMES:
		return

	# Alpha final calculado por el shader (la captura viene con RGB
	# premultiplicado por el blending, así que el RGB se toma aparte).
	var render: Image = _vp.get_texture().get_image()
	# RGB original tal y como lo lee la GPU (textura importada, con
	# fix_alpha_border aplicado por el importador).
	var source: Image = _texture.get_image()

	assert(source.get_size() == VIEWPORT_SIZE)
	assert(render.get_size() == VIEWPORT_SIZE)

	var out := Image.create(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, false, Image.FORMAT_RGBA8)
	var a_min := 1.0
	var a_max := 0.0
	var covered := 0

	for y in VIEWPORT_SIZE.y:
		for x in VIEWPORT_SIZE.x:
			var s := source.get_pixel(x, y)
			var r := render.get_pixel(x, y)
			var a: float = r.a
			out.set_pixel(x, y, Color(s.r, s.g, s.b, a))
			a_min = minf(a_min, a)
			a_max = maxf(a_max, a)
			if a > 0.0:
				covered += 1

	var err := out.save_png(OUT_PATH)
	if err != OK:
		push_error("No se pudo guardar %s (error %d)" % [OUT_PATH, err])
		quit(1)
		return

	print("Guardado: ", OUT_PATH)
	print("alpha min=%f max=%f | pixeles con alpha>0: %d/%d" % [a_min, a_max, covered, VIEWPORT_SIZE.x * VIEWPORT_SIZE.y])
	_ascii_preview(out)
	quit()


## Vista previa en ASCII del canal alpha (para verificar el resultado en consola).
func _ascii_preview(img: Image, width: int = 64) -> void:
	const CHARS := " .:-=+*#%@"
	var height: int = int(round(float(img.get_height()) * width / img.get_width()))
	var step_x := float(img.get_width()) / width
	var step_y := float(img.get_height()) / height
	for py in height:
		var line := ""
		for px in width:
			var x := int(px * step_x)
			var y := int(py * step_y)
			var a: float = img.get_pixel(x, y).a
			var idx: int = clampi(int(a * CHARS.length()), 0, CHARS.length() - 1)
			line += CHARS[idx]
		print(line)

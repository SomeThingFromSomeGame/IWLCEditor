shader_type canvas_item;

global uniform vec2 SCREEN_SIZE;

global uniform vec2 VIEWPORT_POS; // where the top left corner of the game viewport is, in world space
global uniform float RCAMERA_ZOOM = 1; // reciprocal of camera zoom

void fragment() {
	// pixelate
	vec2 worldScreenSize = SCREEN_SIZE*RCAMERA_ZOOM;
	COLOR.rgb = texture(TEXTURE, (floor(UV*worldScreenSize + fract(VIEWPORT_POS)) - fract(VIEWPORT_POS) + vec2(0.5,0.5))/worldScreenSize).rgb;
}

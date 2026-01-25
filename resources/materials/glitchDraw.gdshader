shader_type canvas_item;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// https://github.com/hughsk/glsl-hsv2rgb
vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 base = COLOR;
	float time = mod(TIME*0.024, 72.0);
	vec2 uv = UV;
	float hue = rand(uv+vec2(time,0));
	float sat = rand(uv+vec2(0,time));
	COLOR = vec4(hsv2rgb(vec3(hue,sat*base.r,base.g)),base.a);
}
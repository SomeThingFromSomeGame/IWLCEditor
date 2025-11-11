shader_type canvas_item;
uniform float pauseAnimTimer;
uniform bool darken;

// https://inspirnathan.com/posts/49-shadertoy-tutorial-part-3
vec2 rotate(vec2 uv, float th) {
  return mat2(vec2(cos(th), sin(th)), vec2(-sin(th), cos(th))) * uv;
}

bool sdfSquare(vec2 pos, float size, float angle, vec2 center) {
  float x = pos.x - center.x;
  float y = pos.y - center.y;
  vec2 rotated = rotate(vec2(x,y), angle);
  float d = max(abs(rotated.x), abs(rotated.y)) - size;

  return d <= 0.;
}

void fragment() {
	if (darken) {
		COLOR.rgb *= 0.6; // i cant figure out what/where the actual effect is
	}
	if (pauseAnimTimer > 0.0) {
		float squareT;
		if (pauseAnimTimer < 0.4166666667) {
			squareT = min(pauseAnimTimer*4.7123889804,1.5707963268);
		} else {
			squareT = 1.5707963268-min((pauseAnimTimer-0.4166666667)*4.7123889804,1.5707963268);
		}
		float squareScale = sin(squareT);
		float squareAngle = (1.0-squareScale)*1.5707963268;
		vec2 pos = UV.xy*vec2(800,608);
		if (mod(pos.y, 64) <= 32.0) {
			squareAngle *= -1.0;
		}
		if (sdfSquare(mod(pos,vec2(32,32)), squareScale*16.0, squareAngle, vec2(16,16))) {
			COLOR = vec4(0,0,0,0);
		}
	}
}

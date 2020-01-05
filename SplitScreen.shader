shader_type canvas_item;
render_mode unshaded;

uniform sampler2D viewport1 : hint_albedo;
uniform sampler2D viewport2 : hint_albedo;
uniform bool split_active; 	// true: split screen, false: use view1
uniform vec2 split_origin;	// center point in UV coordinates. (0.5, 0.5) for center
uniform vec2 player1;		// position of player 1 un UV coordinates
uniform vec2 player2;		// position of player 2 un UV coordinates
uniform float border_width;	// width of the split boder
uniform vec4 border_color;	// color of the split border

// from https://stackoverflow.com/questions/15276454/is-it-possible-to-draw-line-thickness-in-a-fragment-shader
float distanceToLine(vec2 p1, vec2 p2, vec2 point) {
    float a = p1.y-p2.y;
    float b = p2.x-p1.x;
    return abs(a*point.x+b*point.y+p1.x*p2.y-p2.x*p1.y) / sqrt(a*a+b*b);
}

void fragment() {
    vec3 view1 = texture(viewport1, UV).rgb;
    vec3 view2 = texture(viewport2, UV).rgb;

	// Compute viewport's width and height in pixels
	float width = float(textureSize(viewport1, 0).x);
	float height = float(textureSize(viewport1, 0).y);
	
	if (split_active) {
		vec2 dx = player2 - player1;
		float split_slope;
		
		if(dx.y != 0.0) {
			split_slope = dx.x / dx.y;
		}
		else {
			split_slope = 100000.0; // High value (vertical split) if dx.y = 0
		}
		
		vec2 split_line_start = vec2(0.0, height * ((split_origin.x - 0.0) * split_slope + split_origin.y));
		vec2 split_line_end = vec2(width, height * ((split_origin.x - 1.0) * split_slope + split_origin.y));
		float distance_to_split_line = distanceToLine(split_line_start, split_line_end, vec2(UV.x * width, UV.y * height));
		
		// Draw split border if close enough
		if(distance_to_split_line < border_width) {
			COLOR = border_color;
		}
		else {
			float split_current_y = (split_origin.x - UV.x) * split_slope + split_origin.y;
			float split_player1_y = (split_origin.x - player1.x) * split_slope + split_origin.y;

			// Check on which side of the split UV is and select the proper view
			if (UV.y > split_current_y) {
				if (player1.y > split_player1_y) {
					COLOR = vec4(view1, 1.0);
				}
				else {
					COLOR = vec4(view2, 1.0);
				}
			}
			else {
				if (player1.y < split_player1_y) {
					COLOR = vec4(view1, 1.0);
				}
				else {
					COLOR = vec4(view2, 1.0);
				}
			}
		}
	}
	else {
		COLOR = vec4(view1, 1.0);
	}
}
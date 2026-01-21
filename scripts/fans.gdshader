shader_type spatial;

uniform float cheer_speed = 4.0;
uniform float cheer_height = 0.4;

// Move function to the top and use "16u" for unsigned shifts
uint hash(uint x) {
	x = ((x >> 16u) ^ x) * 0x45d9f3bU;
	x = ((x >> 16u) ^ x) * 0x45d9f3bU;
	x = (x >> 16u) ^ x;
	return x;
}

void vertex() {
	// Convert the hash result to a 0.0 - 1.0 float range
	float offset = float(hash(uint(INSTANCE_ID))) / 4294967295.0;
	
	// Use the offset to randomize the jump timing
	// Multiply offset by 6.28 (2*PI) so they are spread across a full circle
	float jump = max(0.0, sin((TIME * cheer_speed) + offset * 6.28));
	
	VERTEX.y += jump * cheer_height;
}
// Author: Nicolas Barradeau
// Title: waves

#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER
const vec3 blue				= vec3( 0.4453125, 	0.890625, 	0.890625 );
const vec3 yellow_bright	= vec3( 0.9296875, 	0.8671875, 	0.18359375 );
const vec3 yellow_dark		= vec3( 0.921875,  	0.80078125, 0.);
const vec3 orange			= vec3( 0.88671875, 0.625,		0.1171875);
const vec3 pink				= vec3( 0.92578125, 0.46484375,	0.89453125);


uniform float u_time;
uniform vec2 u_resolution;
uniform float u_mouse;

// 1D random numbers
float rand(float n){
    return fract( ( sin( n )  * 43758.5453123 ) );
}

// 2D random numbers
vec2 rand2(in vec2 p){
	return fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

// 1D noise
float noise(float p)
{
	float fl = floor(p);
	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}


void main() {
    

    float scale = 1.;
    vec2 sc = ( gl_FragCoord.xy / u_resolution );
    vec2 uv = sc * u_resolution.xy / max(u_resolution.x, u_resolution.y);
    uv  *= scale;

    float angle = radians( 45 * sc.y + sin( u_time ) );
    float ca = cos( angle );
    float sa = sin( angle );

    uv *= mat2( ca, sa, -sa, ca );
    vec2 i = floor( uv );
    vec2 f = fract( uv );

    float v0 = rand( floor( uv * 20. ).x+ u_time * 0.00001 );
    vec3 color0 = mix( blue, yellow_dark, v0 );
    
    float v1 = rand( floor( uv * 40. ).y + u_time * 0.00001 );
    vec3 color1 = mix( yellow_bright, blue, v1 );

    float v2 = rand( floor( uv * 80. ).y + u_time * 0.00001 );
    vec3 color2 = mix( pink, yellow_bright, v2 );

    float a = ( sc.y - .15 + sin( u_time * 2.5 + sc.x * 8. ) * .1 );
    float b = ( sc.y + .13 + sin( - u_time * 2.25 + sc.x * 6. ) * .15 );
    float c = ( sc.y - .13 + cos( .25 + u_time * 1.25 + sc.x * 4. ) * .25 );

    
    vec3 color = mix( orange, blue, v0 ) * .75;
    color = mix( color, color2 * .95, smoothstep( 0.5,.501, c ) );
    color = mix( color, color0, smoothstep( 0.501,.5, a )  );
    color = mix( color, color1 * 1.25, smoothstep( 0.501,.5, b ) );

	gl_FragColor = vec4(color,1.0);
       

}
// Author: Nicolas Barradeau
// Title: panopitcon ( dark future )

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159

#define PROCESSING_COLOR_SHADER
const vec3 blue				= vec3( 0.4453125, 	0.890625, 	0.890625 );
const vec3 yellow_bright	= vec3( 0.9296875, 	0.8671875, 	0.18359375 );
const vec3 yellow_dark		= vec3( 0.921875,  	0.80078125, 0.);
const vec3 orange			= vec3( 0.88671875, 0.625,		0.1171875);
const vec3 pink				= vec3( 0.92578125, 0.46484375,	0.89453125);

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


float rand(float n){
    return fract( ( sin( n )  * 43758.5453123 ) );
}
float noise(float p)
{
	float fl = floor(p);
	float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}

float f( vec2 p, float a, float b){
    return ( atan(p.y+a,p.x+b) );
}

void main() {

    float scale = 10.;
    vec2 sc = 2. * ( gl_FragCoord.xy / u_resolution );
    vec2 st = sc * u_resolution.xy / max(u_resolution.x, u_resolution.y);
    st *= 6.;
    vec2 uv = 1. + sc * u_resolution.xy / max(u_resolution.x, u_resolution.y);
    uv  *= scale;
    
    float t = ( u_time *.1 ) - 10.;
    vec2 id = floor( uv );
    vec2 fr = fract( uv);

    float acc = 0.;
    for( float i = 1.; i < 20.; i+=1. ){
    	vec2 id = floor( uv * scale / i ) + t;
    	vec2 fr = fract( uv * scale / i ) + ( ( t ) - floor( uv.x  * t ) );
        fr.y += fract( fr.y );
        acc += .205 * sin( f( sc * floor( sc ).x + floor( sc ).y, fr.x / cos( id.x ), fr.y / sin( id.y ) ) );
    }
    
    float w = sc.y + ( sin( ( sc.y - t  ) * rand( floor(st+t).x ) * 10. ) );
    w *=  ( cos( ( sc.x - t * sc.y * 50.) * 1. ) );
    
    float v = acc * pow( length( sc-vec2( 1., 0. ) ), 2. );
    
    vec3 color = mix( blue * v, orange * v, smoothstep( 0.,1., w ) );   
    
    color *= smoothstep( .65,.751,1.-sin( distance( fract( st ), vec2(0.5) ) ) );

    gl_FragColor = vec4(color,1.0);

}
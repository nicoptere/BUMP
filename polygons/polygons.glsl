// Author: Nicolas Barradeau
// Title: polygons

#ifdef GL_ES
precision mediump float;
#endif
#define PI 3.14159265359
#define PROCESSING_COLOR_SHADER

const vec3 blue				= vec3( 0.4453125, 	0.890625, 	0.890625 );
const vec3 yellow_bright	= vec3( 0.9296875, 	0.8671875, 	0.18359375 );
const vec3 yellow_dark		= vec3( 0.921875,  	0.80078125, 0.);
const vec3 orange			= vec3( 0.88671875, 0.625,		0.1171875);
const vec3 pink				= vec3( 0.92578125, 0.46484375,	0.89453125);

uniform vec2 u_resolution;
uniform float u_time;

float poly( vec2 c, float sides, float scale, float thickness ){

    float a=atan(c.x,c.y);
    float b=6.28319/float(sides);
    return smoothstep( .5-thickness, .5, cos(floor(.5+a/b)*b-a)*length(c.xy) * ( 1. / scale ) ) - smoothstep( .5, .5 + thickness, cos(floor(.5+a/b)*b-a)*length(c.xy) * ( 1. / scale ) );

}
float rand( vec2 c ){
    return fract(sin(dot(c.xy,vec2(12.9898,78.233)))*43758.5453123);
}

//#define biunit
void main() {

    vec2 ratio = u_resolution.xy / max(u_resolution.x, u_resolution.y);
	#ifdef biunit
    	vec2 uv = ( 2. * ( gl_FragCoord.xy / u_resolution ) - 1. ) * ratio;
    #else
   		vec2 uv = ( gl_FragCoord.xy / u_resolution ) * ratio;
    #endif

    vec3 col = vec3(0.);

    float scale = 1.;
    vec2 f = fract( uv );

    float a = u_time * .001 * PI;
    float ca = cos( a * 2. );
    float sa = sin( a * 1.5 );
    mat2 t = mat2( ca, -sa, sa, ca );

    vec2 i = floor( uv * 100. );
    vec2 motion = vec2( sa, ca )*100.;

    float acc = 0.;
    const float count = 10.;
    for( float k = 0.; k < count; k+= 1. ){
        acc += rand( floor( t * ( motion + uv * k - vec2( k *.5 ) * ratio ) )  ) * (  k / count ) * .25;
    }
 	col = vec3( acc );

    a = 0.;
    ca = cos( a );
    sa = sin( a );
    t = mat2( ca, -sa, sa, ca );
    f -= vec2(0.5) * ratio;
    f *= t;

    float s = 0.;
    float pscale = 0.;

    a = u_time  * 1.1;
    ca = cos( a );
    sa = sin( a );
    s = 6.;
    pscale = min( ratio.x, ratio.y ) * .25 ;
 	col += vec3( poly( f, s, pscale, 0.1 ) + poly( f, s,pscale,.15 ) * ( .25 + sa * .05 ) );
    s /= 2.;
 	col += vec3( poly( f, s, pscale, 0.1 ) + poly( f, s,pscale,.15 ) * ( .25 + sa * .05 ) );
    s *= 40.;
 	col += vec3( poly( f, s, pscale * 2., 0.1 ) + poly( f, s,pscale * 2.,.5 )* ( .5 + sa * .35 ) );
    s = 4.;
 	col += vec3( poly( f, s, pscale * 2., 0.1 ) + poly( f, s,pscale * 1.,.25 ) );//  * ( .5 + sa * .75 ) );

    f += vec2(.5);
    col *= vec3( f.x, f.y, 1. );
    gl_FragColor = vec4( col, 1. );

}
// Author: Nicolas Barradeau
// Title: gooey

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
uniform float u_time;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// http://iquilezles.org/www/articles/voronoise/voronoise.htm
vec3 hash3( vec2 p ) {
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
                   dot(p,vec2(269.5,183.3)), 
                   dot(p,vec2(419.2,371.9)) );
    return fract(sin(q)*43758.5453);
}

float iqnoise( in vec2 x, float u, float v, float s ) {
    vec2 p = floor(x);
    vec2 f = fract(x);
        
    float k = 1.0+63.0*pow(1.0-v,4.0);
    
    float va = 0.0;
    float wt = 0.0;
    vec4 ret;
    for ( float j=-2.; j<=2.; j+=1.) {
        for (float i=-2.; i<=2.; i+=1.) {
            
            vec2 g = vec2(i,j);
            vec3 o = hash3(p + g)*vec3(u,u,1.0);
            vec2 r = g - f + o.xy;
            
            float d = dot(r,r);
            float ww = pow( 1.0-smoothstep(0.0,s,sqrt(d)), k );
            va += o.z*ww;
            wt += ww;
        }
    }
    return va/wt;
}
void main(){
    
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    float time = u_time;
    float si = sin( time * .1 );
    float co = cos( time * .1 );
    float n = iqnoise( ( st - vec2( 0., time*.1 ) ) * 3.5, 0.5, 0., 10.1 );

    vec2 vt = ( st - vec2( 0., time*.1 ) ) + n * ( co+si );
    float v0 = pow( iqnoise( vt * 3., 1., si, max( 0., 0.5 + si * .5 ) ), 3. );
    float v1 = pow( iqnoise( vt * 6., co, min( 1., co*si ),1.1 ), 3. );

    vec3 c = mix( mix( orange, yellow_bright, v0 ) * 1.2, mix( pink, blue, v1 ), clamp( max( v0, v1 ), 0.,1. ) * 1. );
    gl_FragColor = vec4( c,1. );

}
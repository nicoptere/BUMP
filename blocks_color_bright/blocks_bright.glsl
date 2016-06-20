// Author: Nicolas Barradeau
// Title: blocks color blright

#define PROCESSING_COLOR_SHADER
#ifdef GL_ES
    precision mediump float;
#endif
#define PI 3.14159265359

const vec3 blue				= vec3( 0.4453125, 	0.890625, 	0.890625 );
const vec3 yellow_bright	= vec3( 0.9296875, 	0.8671875, 	0.18359375 );
const vec3 yellow_dark		= vec3( 0.921875,  	0.80078125, 0.);
const vec3 orange			= vec3( 0.88671875, 0.625,		0.1171875);
const vec3 pink				= vec3( 0.92578125, 0.46484375,	0.89453125);

uniform vec2 u_resolution;
uniform vec2 u_mouse;
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
float iqnoise( in vec2 x, in float v )
{
    return iqnoise( x, .5, .5, 1.);
}
float iqnoise( in vec2 x )
{
    return iqnoise( x, 1. );
}


void main() {

    vec2 st = 2. *  gl_FragCoord.xy/u_resolution.xy - 1.;
    st.x *= u_resolution.x/u_resolution.y;
	vec2 uv = st;
    st += vec2(.0);

    vec3 color = orange;
    vec3 colors[4];
    colors[0] = pink;
    colors[1] = orange;
    colors[2] = yellow_bright;
    colors[3] = blue;

    float dir = 1.;
    float ot = ( .5 * sin( u_time ) +.5 );
    float mt = ( .5 * sin( u_time * 1.1 ) +.5 )*2.;
    float mc = ( .5 * sin( u_time * 0.2 ) +.5 );
    vec3 final = mix( mix( blue, pink, mc )*.8, mix( pink, orange, mc ), st.y );// * ( .15 + ot * .05 );
    const float total = 10.;
    for( float i = 1.; i < total; i+= 1. ){

        const float count = 4.;
    	float acc = 0.;

        float a = .1 * u_time + i * PI / 180. * ( i * 20. );
        float inv = .25 + ( ( count - i ) * .1 + sin( u_time * i * .01 ));
        vec2 p = vec2(  2.*cos( a )*inv, sin( a ) * inv );

        for( float j = 1.; j < count; j += 1. ){

            float l = 1.- length( st-p);

            float v = pow( smoothstep( .0,1., l ) * .75, 2. );

            v *= pow( iqnoise( ( uv * i * 0.5 ), mt * .5 ), 1. );
            acc += v;

        }
    	final = mix( final, colors[ int( mod( i, 4. ) ) ], acc  );

    }

    gl_FragColor = vec4( final,1.0);
    
}
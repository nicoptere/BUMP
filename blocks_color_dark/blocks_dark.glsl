// Author: Nicolas Barradeau
// Title: blocks color dark

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
uniform vec2 u_mouse;
uniform float u_time;

float random (in vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233))) * 43758.5453123);
}
void main() {

    vec2 st = 2. *  gl_FragCoord.xy/u_resolution.xy - 1.;
    st.x *= u_resolution.x/u_resolution.y;
	vec2 uv = st;
    st += vec2(.0);
    vec3 color = vec3(1.);
    color = vec3(st.x,st.y,abs(sin(u_time)));
    color = orange;

    vec3 colors[4];
    colors[0] = pink;
    colors[1] = orange;
    colors[2] = yellow_bright;
    colors[3] = blue;

    float ot = ( .5 * sin( u_time ) +.5 );
    float mt = ( .5 * sin( u_time * 0.1 ) +.5 )*2.;
    float mc = ( .5 * sin( u_time * 0.2 ) +.5 );
    vec3 final = blue * ( .15 + ot * .05 );
    const float total = 10.;
    for( float i = 1.; i < total; i+= 1. ){

        const float count = 5.;
    	float acc = 0.;
        for( float j = 1.; j < count; j += 1. ){

            float a = .1 * u_time + i * PI / 180. * ( j * 40. + i * 20. );

            float inv = .25 + abs( ( count - i ) * .1 + sin( u_time * i * .01 ));

            vec2 p = vec2(  2.*cos( a )*inv, sin( a ) * inv );

            float l = 1.- length( st-p);

            float v = pow( smoothstep( .0,1., l ) * 0.85, 4. );

            v *= pow( random( floor( uv * (mt+j*1.5) + p ) ), 2.+mt*3. ) + smoothstep( .99,1.0, l  );
            acc += v;

        }
    	final = mix( final, colors[ int( mod( i, 4. ) ) ], acc  );

    }

    gl_FragColor = vec4( final,1.0);

}
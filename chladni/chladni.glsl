// Author: Nicolas Barradeau
// Title: Chladni patterns

#ifdef GL_ES
precision mediump float;
#endif
#define PROCESSING_COLOR_SHADER

vec3 blue				= vec3( 0.4453125, 	0.890625, 	0.890625 );
vec3 yellow_bright		= vec3( 0.9296875, 	0.8671875, 	0.18359375 );
vec3 yellow_dark		= vec3( 0.921875,  	0.80078125, 0.);
vec3 orange				= vec3( 0.88671875, 0.625,		0.1171875);
vec3 pink				= vec3( 0.92578125, 0.46484375,	0.89453125);

    
#define PI 3.1415926535897932384626433832795
const float GR = 1.61803399;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


void main() {

    vec3 colors[5];
	colors[0] = blue;
	colors[1] = yellow_bright;
	colors[2] = yellow_dark;
	colors[3] = orange;
	colors[4] = pink;

    vec2 st = ( 2. * gl_FragCoord.xy - u_resolution ) / max( u_resolution.x, u_resolution.y ) ;
    float iteration = 20. + smoothstep( -1., 1., sin( PI * 2. * ( u_time * 0.1 ) ) ) * 20.;
    
    float an = u_time * PI * 2. * .1;
    st += vec2( cos( an / GR ), sin( an * GR ) );
    
    float sqi = ( abs(sin( u_time * 0.1 *  PI * 2. ) ) );
    float a = sqi * sin( u_time * 0.01 );
    float b = sqi * cos( u_time * 0.005 );
    
    vec2 t = vec2( cos( an ) * .25, sin( an ) * .25 );
    for( float i = 1.; i < 4.; i+= 1.  ){
        
        mat2 m = mat2( 	cos( a * i * PI * st.x ), 
                        cos( b * i * PI * st.y ), 
                    	-cos( b * i * PI * st.x ), 
                        cos( a * i * PI * st.y ) );
        st += t * m * i;
    }
    
    float len = length( st );
    
    vec3 color = mix( blue, yellow_bright, smoothstep( 0.5, 0.51, len ) );
    color = mix( color, yellow_dark, smoothstep( 0.75, 0.76, len ) );
    color = mix( color, orange, smoothstep( 1.5, 1.51, len ) );
    color = mix( color, pink, smoothstep( 1.75, 1.751, len ) );
    gl_FragColor = vec4(color,1.0);
    
}
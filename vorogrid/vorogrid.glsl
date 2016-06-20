// Author: Nicolas Barradeau
// Title: vorogrid

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

float sdPlane( vec3 p ) { return p.y; }

float sdSphere( vec3 p, float s ) { return length(p)-s; }

float sdBox( vec3 p, vec3 b ) { vec3 d = abs(p) - b; return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)); }

float opS( float d1, float d2 ) { return max(-d2,d1); }

vec2 opU( vec2 d1, vec2 d2 ) { return (d1.x<d2.x) ? d1 : d2; }

vec3 opRep( vec3 p, vec3 c ) { return mod(p,c)-0.5*c; }

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
float snoise(vec2 v){
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod289(i);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c            );
}
float seed = 0.;
float rand(float n){
    
    return fract( sin( seed + n * 43758.5453123 ) );
}
vec2 rand2(in vec2 p){
	return fract(vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

float seednoise(float p)
{
	float fl = floor(p);
	float fc = fract(p );
    return mix(rand( fl + seed ), rand(fl  + seed+ 1.0), fc);
}

float noise(float p)
{
	float fl = floor(p);
	float fc = fract(p );
    return mix(rand( fl ), rand(fl + 1.0), fc);
}

float cube( in vec3 p, in vec3 b, in float t ) {
	return  opS( opS( opS( sdBox( p, b ), sdBox( p, vec3(b.x*2., b.y*t, b.z*t) ) ), sdBox( p, vec3(b.x*t, b.y*2., b.z*t) ) ), sdBox( p, vec3(b.x*t, b.y*t, b.z *2. ) ) );
}
float hollowSphere( in vec3 p, in float outerRadius, in float thickness ) {
    return opS(  sdSphere( p, outerRadius ), sdSphere( p, outerRadius * ( 1. - thickness ) ) );
}

vec2 map( in vec3 pos ){
    vec2 res = vec2( 0.);

    const float count_i = 2., count_j = 2. , count_k = 2.;
    float noise_i = 2., noise_j = 2. , noise_k = 2.;
    float multi = 1.;
    vec3 pfloor = floor( pos * multi );
    vec3 pfract = fract( pos * multi );
    float dist = 0.;

    seed = abs( snoise( vec2( u_time * .01 ) ) ) * .0001;
    pos *= rotationMatrix( vec3( 1.,0.,0. ), u_time * .1 );

    vec3 c = vec3(.0);
    vec3 tg = pos;
    vec3 origin = tg;
    float sq = .75;
    res = vec2( sdSphere( pos, .75) , 2.) ;
    for( float i = -1.; i < count_i; i += 1. ){

        for( float j = -1.; j < count_j; j += 1. ){

            for( float k = -1.; k < count_k; k += 1. ){
                vec3 cell = pos - vec3( i, j, k );
                vec3 tg = cell + normalize( vec3( seednoise( i+j ), seednoise( j+k ), seednoise( k+i ) ) )-.5;
                dist = distance( pos, tg );
                res = vec2( opS( res.x, sdSphere( tg, dist * sq ) ), sqrt( dist ) );
            }
        }
    }
    return res;
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.1;
    float tmax = 50.0;
	float precis = 0.0001;
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<100; i++ )
    {
	    vec2 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x;
	    m = res.y;
    }
    if( t>tmax ) m=-1.0;
    return vec2( t, m );
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

vec3 render( in vec3 ro, in vec3 rd, in vec2 uv )
{
    float n = snoise( vec2( uv.x * .2 + sin( u_time * 0.01 ), uv.y * .2 + sin(u_time * 0.01) ) );
    vec3 col = blue * .35 + rd.y + ( pow( n, 2. )  ) * .8;
    vec2 res = castRay(ro,rd);
    float t = res.x;
	float m = res.y;
    if( m>-0.5 )
    {
   	 	vec3 pos = ro + rd * t;
        vec3 n = calcNormal(pos);
        vec3 ref = reflect( rd, n );
        vec3 diffColor = orange;

    	vec3 lightPos = ( vec3( -1., -.700, 3.0) );
    	vec3 l = normalize(pos-lightPos );
    	float diffStrength = max( pow( dot(n, l), 32. ), 0.0 );
        vec3 ambientColor = blue * clamp( 0.005 + .35 * ref.y, 0.0, 1.0);
    	col = ( diffStrength * diffColor + ambientColor );

    }
	return vec3( clamp(col,0.0,1.0) );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void main()
{
	vec2 q = gl_FragCoord.xy/u_resolution.xy;
    vec2 p = 2.0*q-1.;
	p.x *= u_resolution.x/u_resolution.y;

	vec3 ro = vec3( 0.,0.,-2. );
	vec3 ta = vec3( 2./3., 0., 0.);
    mat3 ca = setCamera( ro, ta, 0.0 );
	vec3 rd = ca * normalize( vec3(p.xy, 2.5 ) );
    vec3 col = render( ro, rd, q );

    gl_FragColor=vec4( col, 1.0 );
}
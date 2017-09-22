varying vec4 vertColor;

uniform float fogNear;
uniform float fogFar;

uniform float _Time;


void main(){
    gl_FragColor = vertColor;
    float normalizedCosTime = (cos(_Time)+1.0/2.0);
    // fogNear = normalizedCosTime * 700;
    // fogFar = normalizedCosTime * 1.5 * 600;
    
    vec3 fogColor =  vec3(0.0,0.0,0.0);
    float depth = gl_FragCoord.z / gl_FragCoord.w;
    float fogFactor = smoothstep(fogNear, fogFar, depth);
    gl_FragColor = mix(gl_FragColor, vec4(fogColor, gl_FragColor.w), fogFactor);
}
uniform vec3 uColorDeepth;
uniform vec3 uColorSurface;

uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vElevation;


void main() {
    float mixStrength = (vElevation + uColorOffset) * uColorMultiplier;
    // mixStrength = smoothstep(0.0, 1.0, mixStrength);
    vec3 color = mix(uColorDeepth, uColorSurface, mixStrength);

    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
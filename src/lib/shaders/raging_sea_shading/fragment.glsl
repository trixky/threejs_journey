uniform vec3 uColorDeepth;
uniform vec3 uColorSurface;

uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vElevation;
varying vec3 vNormal;
varying vec3 vPosition;

#include ../light/includes/point_light.glsl

void main() {
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);

    // Base color
    float mixStrength = (vElevation + uColorOffset) * uColorMultiplier;
    mixStrength = smoothstep(0.0, 1.0, mixStrength);
    vec3 color = mix(uColorDeepth, uColorSurface, mixStrength);

    // Light
    vec3 light = vec3(0.0);
    light += pointLight(vec3(1.0), 10.0, normal, vec3(0., 0.25, 0.), viewDirection, 30.0, vPosition, 0.95);
    color *= light;

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
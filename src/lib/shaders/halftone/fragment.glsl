uniform vec3 uColor;
uniform vec2 uResolution;
uniform float uShadowRepetition;
uniform vec3 uShadowColor;
uniform float uLightRepetition;
uniform vec3 uLightColor;

varying vec3 vNormal;
varying vec3 vPosition;

#include ../light/includes/ambiant_light.glsl
#include ../light/includes/directional_light.glsl

vec3 halftone(vec3 color, float repetitions, vec3 direction, float low, float high, vec3 pointColor, vec3 normal) {
    float intensity = dot(normal, direction);
    intensity = smoothstep(low, high, intensity);

    vec2 uv = gl_FragCoord.xy / uResolution.y; // can divide vec2 by float
    // chose to divide by y because it's the smallest and three.js uses y as default
    // gl_FragCoord is coordinates of the pixels
    uv *= repetitions;
    uv = mod(uv, 1.0);
    float point = distance(uv, vec2(0.5));
    point = step(point, 0.5 * intensity); // intensity is the radius of the circle

    color = mix(color, pointColor, point);

    return color;
}

void main() {
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = uColor;

    // Lights
    vec3 light = vec3(0.0, 0.0, 0.0);
    light += ambiantLight(vec3(1.), 1.0);
    light += directionalLight(vec3(1.), 1., normal, vec3(1.), viewDirection, 1.0);
    color *= light;

    // Halftone
    color = halftone(color, uShadowRepetition, vec3(0.0, -1.0, 0.0), -0.8, 1.5, uShadowColor, normal);
    color = halftone(color, uLightRepetition, vec3(1.0, 1.0, 0.0), 0.5, 1.5, uLightColor, normal);

    // Final color
    gl_FragColor = vec4(color, 1.0);
    // gl_FragColor = vec4(uv, 1.0, 1.0);
    // gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
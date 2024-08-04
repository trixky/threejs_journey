#include ./rotate2d.glsl
// include for the vite

varying vec2 vUv;

uniform sampler2D uPerlin;
uniform float uTime;
uniform float uWindStrength;
uniform float uWindSpeed;

void main() {
    vec3 newPosition = position;

    // Twist
    float twistPerlin = texture(uPerlin, vec2(0.5, uv.y * 0.2 - uTime * 0.01)).r;
    float angle = twistPerlin * 10.;
    newPosition.xz = rotate2D(newPosition.xz, angle);

    // Wind
    vec2 windOffset = vec2(
        texture(uPerlin, vec2(0.25, uTime * uWindSpeed)).r - 0.5,
        texture(uPerlin, vec2(0.75, uTime * (uWindSpeed + 0.01))).r - 0.5
    );
    windOffset *= uWindStrength * pow(uv.y, 2.0);
    newPosition.xy += windOffset;

    // Final position
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
    vUv = uv;
}
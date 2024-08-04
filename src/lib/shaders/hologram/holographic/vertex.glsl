uniform float uTime;
uniform float uGlitchStrength;
uniform float uGlitchSpeed;
uniform float uGlitchSharpness;

varying vec3 vPosition;
varying vec3 vNormal;

#include ./random2d.glsl

void main() {
    // Position
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    // The 1.0 is for the homogeneous coordinate (apply translation)

    // Glitch
    float glitchTime = (uTime * uGlitchSpeed - modelPosition.y);
    float glitchStrength = sin(glitchTime) + sin(glitchTime * 3.45) + sin(glitchTime * 8.76);
    glitchStrength *= .3;
    glitchStrength = smoothstep(uGlitchSharpness, 1.0, glitchStrength);
    glitchStrength *= uGlitchStrength;
    modelPosition.x += (random2D(vec2(modelPosition.xz * uTime)) - 0.5) * glitchStrength;
    modelPosition.z += (random2D(vec2(modelPosition.zx * uTime)) - 0.5) * glitchStrength;
    // remove 0.5 because the random2D return a value between 0 and 1

    gl_Position = projectionMatrix * viewMatrix * modelPosition;

    // Model normal
    vec4 modelNormal = modelMatrix * vec4(normal, 0.0);
    // set 0.0 for the homogeneous coordinate (no translation)

    // Varying
    // vPosition = position.xyz; // follow the vertex position and rotation
    vPosition = modelPosition.xyz;
    vNormal = modelNormal.xyz;
}
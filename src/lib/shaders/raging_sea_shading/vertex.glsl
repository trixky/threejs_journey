uniform float uTime;
uniform float uSpeed;
uniform float uElevation;
uniform vec2 uFrequencies;

uniform float uChaosElevation;
uniform float uChaosFrequency;
uniform float uChaosSpeed;
uniform float uChaosIterations;

varying float vElevation;
varying vec3 vNormal;
varying vec3 vPosition;

#include ./includes/perlin_classic_3D.glsl

float waveElevation(vec3 position) {
    float elevation = sin(position.x * uFrequencies.x + uTime * uSpeed) *
        sin(position.z * uFrequencies.y + uTime * uSpeed) * uElevation;

    for(float i = 1.0; i <= uChaosIterations; i++) {
        elevation -= abs(perlinClassic3D(vec3(position.xz * uChaosFrequency * i, uTime * uChaosSpeed)) * (uChaosElevation / i));
    }

    return elevation;
}

void main() {
    // Base position
    float shift = 0.01;
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    vec3 modelPositionA = modelPosition.xyz + vec3(shift, 0.0, 0.0);
    vec3 modelPositionB = modelPosition.xyz + vec3(0.0, 0.0, - shift);

    // Elevation
    float elevation = waveElevation(modelPosition.xyz);
    modelPosition.y += elevation;
    modelPositionA.y += waveElevation(modelPositionA);
    modelPositionB.y += waveElevation(modelPositionB);

    // Compute normals
    vec3 toA = normalize(modelPositionA - modelPosition.xyz);
    vec3 toB = normalize(modelPositionB - modelPosition.xyz);
    vec3 computeNormal = cross(toA, toB); // cross product give us the normal

    // Final position
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedMatrix = projectionMatrix * viewPosition;
    gl_Position = projectedMatrix;

    // Varying
    vElevation = elevation;
    // vNormal = (modelMatrix * vec4(normal, 0.0)).xyz;
    vNormal = computeNormal;

    vPosition = modelPosition.xyz;
}
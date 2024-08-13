// varying vec2 vUv; // for test 1
varying float vWobble;

attribute vec4 tangent; // thanks to computeTangents in three.js

uniform float uTime;
// --------- wobble
uniform float uPositionFrequency;
uniform float uTimeFrequency;
uniform float uStrength;
// --------- warp
uniform float uWarpPositionFrequency;
uniform float uWarpTimeFrequency;
uniform float uWarpStrength;

#include ../simplexNoise4d.glsl

float getWobble(vec3 position) {
    vec3 warpedPosition = position;
    warpedPosition += simplexNoise4d(vec4(position * uWarpPositionFrequency, uTime * uWarpTimeFrequency)) * uWarpStrength;

    return simplexNoise4d(vec4(warpedPosition * uPositionFrequency,   //XYZ
    uTime * uTimeFrequency       //W
    )) * uStrength;
}

void main() {
    // https://github.com/FarazzShaikh/THREE-CustomShaderMaterial?tab=readme-ov-file#output-variables

    // ----- test 1
    // csm_Position.y += sin(csm_Position.x * 3.) * 0.5;

    // --------------------
    vec3 bigTangent = cross(normal, tangent.xyz);

    // Neighboor positions
    float shift = 0.01;
    vec3 positionA = csm_Position + shift * tangent.xyz;
    vec3 positionB = csm_Position + shift * bigTangent;

    // Wobble
    float wobble = getWobble(csm_Position);
    csm_Position += wobble * normal;
    positionA += getWobble(positionA) * normal;
    positionB += getWobble(positionB) * normal;

    // Compute normal
    vec3 toA = normalize(positionA - csm_Position);
    vec3 toB = normalize(positionB - csm_Position);
    csm_Normal = cross(toA, toB); // Update the normal for shadow mapping

    // Varying
    // vUv = uv;
    vWobble = wobble / uStrength;
}
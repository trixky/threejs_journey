#include ./simplexNoise2d.glsl

#define timeSpeed 0.2;

uniform float uTime;
uniform float uPositionFrequency;
uniform float uStrength;
uniform float uWarpFrequency;
uniform float uWarpStrength;

varying vec3 vPosition;
varying float vUpDot;

float getElevation(vec2 position) {

    vec2 warpPosition = position;
    warpPosition += uTime * timeSpeed;

    warpPosition += simplexNoise2d(warpPosition * uPositionFrequency * uWarpFrequency) * uWarpStrength;

    float elevation = 0.0;
    elevation += simplexNoise2d(warpPosition * uPositionFrequency) / 2.;
    elevation += simplexNoise2d(warpPosition * uPositionFrequency * 2.0) / 4.;
    elevation += simplexNoise2d(warpPosition * uPositionFrequency * 4.0) / 8.;

    float elevationSign = sign(elevation);
    elevation = pow(elevation, 2.0) * elevationSign;
    elevation *= uStrength;

    return elevation;
}

void main() {
    // Neighbours positions
    float shift = 0.01;
    vec3 PositionA = position + vec3(shift, 0.0, 0.0);
    vec3 PositionB = position + vec3(0.0, 0.0, -shift);

    // Elevation
    float elevation = getElevation(csm_Position.xz);
    csm_Position.y = elevation;
    PositionA.y = getElevation(PositionA.xz);
    PositionB.y = getElevation(PositionB.xz);

    // Normal
    vec3 toA = normalize(PositionA - csm_Position);
    vec3 toB = normalize(PositionB - csm_Position);
    csm_Normal = cross(toA, toB);

    vPosition = csm_Position;
    vPosition.xz += uTime * timeSpeed;
    vUpDot = dot(csm_Normal, vec3(0.0, 1.0, 0.0));
}
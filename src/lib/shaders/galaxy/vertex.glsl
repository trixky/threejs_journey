uniform float uTime;
uniform float uSize;

attribute float aScale;
attribute vec3 aRandomness;

varying vec3 vColor;

void main() {
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);

    float angle = atan(modelPosition.y, modelPosition.x); // Because it's in the center of the scene
    float radius = length(modelPosition.xz); // Because it's in the center of the scene
    float angleOffset = (1.0 / radius) * uTime * 0.2;
    angle += angleOffset;
    modelPosition.x = cos(angle) * radius;
    modelPosition.z = sin(angle) * radius;

    // Randomness
    // modelPosition.x += aRandomness.x;
    // modelPosition.y += aRandomness.y;
    // modelPosition.z += aRandomness.z;
    modelPosition.xyz += aRandomness;
    // modelPosition += vec4(aRandomness, 0.0);

    // modelPosition.y += uTime;
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;

    gl_Position = projectedPosition;
    gl_PointSize = uSize * aScale;
    gl_PointSize *= (1.0 / -viewPosition.z);

    vColor = color;
}
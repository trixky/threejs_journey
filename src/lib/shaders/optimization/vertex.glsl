// #define uDisplacementStrength 1.5;

uniform sampler2D uDisplacementTexture;
uniform float uTime;

// varying vec2 vUv;
varying vec3 vColor;

void main() {
    // Position
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    float elevation = texture2D(uDisplacementTexture, uv).r;
    elevation = max(elevation, 0.5);
    // elevation = clamp(elevation, 0.5, 1.0);
    // if(elevation < 0.5) {
    //     elevation = 0.5;
    // }
    modelPosition.y += elevation * uDisplacementStrength;
    modelPosition.y += sin(uTime + modelPosition.x + modelPosition.z) * 0.3;
    gl_Position = projectionMatrix * viewMatrix * modelPosition;

    // Color
    float colorElevation = max(elevation, 0.25);
    vec3 depthColor = vec3(1.0, 0.1, 0.1);
    vec3 surfaceColor = vec3(0.1, 0.0, 0.5);
    vec3 finalColor = mix(depthColor, surfaceColor, colorElevation);

    // vUv = uv;
    vColor = finalColor;
}
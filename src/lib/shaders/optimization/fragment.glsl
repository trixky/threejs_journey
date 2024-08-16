// uniform sampler2D uDisplacementTexture;

// varying vec2 vUv;
varying vec3 vColor;

void main() {
    // float elevation = texture2D(uDisplacementTexture, vUv).r;
    // elevation = max(elevation, 0.25);
    // if(elevation < 0.25) { // remove
    //     elevation = 0.25; // remove
    // } // remove

    // vec3 depthColor = vec3(1.0, 0.1, 0.1);
    // vec3 surfaceColor = vec3(0.1, 0.0, 0.5);
    // vec3 finalColor = vec3(0.0); // remove
    // finalColor.r += depthColor.r + (surfaceColor.r - depthColor.r) * elevation; // remove
    // finalColor.g += depthColor.g + (surfaceColor.g - depthColor.g) * elevation; // remove
    // finalColor.b += depthColor.b + (surfaceColor.b - depthColor.b) * elevation; // remove
    // vec3 finalColor = mix(depthColor, surfaceColor, elevation);

    gl_FragColor = vec4(vColor, 1.0);
}
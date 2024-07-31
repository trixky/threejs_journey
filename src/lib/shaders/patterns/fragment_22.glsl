varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float gradX = floor(vUv.x * 10.0) / 10.0; // round / ceil / floor
    float gradY = floor(vUv.y * 10.0) / 10.0; // round / ceil / floor

    float gradXY = gradX * gradY;

    vec3 grad3 = vec3(gradXY);

    gl_FragColor = vec4(grad3, 1.0);
}
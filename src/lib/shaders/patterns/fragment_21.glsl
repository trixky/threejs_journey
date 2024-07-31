varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    // float grad = float(int(vUv.x * 10.0)) / 10.0;
    float grad = floor(vUv.x * 10.0) / 10.0; // round / ceil / floor

    vec3 grad3 = vec3(grad);

    gl_FragColor = vec4(grad3, 1.0);
}
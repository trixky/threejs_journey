varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float grad = distance(vUv, vec2(0.5, 0.5));
    float gradAbs = abs(grad - 0.25);
    float gradAbsStep = step(0.01, gradAbs );

    vec3 grad3 = vec3(gradAbsStep);

    gl_FragColor = vec4(grad3, 1.0);
}
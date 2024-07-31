varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    // float grad = (1.0 - vUv.x) * (1.0 - vUv.y);
    // float gradReverse = 1.0 - grad;

    float grad = length(vUv);

    vec3 grad3 = vec3(grad);

    gl_FragColor = vec4(grad3, 1.0);
}
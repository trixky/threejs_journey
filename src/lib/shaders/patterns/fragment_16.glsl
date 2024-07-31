varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    vec3 grad = vec3(abs(vUv.x - 0.5));

    gl_FragColor = vec4(grad, 1.0);
}
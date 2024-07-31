varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float angle = atan(vUv.x, vUv.y);

    vec3 grad3 = vec3(angle);

    gl_FragColor = vec4(grad3, 1.0);
}
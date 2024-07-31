varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    // gl_FragColor = vec4(vUv.x, vUv.y, 1.0, 1.0);
    vec3 strengthX = vec3(vUv.x);
    gl_FragColor = vec4(strengthX, 1.0);
}
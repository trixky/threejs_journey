varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    // gl_FragColor = vec4(vUv.x, vUv.y, 1.0, 1.0);
    vec3 strengthY = vec3(vUv.y);
    gl_FragColor = vec4(strengthY, 1.0);
}
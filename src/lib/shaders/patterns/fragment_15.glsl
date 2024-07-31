varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float barX = step(0.4, mod(vUv.x * 10.0, 1.0));
    barX *= step(0.8, mod(vUv.y * 10.0 + 0.2, 1.0));

    float barY = step(0.4, mod(vUv.y * 10.0, 1.0));
    barY *= step(0.8, mod(vUv.x * 10.0 + 0.2, 1.0));

    vec3 barXY = vec3(barX + barY);

    gl_FragColor = vec4(barXY, 1.0);
}
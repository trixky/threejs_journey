varying vec2 vUv; // Let's give uv to the fragment shader

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    float gradX = floor(vUv.x * 10.0) / 10.0; // round / ceil / floor
    float gradY = floor(vUv.y * 10.0) / 10.0; // round / ceil / floor

    vec2 gradXY = vec2(gradX, gradY);

    float random = random(gradXY);

    vec3 grad3 = vec3(random);

    gl_FragColor = vec4(grad3, 1.0);
}
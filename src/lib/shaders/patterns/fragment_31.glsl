varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    vec2 stretchVUvX = vec2(vUv.x * 0.1 + 0.45, vUv.y * 0.5 + 0.25);
    vec2 stretchVUvY = vec2(vUv.y * 0.1 + 0.45, vUv.x * 0.5 + 0.25);
    float gradX = 0.015 / length(stretchVUvX - 0.5);
    float gradY = 0.015 / length(stretchVUvY - 0.5);
    float gradXY = gradX * gradY;
    float gradReversePoint =  gradXY;

    vec3 grad3 = vec3(gradReversePoint);

    gl_FragColor = vec4(grad3, 1.0);
}
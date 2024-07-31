varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    // float grad = (1.0 - vUv.x) * (1.0 - vUv.y);
    // float gradReverse = 1.0 - grad;

    // vec2 center = vec2(0.5, 0.5);
    // float grad = distance(vUv, center);
    float grad = length(vUv - 0.5);
    // float gradReverse = 1.0 - grad;
    // float gradReversePow = pow(gradReverse, 10.0);
    float gradReversePoint = 0.015 / grad;

    vec3 grad3 = vec3(gradReversePoint);

    gl_FragColor = vec4(grad3, 1.0);
}
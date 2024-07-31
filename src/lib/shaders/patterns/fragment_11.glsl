varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float strengthXInverse = vUv.x * 10.0;
    float strengthXInverseModulo = mod(strengthXInverse, 1.0);
    float strengthXInverseModuloStep = step(0.8, strengthXInverseModulo);

    float strengthYInverse = vUv.y * 10.0;
    float strengthYInverseModulo = mod(strengthYInverse, 1.0);
    float strengthYInverseModuloStep = step(0.8, strengthYInverseModulo);


    vec3 strengthXYInverse3 = vec3(strengthXInverseModuloStep + strengthYInverseModuloStep);

    gl_FragColor = vec4(strengthXYInverse3, 1.0);
}
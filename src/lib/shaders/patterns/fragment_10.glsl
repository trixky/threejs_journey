varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float strengthXInverse = vUv.x * 10.0;
    float strengthXInverseModulo = mod(strengthXInverse, 1.0);

    // if (strengthXInverseModulo < 0.5)
    //     strengthXInverseModulo = 0.0;
    // else
    //     strengthXInverseModulo = 1.0;

    // strengthXInverseModulo = strengthXInverseModulo < 0.5 ? 0.0 : 1.0;

    // Classic conditions are bad for performance

    float strengthXInverseModuloStep = step(0.8, strengthXInverseModulo);

    vec3 strengthXInverse3 = vec3(strengthXInverseModuloStep);


    gl_FragColor = vec4(strengthXInverse3, 1.0);
}
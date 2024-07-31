varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float strengthYInverse = vUv.y * 10.0;
    float strengthYInverseModulo = mod(strengthYInverse, 1.0);

    // if (strengthYInverseModulo < 0.5)
    //     strengthYInverseModulo = 0.0;
    // else
    //     strengthYInverseModulo = 1.0;

    // strengthYInverseModulo = strengthYInverseModulo < 0.5 ? 0.0 : 1.0;

    // Classic conditions are bad for performance

    float strengthYInverseModuloStep = step(0.8, strengthYInverseModulo);

    vec3 strengthYInverse3 = vec3(strengthYInverseModuloStep);


    gl_FragColor = vec4(strengthYInverse3, 1.0);
}
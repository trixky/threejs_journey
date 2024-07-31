varying vec2 vUv; // Let's give uv to the fragment shader

#define PI 3.14159265359

void main() {
// ------- star
    float angle = atan(vUv.x - 0.5, vUv.y - 0.5);
    float angle2PI = angle / (PI * 2.0);
    float angle2PIShifted = angle2PI + 0.5;
    float angle2PIShiftedSin = sin(angle2PIShifted * 100.0);
// ------- cercle
    float radius = 0.25 + angle2PIShiftedSin * 0.02;
    float grad = distance(vUv, vec2(0.5, 0.5));
    float gradAbs = abs(grad - radius);
    float gradAbsStep = step(0.01, gradAbs);
    float gradAbsStepReverse = 1.0 - gradAbsStep;


    vec3 grad3 = vec3(gradAbsStepReverse);

    gl_FragColor = vec4(grad3, 1.0);
}
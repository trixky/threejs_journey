varying vec2 vUv; // Let's give uv to the fragment shader

#define PI 3.14159265359

void main() {
    float angle = atan(vUv.x - 0.5, vUv.y - 0.5) ;
    float angle2PI = angle / (PI * 2.0);
    float angle2PIShifted = angle2PI + 0.5;
    float angle2PIShiftedMod = mod(angle2PIShifted * 20.0, 1.0);

    vec3 grad3 = vec3(angle2PIShiftedMod);

    gl_FragColor = vec4(grad3, 1.0);
}
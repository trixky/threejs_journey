varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float gradX = abs(vUv.x - 0.5);
    float gradY = abs(vUv.y - 0.5);
    float gradMaxXY = max(gradX, gradY);
    float gradMinXYstep1 = step(0.2, gradMaxXY);
    float gradMinXYstep2 = step(gradMaxXY, 0.3);

    vec3 gradMinXYstep3 = vec3(gradMinXYstep1 * gradMinXYstep2);

    gl_FragColor = vec4(gradMinXYstep3, 1.0);
}
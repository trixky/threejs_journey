varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    float gradX = abs(vUv.x - 0.5);
    float gradY = abs(vUv.y - 0.5);
    float gradMaxXY = max(gradX, gradY);
    float gradMinXYstep = step(0.2, gradMaxXY);

    vec3 gradMinXYstep3 = vec3(gradMinXYstep);

    gl_FragColor = vec4(gradMinXYstep3, 1.0);
}
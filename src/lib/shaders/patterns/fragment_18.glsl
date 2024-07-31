varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    vec3 gradX= vec3(abs(vUv.x - 0.5));
    vec3 gradY = vec3(abs(vUv.y - 0.5));
    vec3 gradMaxXY = max(gradX, gradY);

    gl_FragColor = vec4( gradMaxXY, 1.0);
}
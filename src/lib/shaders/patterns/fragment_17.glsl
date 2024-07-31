varying vec2 vUv; // Let's give uv to the fragment shader

void main() {
    vec3 gradX= vec3(abs(vUv.x - 0.5));
    vec3 gradY = vec3(abs(vUv.y - 0.5));
    vec3 gradMinXY = min(gradX, gradY);

    gl_FragColor = vec4( gradMinXY, 1.0);
}
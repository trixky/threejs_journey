varying vec2 vUv; // Let's give uv to the fragment shader

void main()
{
    // gl_FragColor = vec4(vUv.x, vUv.y, 1.0, 1.0);
    gl_FragColor = vec4(vUv, 0.5, 1.0);
}
precision mediump float;
// mediump: 16-bit floating point
// highp: 32-bit floating point (can have performance issues and might not be supported on all devices)
// lowp: 8-bit floating point (can create bugs by lack of precision)

// attribute float aRandom; // this is not possible in fragment shader
// you can't pass data from three.js to the fragment shader
// you can only pass data from vertex shader to fragment shader

varying float vRandom; // this is the way to pass data from vertex shader to fragment shader

void main() {
    // gl_FragColor is the output color (already exists like gl_Position)
    // gl_FragColor vec4 is the color (r, g, b, a)
    // a work only if transparency is enabled in three.js (.transparent = true)
    gl_FragColor = vec4(0.5, vRandom, 1.0, 0.8);

    // the fragment between two vertex is interpolated (mix between two vertex)
}

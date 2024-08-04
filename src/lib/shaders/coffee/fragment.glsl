uniform sampler2D uPerlin;
uniform float uTime;
uniform vec3 uColor;
uniform float uSpeed;

varying vec2 vUv;

void main() {
    vec2 smokeUv = vUv;
    smokeUv.x *= 0.5;
    smokeUv.y *= 0.3;
    smokeUv.y -= uTime * uSpeed;
    // repeat the texture in three.js

    float smoke = texture(uPerlin, smokeUv).r;
    smoke = smoothstep(0.4, 1.0, smoke);

    // smoke = 1.0;
    smoke *= smoothstep(0.0, 0.1, vUv.x);
    smoke *= smoothstep(1.0, 0.9, vUv.x);
    smoke *= smoothstep(0.0, 0.1, vUv.y);
    smoke *= smoothstep(1.0, 0.4, vUv.y);

    // Final color
    // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); // Active the transparency in three.js
    gl_FragColor = vec4(uColor, smoke); // Active the transparency in three.js

    #include <tonemapping_fragment>
    // use for tonemapping in three.js
    #include <colorspace_fragment>
    // use for colorspace in three.js
}
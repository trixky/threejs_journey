varying vec2 vUv;
uniform sampler2D tDiffuse;
uniform vec3 uTint;
uniform float uColorAlpha;
uniform float uColorOverride;

void main() {
    vec4 color = texture2D(tDiffuse, vUv);

    vec3 newColor = color.rgb;
    newColor += uTint * uColorAlpha;
    newColor = mix(newColor, uTint, uColorOverride);
    color = vec4(newColor, 1.0);

    gl_FragColor = vec4(color);
}
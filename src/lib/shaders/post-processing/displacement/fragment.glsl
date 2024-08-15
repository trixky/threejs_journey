varying vec2 vUv;
uniform sampler2D tDiffuse;
uniform float uTime;

uniform float uSpeed;
uniform float uXAmplitude;
uniform float uYAmplitude;
uniform float uXFrequency;
uniform float uYFrequency;

void main() {
    vec2 newVUv = vUv;
    newVUv = vec2(vUv.x + sin((vUv.y + uTime * uSpeed * 0.5 * uXFrequency) * 30.0) * 0.02 * uXAmplitude, vUv.y + cos((vUv.x + uTime * uSpeed * 0.5 * uYFrequency) * 30.0) * 0.02 * uYAmplitude);

    vec4 color = texture2D(tDiffuse, newVUv);

    gl_FragColor = vec4(color);
}
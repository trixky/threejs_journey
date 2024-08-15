varying vec2 vUv;
uniform sampler2D tDiffuse;
uniform sampler2D uNormal;
uniform float uNormalStrength;
uniform float uBrightnessStrength;

void main() {
    vec2 newVUv = vUv;
    float lightness = 0.0;

    vec3 normalColor = texture2D(uNormal, vUv).xyz * 2.0 - 1.0;
    newVUv += normalColor.xy * uNormalStrength;
    vec3 lightDirection = normalize(vec3(-1.0, 1.0, 0.0));
    lightness = clamp(dot(normalize(normalColor), lightDirection), 0.0, 1.0);

    vec4 color = texture2D(tDiffuse, newVUv) + lightness * uBrightnessStrength;

    gl_FragColor = vec4(color);
}
// varying vec2 vUv;
varying float vWobble;

uniform vec3 uColorA;
uniform vec3 uColorB;

uniform float uMetalness;
uniform float uRoughness;

void main() {
    // https://github.com/FarazzShaikh/THREE-CustomShaderMaterial?tab=readme-ov-file#output-variables

    // ----- test 1
    // csm_FragColor.rgb = vec3(1., .5, .5); // Override the gl_FragColor;
    // csm_DiffuseColor.rgb = vec3(vUv, .5);
    // ----- test 2
    // csm_Metalness = step(0.0, sin(vUv.x * 100. + 0.5)); // 0.5 remove the bad effect
    // csm_Roughness = 1. - csm_Metalness;

    float colorMix = smoothstep(-1.0, 1.0, vWobble);
    csm_DiffuseColor.rgb = mix(uColorA, uColorB, colorMix);

    // Mirror step
    float metalness = step(0.5, mod(vWobble * 10., 1.));
    float roughness = 1. - metalness;

    csm_Metalness = metalness * uMetalness;
    csm_Roughness = roughness * uRoughness;
}
// Don't use attribute vec2 uv because is already defined in three.js with
// ShaderMaterial and it will throw an error. (it's not RawShaderMaterial)
// attribute vec2 uv;

varying vec2 vUv; // Let's give uv to the fragment shader

void main()
{
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    vUv = uv; // Let's give uv to the fragment shader
}
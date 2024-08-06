varying vec3 vNormal;
varying vec3 vPosition;

void main()
{
    // Position
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    gl_Position = projectionMatrix * viewMatrix * modelPosition;

    // Model normal
    vec4 modelNormal = modelMatrix * vec4(normal, 0.0);
    // 0.0 because is homogeneous coordinates
    // update the position of the vertex but not the normal/direction
    // put 1.0 for update the normal/direction according to the position

    vNormal = modelNormal.xyz;
    vPosition = modelPosition.xyz;
}
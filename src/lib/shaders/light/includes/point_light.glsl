vec3 pointLight(vec3 lightColor, float lightIntensity, vec3 normal, vec3 lightPosition, vec3 viewDirection, float specularPower, vec3 position, float lightDecay) {
    vec3 lightDelta = lightPosition - position;
    float lightDistance = length(lightDelta);
    vec3 lightDirection = normalize(lightDelta);
    vec3 lightReflection = reflect(-lightDirection, normal); // Don't forget to invert the light direction

    // Shading
    float shading = dot(normal, lightDirection);
    shading = max(shading, 0.0);

    // Specular
    float specular = dot(lightReflection, -viewDirection);
    // dot return between -1 and 1
    specular = max(specular, 0.0);
    specular = pow(specular, specularPower);
    specular *= 2.;

    // Decay
    float decay = 1.0 - lightDistance * lightDecay;
    decay = max(decay, 0.0);

    return lightColor * lightIntensity * decay * (shading + specular);
}
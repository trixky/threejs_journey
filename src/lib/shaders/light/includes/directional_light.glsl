vec3 directionalLight(vec3 lightColor, float lightIntensity, vec3 normal, vec3 lightPosition, vec3 viewDirection, float specularPower) {
    vec3 lightDirection = normalize(lightPosition);
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

    return lightColor * lightIntensity * (shading + specular);
}
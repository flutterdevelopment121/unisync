// File: assets/shaders/liquid_glass.frag
#version 300 es
precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
// uniform sampler2D uTexture; // If you want to distort a texture/child

out vec4 fragColor;

// Noise functions by Inigo Quilez
// https://www.shadertoy.com/view/MsfGzM
vec3 hash( vec3 p ) {
    p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
              dot(p,vec3(269.5,183.3,246.1)),
              dot(p,vec3(113.5,271.9,124.6)));
    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec3 p ) {
    vec3 i = floor( p );
    vec3 f = fract( p );
    f = f*f*(3.0-2.0*f);
    return mix(mix(mix( dot( hash( i + vec3(0,0,0) ), f - vec3(0,0,0) ),
                        dot( hash( i + vec3(1,0,0) ), f - vec3(1,0,0) ), f.x),
                   mix( dot( hash( i + vec3(0,1,0) ), f - vec3(0,1,0) ),
                        dot( hash( i + vec3(1,1,0) ), f - vec3(1,1,0) ), f.x), f.y),
               mix(mix( dot( hash( i + vec3(0,0,1) ), f - vec3(0,0,1) ),
                        dot( hash( i + vec3(1,0,1) ), f - vec3(1,0,1) ), f.x),
                   mix( dot( hash( i + vec3(0,1,1) ), f - vec3(0,1,1) ), // Corrected line
                        dot( hash( i + vec3(1,1,1) ), f - vec3(1,1,1) ), f.x), f.y), f.z );
}

float fbm(vec3 p) {
    float f = 0.0;
    f += 0.5000 * noise(p); p *= 2.02;
    f += 0.2500 * noise(p); p *= 2.03;
    f += 0.1250 * noise(p); p *= 2.01;
    f += 0.0625 * noise(p);
    return f / 0.9375;
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - uResolution.xy) / min(uResolution.x, uResolution.y);
    float time = uTime * 0.1; // Control speed of animation

    float noiseVal = fbm(vec3(uv * 1.5, time)); // Adjust uv multiplier for pattern scale

    // Base color for the glass (e.g., a slightly transparent blue)
    vec3 glassColor = vec3(0.6, 0.8, 1.0); // Light blue

    // Modulate color with noise for a liquid appearance
    vec3 finalColor = glassColor * (0.5 + 0.5 * noiseVal);

    // Add some highlights/reflections based on noise
    float highlight = pow(smoothstep(0.6, 0.9, noiseVal), 2.0); // Sharper highlights
    finalColor += vec3(highlight * 0.5); // Add white highlights

    // Simulate some depth or caustics (very simplified)
    float depthEffect = smoothstep(0.2, 0.5, abs(noise(vec3(uv * 3.0, time * 0.5))));
    finalColor *= (0.8 + 0.2 * depthEffect);

    // Output final color with some transparency
    // The child widget will be rendered on top of this.
    // If you want the shader to be more opaque, increase the alpha.
    // If you want it to be more transparent, decrease it.
    fragColor = vec4(finalColor, 0.3); // Adjust alpha for desired transparency
}


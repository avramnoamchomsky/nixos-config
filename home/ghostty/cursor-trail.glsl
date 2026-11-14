// Leave a short blue trail with a white core without replacing the cursor.
void mainImage(out vec4 color, in vec2 pixel) {
    color = texture(iChannel0, pixel / iResolution.xy);
    float progress = (iTime - iTimeCursorChange) / 0.16;
    if (iFocus == 0 || iCursorVisible == 0 || progress < 0.0 || progress >= 1.0 ||
        iPreviousCursor.w <= 0.0 || iCurrentCursor.w <= 0.0) {
        return;
    }

    vec2 center = iCurrentCursor.xy + iCurrentCursor.zw * vec2(0.5, -0.5);
    vec2 previous = iPreviousCursor.xy + iPreviousCursor.zw * vec2(0.5, -0.5);
    vec2 delta = previous - center;
    float distanceMoved = length(delta);
    if (distanceMoved < 1.0) {
        return;
    }

    vec2 direction = delta / distanceMoved;
    float remaining = 1.0 - smoothstep(0.0, 1.0, progress);
    float trailLength = min(distanceMoved, 3.0 * iCurrentCursor.w) * remaining;
    vec2 offset = pixel - center;
    if (all(lessThanEqual(abs(offset), iCurrentCursor.zw * 0.5))) {
        return;
    }

    float along = clamp(dot(offset, direction), 0.0, trailLength);
    float away = length(offset - along * direction);
    float taper = 1.0 - along / max(trailLength, 1.0);
    float radius = max(1.0, iCurrentCursor.w * 0.18 * taper);
    float glow = 1.0 - smoothstep(0.0, radius + 2.0, away);
    float core = 1.0 - smoothstep(0.0, max(1.0, radius * 0.45), away);
    float fade = remaining * taper;
    color.rgb = mix(color.rgb, vec3(0.16, 0.55, 1.0), 0.65 * fade * glow);
    color.rgb = mix(color.rgb, vec3(0.90, 0.97, 1.0), 0.85 * fade * core);
}

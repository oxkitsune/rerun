#import <./types.wgsl>


/// Loads an RGBA texel from a texture holding an NV12 encoded image at the given screen space coordinates.
fn decode_nv12(texture: texture_2d<u32>, coords: vec2i) -> vec4f {
    let texture_dim = vec2f(textureDimensions(texture).xy);
    let uv_offset = u32(floor(texture_dim.y / 1.5));
    let uv_row = u32(coords.y / 2);
    var uv_col = u32(coords.x / 2) * 2u;

    let y = max(0.0, (f32(textureLoad(texture, vec2u(coords), 0).r) - 16.0)) / 219.0;
    let u = (f32(textureLoad(texture, vec2u(u32(uv_col), uv_offset + uv_row), 0).r) - 128.0) / 224.0;
    let v = (f32(textureLoad(texture, vec2u((u32(uv_col) + 1u), uv_offset + uv_row), 0).r) - 128.0) / 224.0;

    // Specifying the color standard should be exposed in the future (https://github.com/rerun-io/rerun/pull/3541)
    // BT.601 (aka. SDTV, aka. Rec.601). wiki: https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.601_conversion
    let r = clamp(y + 1.402 * v, 0.0, 1.0);
    let g = clamp(y  - (0.344 * u + 0.714 * v), 0.0, 1.0);
    let b = clamp(y + 1.772 * u, 0.0, 1.0);
    // BT.709 (aka. HDTV, aka. Rec.709). wiki: https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.709_conversion
    // let r = clamp(y + 1.5748 * v, 0.0, 1.0);
    // let g = clamp(y + u * -0.1873 + v * -0.4681, 0.0, 1.0);
    // let b = clamp(y + u * 1.8556, 0.0 , 1.0);
    return vec4f(r, g, b, 1.0);
}

/// Loads an RGBA texel from a texture holding an YUV422 encoded image at the given screen space coordinates.
fn decode_yuv422(texture: texture_2d<u32>, coords: vec2i) -> vec4f {
    let texture_dim = vec2f(textureDimensions(texture).xy);
    let uv_offset = u32(floor(texture_dim.y / 2.0));
    let uv_row = u32(coords.y);
    var uv_col = u32(coords.x / 2) * 2u;

    let y1 = max(0.0, (f32(textureLoad(texture, vec2u(coords), 0).r) - 16.0)) / 219.0;
    let u = (f32(textureLoad(texture, vec2u(u32(uv_col), uv_offset + uv_row), 0).r) - 128.0) / 224.0;
    let y2 = max(0.0, (f32(textureLoad(texture, vec2u((u32(uv_col) + 1u), uv_row), 0).r) - 16.0)) / 219.0;
    let v = (f32(textureLoad(texture, vec2u((u32(uv_col) + 1u), uv_offset + uv_row), 0).r) - 128.0) / 224.0;

    let r = clamp(y1 + 1.402 * v, 0.0, 1.0);
    let g = clamp(y1  - (0.344 * u + 0.714 * v), 0.0, 1.0);
    let b = clamp(y1 + 1.772 * u, 0.0, 1.0);
    return vec4f(r, g, b, 1.0);
}

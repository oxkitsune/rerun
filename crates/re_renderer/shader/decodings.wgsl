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
    let g = clamp(y - (0.344 * u + 0.714 * v), 0.0, 1.0);
    let b = clamp(y + 1.772 * u, 0.0, 1.0);
    // BT.709 (aka. HDTV, aka. Rec.709). wiki: https://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.709_conversion
    // let r = clamp(y + 1.5748 * v, 0.0, 1.0);
    // let g = clamp(y + u * -0.1873 + v * -0.4681, 0.0, 1.0);
    // let b = clamp(y + u * 1.8556, 0.0 , 1.0);
    return vec4f(r, g, b, 1.0);
}

/// Loads an RGBA texel from a texture holding an YUV422 encoded image at the given screen space coordinates.
fn decode_yuv422(texture: texture_2d<u32>, coords: vec2i) -> vec4f {
    // texture is 2560x960
    // every 4 bytes is 2 pixels

    // we're drawing this at 1280x960
    // so we need to scale the texture coords
    // by 0.5

    let texture_dim = vec2f(textureDimensions(texture).xy);
    var uv_row = u32(coords.y);
    var uv_col = u32(coords.x) * 2u; // multiply by 2 because we're sampling 2 pixels at a time
    var y = 0.0;
    var u = 0.0;
    var v = 0.0;

    // we check coords.x % 2 to see if we're on an even or odd pixel
    if coords.x % 2 == 0 {
        // sample the current pixel and return it
        y = max(0.0, (f32(textureLoad(texture, vec2u(uv_col, uv_row), 0).r))) / 255.0;
        // even though the u component is right next to the y component, we add 2 to the column
        // because the width of the texture bufer is 2*width of the actual image.
        u = max(0.0, (f32(textureLoad(texture, vec2u(uv_col + 2u, uv_row), 0).r))) / 255.0;
        // same goes for the v component, it's 3 components after the first y: yuyv <--
        v = max(0.0, (f32(textureLoad(texture, vec2u(uv_col + 6u, uv_row), 0).r))) / 255.0;
    } else {
        // we're on an odd pixel, so we need to sample the u and v from the "previos" pixel
        // which is the one to the left (because we're on the u component now), but since the width of the texture buffer
        // is 2*width of the actual image, we add 2 to the column to get the correct pixel
        y = max(0.0, (f32(textureLoad(texture, vec2u(uv_col + 2u, uv_row), 0).r))) / 255.0;
        // we're already on the u component, so we don't need to add anything to the column
        u = max(0.0, (f32(textureLoad(texture, vec2u(uv_col, uv_row), 0).r))) / 255.0;
        // same goes for the v component, it's 1 component after the first y: yuyv <--
        v = max(0.0, (f32(textureLoad(texture, vec2u(uv_col + 4u, uv_row), 0).r))) / 255.0;
    }

    let y1 = i32(y * 255.0) - 16;
    let u1 = i32(u * 255.0) - 128;
    let v1 = i32(v * 255.0) - 128;

    let r = (298 * y1 + 409 * v1 + 128) >> 8u;
    let g = (298 * y1 - 100 * u1 - 208 * v1) >> 8u;
    let b = (298 * y1 + 516 * u1) >> 8u;

    let r1 = clamp(f32(r) / 255.0, 0.0, 1.0);
    let g1 = clamp(f32(g) / 255.0, 0.0, 1.0);
    let b1 = clamp(f32(b) / 255.0, 0.0, 1.0);

    // let texture_dim_width_colour = texture_dim.y / f32(960u);

    // return vec4f(texture_dim_width_colour, texture_dim_width_colour, texture_dim_width_colour, 1.0);
    // let i = f32(uv_col / 2u) /  510.0;
    // let i = f32(uv_row) / (255.0);
    // return vec4f(i, i, i, 1.0);
    return vec4f(r1, g1, b1, 1.0);
    // return vec4f(y, u, v, 1.0);
    // return vec4f(y, y, y, 1.0);
    // return vec4f(u, u, u, 1.0);
    // return vec4f(v, v, v, 1.0);
}

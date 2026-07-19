"""
golden_model.py
Python Golden Model for the INT8 3x3 Convolution Core.

Extends compare_python.py's per-window arithmetic (conv3x3 + clip_int8) to
an entire image, reproducing exactly what the hardware pipeline computes:

    mac_3x3.v   : product = pixel(INT8) * weight(INT8)         -> INT16
                  product_sum = sign-extended sum of 9 products -> INT32
                  sum = product_sum + bias                      -> INT32
    quant_clip.v: out_int8 = clip(sum, -128, 127)                -> INT8

Reads a streamed image.hex (e.g. so.hex / vat.hex / giay.hex, 784 signed
INT8 values, produced by convert_all.py) and a kernel.hex (9 signed INT8
weights, same layout kernel_rom.v loads via $readmemh), and writes
expected_output.hex: 676 signed INT8 values (26x26), one per line, in the
same row-major order as tb_compare_python_rtl.v's out_index = row*26+col.

Usage:
    python golden_model.py --image so.hex --kernel kernel.hex \
        --out expected_output.hex

    # Regenerate kernel.hex from the built-in Sobel-vertical kernel
    # (kernel_rom.v, kernel_sel = 0):
    python golden_model.py --image so.hex --write-kernel kernel.hex \
        --out expected_output.hex
"""

import argparse

# kernel_rom.v, kernel_sel = 0 (Sobel vertical edge kernel)
SOBEL_VERTICAL = [
    [1, 0, -1],
    [2, 0, -2],
    [1, 0, -1],
]

BIAS = 0


def read_hex_bytes(path):
    """Read a $readmemh-style file: one 2-digit hex byte per line,
    interpreted as signed INT8 (two's complement)."""
    values = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            raw = int(line, 16)
            if raw > 127:
                raw -= 256
            values.append(raw)
    return values


def write_hex_bytes(path, values):
    """Write signed INT8 values as one 2-digit two's-complement hex byte per line."""
    with open(path, "w") as f:
        for v in values:
            f.write(f"{v & 0xFF:02X}\n")


def conv3x3(window, kernel, bias=0):
    """Signed multiply-accumulate over a 3x3 window - mirrors mac_3x3.v."""
    total = bias
    for r in range(3):
        for c in range(3):
            # In RTL: int8 * int8 -> int16, sign-extended and accumulated into int32.
            total += int(window[r][c]) * int(kernel[r][c])
    return total


def clip_int8(value):
    """Mirrors quant_clip.v with SHIFT = 0: saturate to signed INT8 range."""
    if value > 127:
        return 127
    if value < -128:
        return -128
    return value


def run_golden_model(image_path, kernel_path, img_width=28, img_height=28, bias=BIAS):
    pixels = read_hex_bytes(image_path)
    expected_len = img_width * img_height
    if len(pixels) != expected_len:
        raise ValueError(
            f"{image_path}: expected {expected_len} pixels "
            f"({img_width}x{img_height}), got {len(pixels)}"
        )
    image = [pixels[r * img_width:(r + 1) * img_width] for r in range(img_height)]

    if kernel_path:
        kflat = read_hex_bytes(kernel_path)
        if len(kflat) != 9:
            raise ValueError(f"{kernel_path}: expected 9 kernel weights, got {len(kflat)}")
        kernel = [kflat[0:3], kflat[3:6], kflat[6:9]]
    else:
        kernel = SOBEL_VERTICAL

    out_w = img_width - 2
    out_h = img_height - 2
    expected_output = []

    # Row-major order matches tb_compare_python_rtl.v: out_index = row*OUT_W + col
    for row in range(out_h):
        for col in range(out_w):
            window = [image[row + dr][col:col + 3] for dr in range(3)]
            acc = conv3x3(window, kernel, bias)
            expected_output.append(clip_int8(acc))

    return expected_output, kernel


def main():
    parser = argparse.ArgumentParser(description="INT8 Conv Core Python Golden Model")
    parser.add_argument("--image", required=True, help="Input image .hex (e.g. so.hex)")
    parser.add_argument("--kernel", default=None,
                         help="Kernel .hex to read (defaults to built-in Sobel vertical)")
    parser.add_argument("--img-width", type=int, default=28)
    parser.add_argument("--img-height", type=int, default=28)
    parser.add_argument("--bias", type=int, default=0)
    parser.add_argument("--out", default="expected_output.hex", help="Output .hex path")
    parser.add_argument("--write-kernel", default=None,
                         help="If set, (re)write the kernel actually used to this path")
    args = parser.parse_args()

    expected_output, kernel = run_golden_model(
        args.image, args.kernel, args.img_width, args.img_height, args.bias
    )

    write_hex_bytes(args.out, expected_output)
    print(f"Wrote {len(expected_output)} values to {args.out} "
          f"({args.img_width - 2}x{args.img_height - 2} feature map)")

    if args.write_kernel:
        kflat = [w for row in kernel for w in row]
        write_hex_bytes(args.write_kernel, kflat)
        print(f"Wrote kernel to {args.write_kernel}")


if __name__ == "__main__":
    main()

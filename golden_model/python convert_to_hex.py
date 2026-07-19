from PIL import Image
import numpy as np

def image_to_hex(image_path, output_hex_path):
    # 1. Mở ảnh và ép về chuẩn 28x28 Grayscale
    img = Image.open(image_path).convert('L').resize((28, 28))
    data = np.array(img).astype(np.int16) # Dùng int16 để tính toán không bị tràn
    
    # 2. Lượng tử hóa INT8 (dải 0-255 -> -128 đến 127)
    # Mạch của Người số 3 dùng signed INT8
    data_int8 = data - 128
    
    # 3. Xuất file HEX (Đúng chuẩn ModelSim $readmemh)
    with open(output_hex_path, 'w') as f:
        for pixel in data_int8.flatten():
            # Chuyển sang dạng bù 2 (two's complement) 8-bit
            # Lấy 8 bit cuối để ra định dạng hex 2 ký tự
            hex_val = f"{pixel & 0xFF:02X}"
            f.write(hex_val + "\n")
    
    print(f"Đã xuất file thành công tại: {output_hex_path}")

# Thay tên ảnh của cậu vào đây
image_to_hex("layer 1.png", "layer 1.hex")
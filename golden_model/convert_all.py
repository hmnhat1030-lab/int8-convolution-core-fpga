import os
from PIL import Image
import numpy as np

# Danh sách các thư mục cần xử lý
folders = ['giày', 'số', 'vật']

for folder in folders:
    output_file = f"{folder}.hex"
    print(f"--- Đang xử lý thư mục: {folder} ---")
    
    # Mở file để ghi
    with open(output_file, 'w') as f_out:
        # Lấy danh sách ảnh trong thư mục
        for filename in os.listdir(folder):
            if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
                img_path = os.path.join(folder, filename)
                
                # Resize về 28x28 và chuyển sang ảnh xám
                img = Image.open(img_path).convert('L').resize((28, 28))
                
                # Chuyển sang dạng mảng và ép kiểu INT16 để tránh tràn số
                data = np.array(img).astype(np.int16) - 128
                
                # Ghi dữ liệu vào file .hex (mỗi pixel là 1 dòng)
                for pixel in data.flatten():
                    f_out.write(f"{pixel & 0xFF:02X}\n")
                    
    print(f"Xong! File được lưu tại: {output_file}")
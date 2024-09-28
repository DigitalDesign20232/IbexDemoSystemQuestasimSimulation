#!/bin/bash

# Đường dẫn thư mục
objdump_dir="/home/luanle/ibex/riscv-compliance/work/rv32i_m/I"
mem_dir="/home/luanle/DigitalDesign/IbexDemoSystemQuestasimSimulation/result_test"
output_dir="/home/luanle/DigitalDesign/IbexDemoSystemQuestasimSimulation/signature_output"

# Tạo thư mục đầu ra nếu chưa tồn tại
mkdir -p "$output_dir"

# Lặp qua tất cả các file .objdump trong thư mục
for objdump_file in "$objdump_dir"/*.elf.objdump; do
  if [ ! -f "$objdump_file" ]; then
    echo "Không tìm thấy file .objdump nào trong thư mục."
    continue
  fi

  # Lấy tên file mà không có phần mở rộng
  base_name=$(basename "$objdump_file" .elf.objdump)

  # Tìm <begin_signature> và <end_signature>
  begin_address=$(grep -m 1 "<begin_signature>:" "$objdump_file" | awk '{print $1}' | tr -d '<>')
  end_address=$(grep -m 1 "<end_signature>:" "$objdump_file" | awk '{print $1}' | tr -d '<>')

  if [ -z "$begin_address" ] || [ -z "$end_address" ]; then
    echo "Không tìm thấy signature trong file $objdump_file." 
    continue
  fi

  # Chia giá trị signature cho 4
  begin_address=$((0x$begin_address/4))
  end_address=$((0x$end_address/4-1))

  # Đọc file .mem tương ứng
  mem_file="$mem_dir/$base_name.elf.mem"
  if [ ! -f "$mem_file" ]; then
    echo "Không tìm thấy file .elf.mem tương ứng: $mem_file" 
    continue
  fi

  # Tạo file ghi kết quả cho từng file .objdump
  output_file="$output_dir/$base_name.signature"

  # Lọc dữ liệu giữa <begin_signature> và <end_signature>
  awk -v start="$begin_address" -v end="$end_address" '
  {
    # Tách địa chỉ và giá trị
    split($0, arr, ":");
    addr = arr[1];  # Địa chỉ

    # So sánh với địa chỉ cần lấy
    if (addr >= start && addr <= end) {
      # Loại bỏ khoảng trắng thừa trước giá trị
      gsub(/^ +| +$/, "", arr[2]);  # Trimming spaces
      print arr[2];  # Chỉ ghi phần sau dấu ':'
    }
  }' "$mem_file" > "$output_file"

  # Hiển thị thông báo thành công trên terminal
  echo "Kết quả đã được ghi vào: $output_file"
done

echo "Tất cả kết quả đã được ghi vào thư mục: $output_dir"

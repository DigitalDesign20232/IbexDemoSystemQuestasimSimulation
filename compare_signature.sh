#!/bin/bash

# Đường dẫn thư mục
signature_dir=~/DigitalDesign/IbexDemoSystemQuestasimSimulation/signature_output
reference_dir=~/ibex/riscv-compliance/riscv-test-suite/rv32i_m/I/references

# Kiểm tra xem thư mục a và b có tồn tại không
if [ ! -d "$signature_dir" ] || [ ! -d "$reference_dir" ]; then
  echo "Một trong hai thư mục '$signature_dir' hoặc '$reference_dir' không tồn tại."
  exit 1
fi

# Hiển thị tiêu đề
printf "%-30s %s\n" "Tên tệp" "Trạng thái"
mkdir -p compare


# Lặp qua tất cả các tệp .vmem trong thư mục a
for file in "$signature_dir"/*.signature; do
  # Lấy tên tệp mà không có đường dẫn và phần mở rộng
  basename_file=$(basename "$file" .signature)

  # Kiểm tra xem tệp cùng tên có tồn tại trong thư mục b hay không
  if [ -f "$reference_dir/$basename_file.reference_output" ]; then
    # So sánh tệp
    diff "$file" "$reference_dir/$basename_file.reference_output" > "$signature_dir/$basename_file.diff"
    if diff -q "$file" "$reference_dir/$basename_file.reference_output" > /dev/null ; then
      status="PASS"
    else
      status="FAIL"
    fi
  else
    status="Không tìm thấy"
  fi

  # In ra kết quả
  printf "%-30s %s\n" "$basename_file" "$status"
done

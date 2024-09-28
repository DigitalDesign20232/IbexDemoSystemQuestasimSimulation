#!/bin/bash

# Kiểm tra số lượng tham số
if [ "$#" -ne 2 ]; then
  echo "Sử dụng: $0 <thư_mục_a> <thư_mục_b>"
  exit 1
fi

# Gán tham số vào biến
dir_a=$1
dir_b=$2

# Kiểm tra xem thư mục a và b có tồn tại không
if [ ! -d "$dir_a" ] || [ ! -d "$dir_b" ]; then
  echo "Một trong hai thư mục '$dir_a' hoặc '$dir_b' không tồn tại."
  exit 1
fi

# Hiển thị tiêu đề
printf "%-30s %s\n" "Tên tệp" "Trạng thái"
mkdir -p compare

# Lặp qua tất cả các tệp .vmem trong thư mục a
for file in "$dir_a"/*.mem; do
  # Lấy tên tệp mà không có đường dẫn và phần mở rộng
  basename_file=$(basename "$file" .mem)

  # Kiểm tra xem tệp cùng tên có tồn tại trong thư mục b hay không
  if [ -f "$dir_b/$basename_file.mem" ]; then
    # So sánh tệp
    diff "$file" "$dir_b/$basename_file.mem" > "$dir_b/$basename_file.diff"
    if diff -q "$file" "$dir_b/$basename_file.mem" > /dev/null ; then
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

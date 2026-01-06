#!/bin/bash

# 设置工作目录
WORK_DIR=$(pwd)
PUBSPEC_FILE="$WORK_DIR/pubspec.yaml"
R_FILE="$WORK_DIR/lib/r.dart"
ASSETS_DIR="$WORK_DIR/assets/img"

# 创建临时文件
TEMP_R=$(mktemp)
TEMP_PUBSPEC=$(mktemp)

# 函数：将字符串转换为驼峰命名
to_camel_case() {
    local input=$1
    # 移除文件后缀
    input=$(echo "$input" | sed 's/\.[^.]*$//')
    local output="assetsImg"

    # 将输入按_和-分割
    IFS='_-' read -ra PARTS <<< "$input"

    for part in "${PARTS[@]}"; do
        # 每个部分都首字母大写
        local first_char=$(echo "${part:0:1}" | tr '[:lower:]' '[:upper:]')
        local rest_chars=$(echo "${part:1}" | tr '[:upper:]' '[:lower:]')
        output="${output}${first_char}${rest_chars}"
    done

    echo "$output"
}

# 函数：检查并同步资源文件
sync_assets() {
    echo "开始检查资源文件..."
    
    # 获取pubspec.yaml中的资源列表
    local pubspec_assets=$(grep -A 1000 "flutter:" "$PUBSPEC_FILE" | grep -B 1000 "uses-material-design:" | grep "assets/img/" | sed 's/^[ ]*-[ ]*//')
    
    # 获取实际文件列表
    local actual_files=$(find "$ASSETS_DIR" -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" | sed "s|$WORK_DIR/||")
    
    # 检查缺失的文件
    local missing_files=()
    while IFS= read -r file; do
        if ! echo "$pubspec_assets" | grep -q "^$file$"; then
            missing_files+=("$file")
        fi
    done <<< "$actual_files"
    
    # 如果有缺失的文件，添加到pubspec.yaml
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "发现 ${#missing_files[@]} 个未在pubspec.yaml中配置的资源文件"
        
        # 创建新的pubspec.yaml
        awk -v files="${missing_files[*]}" '
        /uses-material-design:/ {
            split(files, arr, " ")
            for (i in arr) {
                if (arr[i] != "") {
                    print "    - " arr[i]
                }
            }
            print $0
            next
        }
        {print}
        ' "$PUBSPEC_FILE" > "$TEMP_PUBSPEC"
        
        # 替换原文件
        mv "$TEMP_PUBSPEC" "$PUBSPEC_FILE"
        echo "已将缺失的资源文件添加到pubspec.yaml"
    else
        echo "所有资源文件都已正确配置"
    fi
}

# 同步资源文件
sync_assets

# 创建r.dart文件头部
cat > "$TEMP_R" << EOL
class R {
EOL

# 从pubspec.yaml中提取资源并生成r.dart内容
grep -A 1000 "flutter:" "$PUBSPEC_FILE" | grep -B 1000 "uses-material-design:" | grep "assets/img/" | sed 's/^[ ]*-[ ]*//' | while read -r asset; do
    # 生成变量名
    filename=$(basename "$asset")
    var_name=$(to_camel_case "$filename")

    # 添加到r.dart
    {
        echo "  /// ![](http://127.0.0.1:9999/$asset)"
        echo "  static final String $var_name = '$asset';"
        echo ""
    } >> "$TEMP_R"
done

# 添加文件尾部
echo "}" >> "$TEMP_R"

# 替换原文件
mv "$TEMP_R" "$R_FILE"

echo "r.dart 文件已根据 pubspec.yaml 重新生成完成!"
#!/usr/bin/env bash
#
# 由 v2fly/domain-list-community 的 data/category-ai-!cn 生成 AI.list。
#
# 规则来源：https://github.com/v2fly/domain-list-community/blob/master/data/category-ai-!cn
# 该文件本身只是一份 include 索引，需要递归展开它引用的 data 文件。
#
# 语法映射（与 AD.list / gwlist.txt 的 DOMAIN-SUFFIX 风格保持一致）：
#   example.com       -> DOMAIN-SUFFIX,example.com
#   full:example.com  -> DOMAIN,example.com
#   keyword:xxx       -> DOMAIN-KEYWORD,xxx
#   regexp:...        -> DOMAIN-REGEX,...（见下方正则近似的特例处理）
#   include:name      -> 递归展开 data/name
#   行尾属性 @ads/@cn 等与 # 注释一并丢弃
#
# 依赖：bash + wget
set -euo pipefail

RAW='https://raw.githubusercontent.com/v2fly/domain-list-community/master/data'
ROOTS='category-ai-!cn'

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

declare -A FETCHED=()
declare -A SEEN=()

fetch() {
    local name="$1"
    [ -n "${FETCHED[$name]:-}" ] && return 0
    FETCHED[$name]=1
    if ! wget -q --tries=3 --timeout=30 "$RAW/$name" -O "$WORK/$name"; then
        echo "WARN: 拉取失败 $RAW/$name" >&2
        return 1
    fi
}

expand() {
    local name="$1" raw line target

    [ -n "${SEEN[$name]:-}" ] && return 0
    SEEN[$name]=1
    fetch "$name" || return 0

    while IFS= read -r raw || [ -n "$raw" ]; do
        # 去掉 # 注释（行首或空白后的 #），再去掉行尾属性（@ads/@cn/...）
        line="$(printf '%s\n' "$raw" \
            | sed -E 's/(^|[[:space:]])#.*$//; s/[[:space:]]+@[^[:space:]]*//g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
        [ -z "$line" ] && continue

        case "$line" in
            include:*)
                target="${line#include:}"
                target="${target%% *}"
                expand "${target/:/\/}"          # include:dir:name -> dir/name
                ;;
            attribute:*|@*)
                continue
                ;;
            full:*)
                echo "DOMAIN,${line#full:}"
                ;;
            keyword:*)
                echo "DOMAIN-KEYWORD,${line#keyword:}"
                ;;
            regexp:*)
                case "$line" in
                    # 注意：源文件里的点是反斜杠转义的，模式里不能带裸点
                    *chatgpt-async-webps-prod*webpubsub*)
                        # 原规则 ^chatgpt-async-webps-prod-\S+-\d+\.webpubsub\.azure\.com$
                        # 即 chatgpt-async-webps-prod-<区域>-<序号>.webpubsub.azure.com，
                        # 前缀固定、后半段可变，用 DOMAIN-KEYWORD 近似替代。
                        echo "DOMAIN-KEYWORD,chatgpt-async-webps-prod"
                        ;;
                    *)
                        echo "DOMAIN-REGEX,${line#regexp:}"
                        ;;
                esac
                ;;
            *:*)
                echo "WARN: 未知条目 $line ($name)" >&2
                ;;
            *)
                echo "DOMAIN-SUFFIX,$line"
                ;;
        esac
    done < "$WORK/$name"
}

{
    for root in $ROOTS; do
        expand "$root"
    done
} | sort -u > AI.list.tmp

mv -f AI.list.tmp AI.list
echo "AI.list 生成完毕：$(wc -l < AI.list) 条"

#!/bin/bash
# link_helper.sh - Helper functions for creating symlinks safely
# Used by reforge_link.sh and Model downloader scripts

# Check if source exists and is readable
check_source_path() {
    local src="$1"

    if [ ! -e "$src" ]; then
        echo "エラー: ソースパスが見つかりません: $src" >&2
        return 1
    fi

    if [ ! -r "$src" ]; then
        echo "エラー: ソースパスに読み取り権限がありません: $src" >&2
        return 1
    fi

    return 0
}

# Check if destination parent is writable
check_dest_directory() {
    local dst="$1"
    local parent
    parent="$(dirname "$dst")"

    if [ ! -d "$parent" ]; then
        echo "エラー: 宛先の親ディレクトリが見つかりません: $parent" >&2
        return 1
    fi

    if [ ! -w "$parent" ]; then
        echo "エラー: 宛先ディレクトリに書き込み権限がありません: $parent" >&2
        return 1
    fi

    return 0
}

# Handle existing symlink or backup existing item
handle_existing_target() {
    local dst="$1"

    if [ -L "$dst" ]; then
        # Already a symlink, remove it
        echo "既存のシンボリックリンクを削除します: $dst"
        rm "$dst"
    elif [ -e "$dst" ]; then
        # Non-symlink item exists, back it up
        local timestamp
        timestamp="$(date +%Y%m%d_%H%M_%S%N)"
        local backup="${dst}-backup-${timestamp}"
        echo "既存のアイテムをバックアップします: $dst -> $backup"
        mv "$dst" "$backup"
    fi
}

# Create symlink with error handling
create_symlink() {
    local dst="$1"
    local src="$2"

    # Validate
    check_source_path "$src" || return 1
    check_dest_directory "$dst" || return 1

    # Handle existing
    handle_existing_target "$dst"

    # Create symlink
    if ! ln -s "$src" "$dst"; then
        echo "エラー: シンボリックリンク作成に失敗しました" >&2
        return 1
    fi

    # Verify
    if [ ! -L "$dst" ]; then
        echo "エラー: シンボリックリンク検証に失敗しました" >&2
        return 1
    fi

    echo "シンボリックリンク作成成功: $dst -> $src"
    return 0
}

# Get timestamp for unique names
get_timestamp() {
    date +%Y%m%d_%H%M_%S%N
}

# Interactive path prompt with validation
prompt_for_path() {
    local prompt_text="$1"
    local path_input

    while true; do
        read -r -p "$prompt_text: " path_input

        if [ -z "$path_input" ]; then
            echo "パスが空です。もう一度入力してください。"
            continue
        fi

        if [ ! -e "$path_input" ]; then
            echo "エラー: パスが見つかりません: $path_input"
            continue
        fi

        echo "$path_input"
        break
    done
}

# Get short name with optional override
prompt_for_name() {
    local default_name="$1"
    local name_input

    read -r -p "短いリンク名を入力（デフォルト: $default_name）: " name_input

    if [ -z "$name_input" ]; then
        echo "$default_name"
    else
        echo "$name_input"
    fi
}

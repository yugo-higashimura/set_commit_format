#!/bin/bash
set -euxo pipefail

## git のルードディレクトリを確認
CURRENT_DIR=$(git rev-parse --show-toplevel)

## prepare-commit-msg がないことを確認する
hook_file_path="${CURRENT_DIR}/.git/hooks/prepare-commit-msg"

if [ -e $hook_file_path ]; then
    echo "prepare-commit-msg exists."
    exit 1
fi

## commit_template がないことを確認する 
template_path="${CURRENT_DIR}/.git/hooks/_commit_template"

if [ -e $template_path ]; then
    echo "commit template exists."
    exit 1
fi

## config の確認
if [ -e $(git config commit.template) ]; then
    echo "commit template exists."
    exit 1
fi

## commit template を作成する
touch $template_path
echo "refs #[ticket_number] " >> $template_path

## commit template を config に設定する
git config commit.template $template_path

touch $hook_file_path
chmod +x $hook_file_path

# prepare-commit-msg の中身を設定する
cat << EOF >> $hook_file_path
#!/bin/bash

set -feu

# 現在のブランチ名を取得
current_branch_name=\$(git branch --contains | cut -d " " -f 2)

# branch から 数字の取得
if [[ \${current_branch_name} =~ ([0-9]+) ]]; then

    # 文字列結合
    ticket_number="\${BASH_REMATCH[1]}"

    # sed s=スクリプト/変更前/変更後 \$1=スクリプト実行対象
    sed -i "s/\[ticket_number\]/\$ticket_number/" \$1
fi

EOF

echo "local install done."

#!/bin/sh
# test.sh - 手动运行全部单元测试与静态检查
#
# 用法: ./test.sh
#
# 说明:
#   1. 本环境沙箱限制了对默认 Go 缓存目录的写入，因此将 GOCACHE/GOMODCACHE
#      指向 /private/tmp 下的可写目录。
#   2. 本环境无网络，GOPROXY=off 强制使用本地模块缓存；仓库根目录的
#      go.work（本地文件，未提交）将少数本地缓存缺失的依赖替换为可用版本。
#   3. 沙箱禁止绑定端口，以下包的测试因 httptest 无法 listen 而失败，
#      属于环境限制而非代码问题，脚本默认跳过：
#      internal/http/client, internal/reader/fetcher, internal/integration/...
#      如需全量运行（有网络/权限的环境），执行: ./test.sh --all

set -e
cd "$(dirname "$0")"

export GOCACHE=/private/tmp/gocache
export GOMODCACHE=/private/tmp/gomodcache
export GOPROXY=off
export GOSUMDB=off
export GOFLAGS=

SKIP_NET_PKGS='miniflux.app/v2/internal/http/client|miniflux.app/v2/internal/reader/fetcher|miniflux.app/v2/internal/integration/'

echo "==> 1/3 go build ./..."
go build ./...

echo "==> 2/3 go vet ./..."
go vet ./...

echo "==> 3/3 go test (unit tests)"
if [ "$1" = "--all" ]; then
    go test ./...
else
    PKGS=$(go list ./... | grep -v -E "$SKIP_NET_PKGS")
    # shellcheck disable=SC2086
    go test $PKGS
fi

echo "==> 全部通过"

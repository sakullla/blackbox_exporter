# 构建阶段
FROM golang:1.24.1-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装基本的构建工具
RUN apk add --no-cache git make

# 复制 go.mod 和 go.sum 文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o blackbox_exporter .

# 运行阶段
FROM alpine:latest

# 安装基本工具和CA证书
RUN apk --no-cache add ca-certificates tzdata

# 创建运行目录
RUN mkdir -p /bin

# 从构建阶段复制编译好的二进制文件到 /bin
COPY --from=builder /app/blackbox_exporter /bin/


EXPOSE      9115
ENTRYPOINT  [ "/bin/blackbox_exporter" ]
CMD         [ "--config.file=/etc/blackbox_exporter/config.yml" ]

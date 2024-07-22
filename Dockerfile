FROM golang:1.23rc2-alpine3.20 AS builder
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
COPY src/main.go ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
ENTRYPOINT ["./main"]
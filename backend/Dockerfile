# Build Stage
FROM golang:1.24-alpine AS builder
WORKDIR /app

# Dependencies
COPY backend/go.mod ./
RUN go mod download

# Build binary
COPY backend/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server .

# Production Runtime Stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /app

COPY --from=builder /app/server /app/server

ENV PORT=8080
EXPOSE 8080

CMD ["/app/server"]

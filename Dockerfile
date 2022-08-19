# syntax=docker/dockerfile:1

# specify the base image to  be used for the application, alpine or ubuntu
FROM --platform=$BUILDPLATFORM golang:1.19-alpine AS builder

# create a working directory inside the image
WORKDIR /app

# copy Go modules and dependencies to image
COPY go.mod go.sum ./

# download Go modules and dependencies
RUN go mod download

# copy directory files i.e all files ending with .go
COPY *.go ./

# compile application
ARG TARGETOS
ARG TARGETARCH

RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -o /bekci

FROM scratch

WORKDIR /

COPY --from=builder /bekci /bekci

EXPOSE 8080

ENTRYPOINT ["/bekci"]

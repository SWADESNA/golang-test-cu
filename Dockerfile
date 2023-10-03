FROM golang:1.21.1-bookworm AS build

# RUN apt-get update && apt-get install -y ca-certificates git-core ssh
# RUN git config --global --add url."https://${GITHUB_TOKEN}:@github.com/alexliesenfeld".insteadOf "https://github.com/alexliesenfeld"
RUN go get github.com/sqlc-dev/sqlc/cmd/sqlc@v1.22.0
RUN go install golang.org/x/tools/cmd/goimports@v0.13.0

# ENV GOPRIVATE=github.com/alexliesenfeld/*
ARG GITHUB_TOKEN

WORKDIR /app

COPY .. .

ENV CGO_ENABLED 0

RUN make generate-sql
RUN go build -o /go/bin/app cmd/scraper/main.go

FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build /go/bin/app /app

EXPOSE 3000

USER nonroot:nonroot

ENTRYPOINT ["/app"]

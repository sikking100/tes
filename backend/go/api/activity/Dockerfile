FROM golang:alpine3.16 as build
WORKDIR /app
COPY . .
RUN apk add --update --no-cache ca-certificates git
RUN go mod edit -replace github.com/grocee-project/dairyfood/backend/go/pkg/auth@v0.0.0=./dependency/pkg/auth
RUN go mod edit -replace github.com/grocee-project/dairyfood/backend/go/pkg/errors@v0.0.0=./dependency/pkg/errors
RUN go mod edit -replace github.com/grocee-project/dairyfood/backend/go/pkg/routes@v0.0.0=./dependency/pkg/routes
RUN go mod tidy 
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app -ldflags="-w -s" .
FROM scratch
WORKDIR /app
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /app/app /usr/bin/
ENV PORT=8080
EXPOSE $PORT
ENTRYPOINT ["app"]


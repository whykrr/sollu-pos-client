# Stage 1: Build Flutter Web
FROM ghcr.io/cirrusci/flutter:3.29.0 AS build-stage

WORKDIR /app

# Copy dependency manifests
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source code and build PWA release
COPY . .
RUN flutter build web --release --pwa-strategy offline-first

# Stage 2: Production Nginx Server
FROM nginx:alpine AS production-stage

# Copy Nginx SPA & PWA configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled web assets
COPY --from=build-stage /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

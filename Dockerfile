# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-stage

WORKDIR /app

# Copy project source code
COPY . .

# Resolve dependencies & build PWA release
RUN flutter pub get
RUN flutter build web --release --pwa-strategy offline-first

# Stage 2: Production Nginx Server
FROM nginx:alpine AS production-stage

# Copy Nginx SPA & PWA configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled web assets
COPY --from=build-stage /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

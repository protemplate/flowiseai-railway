# Stage 1: Build stage
FROM node:20-alpine AS build

USER root

# Skip downloading Chrome for Puppeteer (saves build time)
ENV PUPPETEER_SKIP_DOWNLOAD=true

# Install latest Flowise globally (specific version can be set: flowise@1.0.0)
RUN npm install -g flowise

# Stage 2: Runtime stage
FROM node:20-alpine

# Install runtime dependencies including PostgreSQL client for database initialization
RUN apk add --no-cache chromium git python3 py3-pip make g++ build-base cairo-dev pango-dev curl postgresql-client

# Set the environment variable for Puppeteer to find Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy Flowise from the build stage
COPY --from=build /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=build /usr/local/bin /usr/local/bin

# Copy initialization script
COPY init-db.sh /init-db.sh
RUN chmod +x /init-db.sh

# Set environment variables
ENV PORT=80

# Expose the specified port
EXPOSE ${PORT}

# Use the initialization script as entrypoint
ENTRYPOINT ["/init-db.sh"]
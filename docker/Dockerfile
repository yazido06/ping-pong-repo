# Build stage
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies
COPY src/ping-pong-api/package*.json ./
RUN npm install --omit=optional

# Copy source code
COPY src/ping-pong-api/ .

# No build step needed

# Production stage
FROM node:20-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy all files from builder
COPY --from=builder /app ./

# Install production dependencies only
RUN npm install --omit=optional --production

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ping || exit 1

# Start the application
CMD ["node", "server.js"] 
# --- Stage 1: builder ---
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app

# Install build deps (if needed) and copy package files first for caching
COPY package.json package-lock.json* ./

# Install only production dependencies in builder (optional)
# We still use builder stage to run npm ci to produce node_modules
RUN npm ci --production

# Copy app source
COPY . .

# If you have any build step (e.g. transpile), run it here
# RUN npm run build

# --- Stage 2: runtime ---
FROM node:20-alpine AS runtime

# Create non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only what's necessary from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/app.js ./app.js
# (Copy other needed files if present, e.g. public/, dist/)

# Ensure file permissions are correct for non-root user
RUN chown -R appuser:appgroup /app

# Expose default port
ENV PORT=3000
EXPOSE 3000

# Use non-root user
USER appuser

# Start the app
CMD ["node", "app.js"]

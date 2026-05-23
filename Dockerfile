# Stage 1: Build the C++ binary
FROM ubuntu:24.04 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the source code
COPY . .

# Build the project
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# Stage 2: Create the minimal runtime image
FROM ubuntu:24.04

# Install runtime dependencies (if any)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/build/edge_proxy /app/edge_proxy

# Expose port (assuming the proxy runs on 8080 eventually)
EXPOSE 8080

# Command to run the proxy
CMD ["./edge_proxy"]

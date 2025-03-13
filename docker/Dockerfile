FROM amazonlinux:2

# Install dependencies
RUN yum update -y && \
  yum install -y zip unzip curl

# Install Node.js 16.x
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash - && \
  yum install -y nodejs

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Build command will be executed from the build script
CMD ["echo", "Use build.sh to build the application"]
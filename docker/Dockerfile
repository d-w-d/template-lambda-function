FROM public.ecr.aws/sam/build-nodejs22.x

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

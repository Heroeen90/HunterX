FROM node:24-alpine

WORKDIR /app

# Install system tools
RUN apk add --no-cache \
    nmap \
    nmap-scripts \
    tcpdump \
    curl \
    wget \
    whois \
    bind-tools \
    openssh-client \
    && rm -rf /var/cache/apk/*

# Copy package files
COPY package.json ./

# Install Node dependencies
RUN npm install --omit=dev

# Copy source
COPY . .

EXPOSE 5000

ENV NODE_ENV=production
ENV PORT=5000

CMD ["node", "src/index.js"]

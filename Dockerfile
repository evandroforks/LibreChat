# Base node image
FROM node:18-alpine AS node

RUN apk add --no-cache g++ make py3-pip curl && \
        npm config set fetch-retry-maxtimeout 300000 && \
        npm install -g node-gyp npm

# USER node

WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY --chown=node:node package.json package-lock.json* ./
COPY --chown=node:node config config/
COPY --chown=node:node api/package.json api/
COPY --chown=node:node client/package.json client/
COPY --chown=node:node packages/data-provider/package.json packages/data-provider/

# Install dependencies
RUN npm install --no-audit
# Allow mounting of these files, which have no default
# values.
RUN touch .env

# Copy the rest of the application code
COPY --chown=node:node . .

# React client build
ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN npm run frontend

# Node API setup
EXPOSE 3080
ENV HOST=0.0.0.0
CMD ["npm", "run", "backend"]

# Optional: for client with nginx routing
# FROM nginx:stable-alpine AS nginx-client
# WORKDIR /usr/share/nginx/html
# COPY --from=node /app/client/dist /usr/share/nginx/html
# COPY client/nginx.conf /etc/nginx/conf.d/default.conf
# EXPOSE 80
# ENTRYPOINT ["nginx", "-g", "daemon off;"]

# Use nginx alpine for lightweight static file serving
FROM nginx:alpine

# Create a non-root user
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G nginx-app nginx-app

# Create necessary directories and set permissions
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html

# Copy website files to nginx html directory
COPY --chown=nginx-app:nginx-app index.html /usr/share/nginx/html/
COPY --chown=nginx-app:nginx-app style.css /usr/share/nginx/html/

# Copy custom nginx configuration
COPY --chown=nginx-app:nginx-app nginx.conf /etc/nginx/conf.d/default.conf

# Update main nginx.conf to run as non-root user
RUN sed -i 's/user  nginx;/user  nginx-app;/' /etc/nginx/nginx.conf && \
    sed -i '/listen\s*80;/s/80;/8080;/' /etc/nginx/conf.d/default.conf

# Switch to non-root user
USER nginx-app

# Expose port 8080 (non-privileged port)
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
FROM nginx:latest
LABEL org.opencontainers.image.title="my-study-mission"
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
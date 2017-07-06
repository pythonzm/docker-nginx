# docker-nginx

# How to use this image

## Hosting some simple static content
```
$ docker run --name some-nginx -v /some/static-html-directory:/usr/share/nginx/html:ro -d nginx
```
Alternatively, a simple Dockerfile can be used to generate a new image that includes the necessary content (which is a much cleaner solution than the bind mount above):
```
FROM nginx
COPY static-html-directory /usr/share/nginx/html
```
Place this file in the same directory as your directory of content ("static-html-directory"), run `docker build -t some-content-nginx .`, then start your container:
```
$ docker run --name some-nginx -d some-content-nginx
```
## Exposing external port

```
$ docker run --name some-nginx -d -p 8080:80 some-content-nginx
```
Then you can hit `http://localhost:8080` or `http://host-ip:8080` in your browser

## Complex configuration

```
$ docker run --name my-custom-nginx-container -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx
```
If you wish to adapt the default configuration, use something like the following to copy it from a running nginx container:
```
$ docker run --name tmp-nginx-container -d nginx
$ docker cp tmp-nginx-container:/etc/nginx/nginx.conf /host/path/nginx.conf
$ docker rm -f tmp-nginx-container
```
This can also be accomplished more cleanly using a simple Dockerfile (in /host/path/):
```
FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
```
If you add a custom CMD in the Dockerfile, be sure to include -g daemon off; in the CMD in order for nginx to stay in the foreground, so that Docker can track the process properly (otherwise your container will stop immediately after starting)!


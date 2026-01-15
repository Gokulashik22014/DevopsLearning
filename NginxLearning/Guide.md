
# NGINX as a Reverse Proxy & Load Balancer using Docker

This setup uses Docker images instead of manual installation to run **NGINX as a reverse proxy and load balancer**.

We use:

nginx:stable


for NGINX and a custom-built backend server image.

---

## 1. Build the Backend Server Image

From the backend project directory:

```bash
cd server
docker build -t nserver .
```

This creates an image called `nserver` that runs the backend on port `3000`.

---

## 2. Run Backend Server Container

```bash
docker run -d --name nserver1 nserver
```

This starts the backend server container.

---

## 3. Run NGINX Container

```bash
docker run -d --name nginxLB -p 80:80 nginx:stable
```

NGINX is now accessible at:

```
http://localhost
```

---

## 4. Create a Private Docker Network

```bash
docker network create nginx_network
```

Connect both containers to the network:

```bash
docker network connect nginx_network nginxLB
docker network connect nginx_network nserver1
```

Verify:

```bash
docker network inspect nginx_network
```

Now `nginxLB` and `nserver1` can talk using container names.

---

## 5. Configure NGINX as a Reverse Proxy

Enter the NGINX container:

```bash
docker exec -it nginxLB bash
```
Sometimes the edior wont be avaliable so 

```bash
apt-get update
apt-get install nano
```

Edit the default config:

```bash
nano /etc/nginx/conf.d/default.conf
```

Replace it with:

```nginx
server {
    listen 80;

    location / {
        proxy_pass http://nserver1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Reload NGINX:

```bash
nginx -s reload
```

Now traffic flows like:

```
Browser → NGINX → nserver1
```

The backend server is hidden and private.

---

## 6. Add Load Balancing

Run a second backend server:

```bash
docker run -d --name nserver2 --network nginx_network nserver
```

Update the NGINX config:

```bash
nano /etc/nginx/conf.d/default.conf
```

Replace it with:

```nginx
upstream backend_servers {
    server nserver1:3000;
    server nserver2:3000;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Reload:

```bash
nginx -s reload
```

Now NGINX distributes requests between `nserver1` and `nserver2`.

---

## 7. Automate Everything Using Docker Compose

### Folder Structure

```
project/
 ├─ server/
 │   ├─ Dockerfile
 │   └─ app code
 ├─ nginx/
 │   └─ default.conf
 └─ docker-compose.yml
```

---

### nginx/default.conf

```nginx
upstream backend_servers {
    server nserver1:3000;
    server nserver2:3000;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

### docker-compose.yml

```yaml
version: "3.9"

services:
  nserver1:
    build: ./backend
    container_name: nserver1
    expose:
      - "3000"
    networks:
      - nginx_net

  nserver2:
    build: ./backend
    container_name: nserver2
    expose:
      - "3000"
    networks:
      - nginx_net

  nginx:
    image: nginx:stable
    container_name: nginxLB
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - nserver1
      - nserver2
    networks:
      - nginx_net

networks:
  nginx_net:
    driver: bridge
```

---

## 8. Start Everything

From the project directory:

```bash
docker compose up --build
```

This will:

* Build the backend image
* Start two backend servers
* Start NGINX
* Create the network
* Apply the load balancer config

---

## Final Architecture

```
Browser
   ↓
NGINX (Reverse Proxy + Load Balancer)
   ↓
nserver1   nserver2
```

You now have a real, production-style reverse proxy and load balancer running locally. 🚀

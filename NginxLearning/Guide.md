I am trying to learn how to use the Nginx as a load balancer so we are using the following images from docker to avoid the manual installation

nginx:stable

so i created a server image docker build -t nserver . then created a container for it

now "Reverse proxy"
    -> hides the server and makes them private so only nginx can access it 
    -> so nginx is public and the security
    := user->http://localhost->nginx->server

    add both the nginx container and the server container in a single network 
    docker network create <name>
    docker network connect <n_name> <c_name>
    docker network inspect <n_name>

    so now that they are in the same network we need nginx to be the front face 
    so inside nginx container edit the /etc/nginx/conf.d/default.conf to your server
# cmcdota/docker-apache-php56-oci8
Docker image PHP 5.6 and Nginx+php-fpm


### Links
- [https://github.com/paliari-ti/docker-apache-php56-oci8](https://github.com/paliari-ti/docker-apache-php56-oci8)
- [https://hub.docker.com/r/paliari/apache-php56-oci8](https://hub.docker.com/r/paliari/apache-php56-oci8)

## Quick Start

To pull from docker hub:

```
docker build . -t timsof/php56-oci-master:latest
docker tag timsof/php56-oci-master:latest timsof/php56-oci-master:1.0.15
docker login
docker push timsof/php56-oci-master:1.0.15
```

### Running

Run the container:

```
docker container run -p 80:80 -v $(pwd):/var/www/html -d paliari/apache-ssl-php56-oci8:1.0.4-dev
```

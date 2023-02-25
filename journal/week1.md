# Week 1 — App Containerization
* [Streched Homework](#stretched-homework)
  * [Changed GitPod Port Visibility](#changed-gitpod-port-visibility)
  * [Added npm install to gitpod yaml](#added-npm-install-to-gitpod-yaml)
  * [Run Dockerfile CMD as an external script](#run-dockerfile-cmd-as-an-external-script)
  * [Push and tag an image to Dockerhub](#push-and-tag-an-image-to-dockerhub)
  * [Use multi-stage building for Dockerfile build](#use-multi-stage-building-for-dockerfile-build)
  * [Dockerfiles best practices](#dockerfiles-best-practices)
  * [Helpful Commands](#helpful-commands)
  * [Challenges](#challenges)
 
* [Required Homework](#required-homework)


## Stretched Homework

### Changed GitPod Port Visibility
  - using the GitPod documentation, I changed gitpod port visibility to public in .gitpod.yml file
  ``` 
  ports:
    - name: Backend
      port: 4567
      visibility: public
    - name: Frontend
      port: 3000
      visibility: public
    - name: Dynamodb
      port: 8000
      visibility: public
    - name: Postgres
      port: 5432
      visibility: public
  ```
 ### Added npm install to gitpod yaml
  - Added npm install to .gitpod.yaml file to all npm be automatically installed on launching gitpod
 ```
 - name: npm-install
    init: |
      cd /workspace/aws-bootcamp-cruddur-2023/frontend-react-js
      npm install
  ```
### Run Dockerfile CMD as an external script
- Create a script file in the root directory `run_dockerfile.sh` to build and run the container
    ```
      #!/bin/sh
      docker build -t  backend-flask ./backend-flask
      docker build -t  frontend-react-js ./frontend-react-js
      docker run -d --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
      docker run -d --rm -p 3000:3000 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' frontend-react-js
    ```
- Make the file executable by running `chmod +x run-dockerfile.sh `(this needs to be done only once) and `./run-dockerfile.sh` to run the file or add the file to the dockerfile CMD

  ![Screenshot 2023-02-24 at 18 25 42](https://user-images.githubusercontent.com/22412589/221260031-b95a69a0-658e-45a7-805c-4423935077cd.png)
  ![Screenshot 2023-02-24 at 18 24 53](https://user-images.githubusercontent.com/22412589/221259915-d5cf0780-5174-471e-81f1-7f1ced603e78.png)

### Push and tag an image to Dockerhub
- sign in to [Docker](https://hub.docker.com/)
- create a repository 
- login to docker on your terminal using
 `docker login`
 `WARNING! Your password will be stored unencrypted in /home/gitpod/.docker/config.json.`
   - using `docker logout` fixes this by deleting your credentials from `.docker/config.json` . Check `cd /home/gitpod/.docker/config.json` to confirm
- build and tag a new image
  `docker build -t <hub-user>/<repo-name>[:<tag>]`
- retag an existing local image e.g backend-flask
 `docker tag <existing-image> <hub-user>/<repo-name>[:<tag>]`
 `docker tag backend-flask kofoworolaogunleye/aws-cruddur-bootcamp:1.0`
- push image
  `docker push <hub-user>/<repo-name>:<tag>`
  `docker push kofoworolaogunleye/aws-cruddur-bootcamp:1.0`
  
  <img width="752" alt="Screenshot 2023-02-24 at 19 39 26" src="https://user-images.githubusercontent.com/22412589/221275282-86564130-364a-4af1-8066-2c5f9664408f.png">

### Use multi-stage building for Dockerfile build

```
  "One of the most challenging things about building images is keeping the image size down. Each RUN, COPY, and ADD instruction in the Dockerfile adds a   layer to the image, and you need to remember to clean up any artifacts you don’t need before moving on to the next layer. To write a really efficient   Dockerfile, you have traditionally needed to employ shell tricks and other logic to keep the layers as small as possible and to ensure that each layer   has the artifacts it needs from the previous layer and nothing else." 
  In simple terms,  multi-stage building helps to reduce the size of our image.
```
- using this youtube [video]([https://www.youtube.com/watch?v=1tHCVIO8Q04&ab_channel=CloudWithRaj](https://www.youtube.com/watch?v=5hSus7e4X1U&ab_channel=TechwithMike)), I learnt about multi stage build.
- initial size of docker image for backend was `129Mb`, use `docker history backend-flask' to see more details of each layer
  ![Screenshot 2023-02-24 at 21 13 46](https://user-images.githubusercontent.com/22412589/221294294-19e6846e-1777-4a6e-881d-9ec781cddbc4.png)
- final docker image size was `81.9Mb`
```
# Build stage
  FROM python:3.10-slim-buster AS base

  WORKDIR /backend-flask

  COPY requirements.txt requirements.txt
  RUN pip3 install -r requirements.txt

# Runtime stage, keeps the final
  FROM python:3.10-alpine # use a smaller image
  COPY --from=base /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/ #use files from the base stage and copies them in the second stage
  COPY --from=base /usr/bin/ /usr/bin/
  COPY . .
  ENV FLASK_ENV=development

  EXPOSE ${PORT}
  CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```
   ![Screenshot 2023-02-24 at 22 33 41](https://user-images.githubusercontent.com/22412589/221307742-03adaf25-678d-49cc-a419-367d57aacf05.png)

### Dockerfiles best practices
- using .dockerignore file in the root directory 
  ```
   # ignore .git and .cache folders
    .git
    .cache
    # ignore markdown files
    *.markdown

    # ignore sensitive files
    private.key
    settings.json
  ```
- scan images for vulnerabilities
   - login to docker using `docker login`
   - install docker scan package using `sudo apt-get update && sudo apt-get install docker-scan-plugin`
   - run `docker scan imagename`. it uses `synk`
   - `docker logout`
   
    ![Screenshot 2023-02-24 at 22 04 15](https://user-images.githubusercontent.com/22412589/221302077-706259b9-1202-426a-a0e1-3a01b659cf33.png)

- use small size official images. e.g `FROM python:3.10-alpine`
- use least priviledged user 

## Helpful Commands
- `chmod +x` - make script file executable
- `docker rmi <image name>` - remove image
- `docker stop <Container_ID>` - stop container
- `docker rm <Container_ID>` - remove container
- `docker history backend-flask`- see size of each layer
- `docker logs CONTAINER_ID -f` - check container logs
- `docker exec CONTAINER_ID -it /bin/bash` -  enter into the container
- `docker ps`

## Challenges
- while using multi stage build, my container kept exiting due to the error:
   `exec /usr/local/bin/python3: no such file or directory`
- sorted this out by running `whereis python3` to get the right path


## Required Homework
 ### Containerise Backend
  - added public port visibility to .gitpod.yml as shown [above](#changed-gitpod-port-visibility)  
  - created a Dockerfile in the `backend-flask` folder
  ```
  FROM python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```
 - Built and ran the container using `docker build -t  backend-flask ./backend-flask` and `docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask`
    - Another way to do this is by exporting the variables 
     ```
     export FRONTEND_URL="*"
     export BACKEND_URL="*"
     ```
     and using this `docker run --rm -p 4567:4567 -it  -e FRONTEND_URL -e BACKEND_URL backend-flask` to get the variables locally
     
     Then unset the variables using
     ```
     unset FRONTEND_URL="*"
     unset BACKEND_URL="*"
     ```
 ### Containerise Frontend
 - add npm install into .gitpod.yml to install it when [gitpod](#added-npm-install-to-gitpod-yaml) is run
 - create a Dockerfile in `frontend-react-js` folder
   ```
   FROM node:16.18

   ENV PORT=3000

   COPY . /frontend-react-js
   WORKDIR /frontend-react-js
   RUN npm install
   EXPOSE ${PORT}
   CMD ["npm", "start"]
   ```
 - Build and run container
   `docker build -t frontend-react-js ./frontend-react-js`
   `docker run -p 3000:3000 -d frontend-react-js`
   
 ### Use Docker-compose to run multiple containers
 - Create a `docker-compose.yml` at the root
 ```
 version: "3.8"
 services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js
networks: 
  internal-network:
    driver: bridge
    name: cruddur
 ```
 
 ### Add Local DynamoDB and Postgres
 - For Dynamodb, add this to `docker-compose.yml`
 ```
 services:
  dynamodb-local:
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
 ```
 -  For Postgres
 ```
 services:
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data
volumes:
  db:
    driver: local
 ```
   - Install postgres client into gitpod
   
 ```
 - name: postgres
   init: |
     curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
     echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
     sudo apt update
     sudo apt install -y postgresql-client-13 libpq-dev
 ```
  - created the notification feature for the frontend and backend
   ![Screenshot 2023-02-24 at 10 28 58](https://user-images.githubusercontent.com/22412589/221156102-6ee589d2-a2ef-4e73-a242-6e2dd768fa86.png)

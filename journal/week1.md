# Week 1 — App Containerization
* [Streched Homework](#stretched-homework)
  * [Changed GitPod Port Visibility](#changed-gitpod-port-visibility)
  * [Run Dockerfile CMD as an external script](#run-dockerfile-cmd-as-an-external-script)
  * [Push and tag an image to Dockerhub](#push-and-tag-an-image-to-dockerhub)
  * [Use multi-stage building for Dockerfile build](#use-multi-stage-building-for-Dockerfile-build)
  * [Dockerfiles best practices](#dockerfiles-best-practices)
  * [Helpful Commands](#helpful-commands)

- created the notification feature for the frontend and backend
![Screenshot 2023-02-24 at 10 28 58](https://user-images.githubusercontent.com/22412589/221156102-6ee589d2-a2ef-4e73-a242-6e2dd768fa86.png)

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
      docker run -d --rm -p 4567:4567  -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
      docker run -d --rm -p 3000:3000 -it frontend-react-js
    ```
- Made the file executable by running `chmod +x run-dockerfile.sh ` and `./run-dockerfile.sh` to run the file

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
### Dockerfiles best practices

## Helpful Commands
- `chmod +x` - make script file executable
- `docker rmi <image name>` - remove image
- `docker stop <Container_ID>` - stop container
- `docker rm <Container_ID>` - remove container

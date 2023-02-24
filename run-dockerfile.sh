#!/bin/sh
docker build -t  backend-flask ./backend-flask
docker build -t  frontend-react-js ./frontend-react-js
docker run -d --rm -p 4567:4567  -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask
docker run -d --rm -p 3000:3000 -it frontend-react-js
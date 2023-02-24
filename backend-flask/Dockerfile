FROM python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]


# # multi stage build

# # Build stage
#   FROM python:3.10-slim-buster AS base

#   WORKDIR /backend-flask

#   COPY requirements.txt requirements.txt
#   RUN pip3 install -r requirements.txt

# # Runtime stage
#   FROM python:3.10-alpine 
#   COPY --from=base /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/ 
#   COPY --from=base /usr/bin/ /usr/bin/
#   COPY . .
#   ENV FLASK_ENV=development

#   EXPOSE ${PORT}
#   CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
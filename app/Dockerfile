# pull official base image
FROM python:3.9.0-slim-buster


#FROM python:3.8.6-slim

RUN python3 -m venv venv


# set work directory

WORKDIR /usr/src/app



# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1



# install dependencies
RUN pip3 install --upgrade pip

#COPY ./requirements.txt .

#RUN pip3 install -r requirements.txt

RUN pip3 install Django --upgrade

RUN pip3 install gunicorn==20.1.0


# copy project
COPY . .

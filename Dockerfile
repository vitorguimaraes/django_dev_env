FROM python:3.12.0-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache make && \
    apk add build-base libpq-dev && \
    pip install --upgrade pip && \
    pip install django djangorestframework \
    djangorestframework-simplejwt django-filter psycopg2

ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

EXPOSE 8000

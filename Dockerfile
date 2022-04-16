
FROM ruby:3.1.2-alpine
EXPOSE 3000
WORKDIR /opt/app/src
ENV LANG ru_RU.utf8

RUN apk add --no-cache --update git build-base ca-certificates less postgresql-dev postgresql-client tzdata make libffi-dev libxml2 libxml2-dev libxslt-dev && \
    cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
    echo "Europe/Moscow" > /etc/timezone

ARG CONTAINER_GID=1000
ARG CONTAINER_UID=1000

RUN addgroup -g ${CONTAINER_GID} app && \
    adduser --uid ${CONTAINER_UID} --disabled-password --ingroup app --home /opt/app app && \
    chown -R app:app /opt/app && \
    chmod -R 0775 /opt/app

USER app:app

ADD --chown=app:app Gemfile Gemfile.lock /opt/app/src/
RUN bundle config without production && bundle install --retry=3 --jobs 20

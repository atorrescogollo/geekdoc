FROM klakegg/hugo:0.78.0-alpine
ARG BASEURL=/

RUN apk add --update npm git python3 alpine-sdk \
    && hugo new site site && mkdir /output \
    && cd site && rm config.toml && git init \
    && git submodule add https://github.com/thegeeklab/hugo-geekdoc.git themes/hugo-geekdoc \
    && cd themes/hugo-geekdoc && npm install  \
    && npm install --global gulp-cli && gulp default

WORKDIR /src/site

COPY config.yaml entrypoint.sh ./
ENTRYPOINT /src/site/entrypoint.sh
RUN sed -i 's@^baseURL:.*$@baseURL: '${BASEURL}'@g' config.yaml

COPY layouts/ ./layouts/
COPY data/ ./data/
COPY content/ ./content/
COPY static/ ./static/

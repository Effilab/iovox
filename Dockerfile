# Web application
FROM ruby:3
LABEL NAME=iovox
LABEL VERSION=1.0

# git is required by Gemfile
RUN apt-get update -qq              \
    && apt-get install -y           \
      build-essential               \
      libpq-dev                     \
      curl                          \
      git                           \
      vim                           \
      libjemalloc2                  \
      libgmp3-dev                   \
      libimlib2-dev                 \
    && rm -rf /var/lib/apt/lists/*  \
    && apt-get clean

ENV APP_ROOT_PATH=/home/iovox \
    EDITOR=vim \
    TZ=Europe/Paris \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    GEM_HOME=/home/iovox/vendor/bundle \
    GEM_PATH=/usr/local/bundle:/home/iovox/vendor/bundle

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
ENV MALLOC_ARENA_MAX 2
ENV HISTFILE=.shell_history

RUN mkdir -vp ${APP_ROOT_PATH}
RUN useradd -m iovox
RUN chown -R iovox:iovox ${APP_ROOT_PATH}

WORKDIR ${APP_ROOT_PATH}

RUN mkdir -vp ${GEM_HOME} \
    && chown -R iovox:iovox ${GEM_HOME}

USER iovox

COPY --chown=iovox:iovox . .

RUN ./bin/setup_bundler.sh ${GEM_HOME} \
    && bundle check || bundle install --jobs 5 --retry 5 \
    && bundle clean --force

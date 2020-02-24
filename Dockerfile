FROM ruby:2.6.5
RUN apt-get update -qq && \
  apt-get install -y imagemagick postgresql-client

RUN mkdir /progimage_store
WORKDIR /progimage_store

COPY Gemfile /progimage_store/Gemfile
COPY Gemfile.lock /progimage_store/Gemfile.lock
RUN bundle install --binstubs
COPY . /progimage_store

# Add a script to be executed every time the container starts.
COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process.
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

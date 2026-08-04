FROM ruby:3.1-bookworm

RUN apt-get update -qq && apt-get install -y build-essential git

WORKDIR /srv/jekyll
COPY Gemfile Gemfile.lock ./
RUN bundle install

EXPOSE 4000
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--force_polling"]
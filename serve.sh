# /bin/sh

docker run -it -v $PWD:/srv/jekyll -p 4000:4000 jekyll/builder jekyll serve --force_polling --incremental --future

FROM hugomods/hugo:go-0.115.1

RUN apk update
RUN apk add git
RUN git config --global user.name "Hugo Go Mod Installer" &&  \
    git config --global user.email "dev@null.com" &&  \
    git config --global --add safe.directory /src

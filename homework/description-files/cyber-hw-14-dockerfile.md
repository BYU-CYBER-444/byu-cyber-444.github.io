---
title: "CYBER HW 14 - Vulnerable Dockerfile (Audit Exercise)"
parent: Homework
nav_exclude: true
---

# Acme Widgets Co. - Vulnerable Dockerfile
{: .no_toc }

{: .note }
This is the intentionally flawed Dockerfile referenced in [CYBER HW 14]({% link homework/cyber-hw-14.md %}) Part 1 - the "app" (Python) service's build definition. Audit it yourself before looking anywhere else - the point of the exercise is to find the gaps independently. It contains **at least 8 issues** spanning the categories the assignment names: running as root, an unpinned base image, secrets in environment variables or build args, world-readable sensitive files, unnecessary packages, no `HEALTHCHECK`, missing `--no-install-recommends`, and exposed unnecessary ports.

```dockerfile
FROM python:latest

LABEL maintainer="devops@example.com"

ARG DB_PASSWORD=SuperSecret123!
ENV DB_PASSWORD=${DB_PASSWORD}
ENV API_KEY=sk_live_51H8xyzABCDEFGHIJKLMNOP
ENV APP_ENV=production

RUN apt-get update && apt-get install -y \
    curl \
    vim \
    telnet \
    netcat \
    build-essential \
    git \
    sudo \
    net-tools

RUN mkdir /app
WORKDIR /app

COPY . /app

RUN chmod -R 777 /app

RUN pip install -r requirements.txt

COPY config/secrets.env /app/secrets.env
RUN chmod 644 /app/secrets.env

EXPOSE 22
EXPOSE 80
EXPOSE 443
EXPOSE 5432
EXPOSE 8000

CMD ["python3", "app.py"]
```

[← Back to CYBER HW 14]({% link homework/cyber-hw-14.md %})

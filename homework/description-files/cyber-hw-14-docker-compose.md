---
title: "CYBER HW 14 - Vulnerable Docker Compose Stack (Audit Exercise)"
parent: Homework
nav_exclude: true
---

# Acme Widgets Co. - Vulnerable Docker Compose Stack
{: .no_toc }

{: .note }
This is the intentionally flawed Compose file referenced in [CYBER HW 14]({% link homework/cyber-hw-14.md %}) Part 2 - a 3-service stack (web/Nginx, app/Python, database/PostgreSQL). Audit it yourself before looking anywhere else - the point of the exercise is to find the gaps independently. You must identify **10 security improvements**, including at minimum: 2 addressing privilege escalation, 2 addressing secret management, 1 addressing network segmentation, 2 addressing resource limits, and 1 read-only filesystem mount.

```yaml
version: "3.8"

services:
  web:
    image: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
      - ./web/static:/usr/share/nginx/html
    depends_on:
      - app
    restart: always

  app:
    build: ./app
    image: myapp:latest
    ports:
      - "8000:8000"
    environment:
      - DB_HOST=database
      - DB_USER=appuser
      - DB_PASSWORD=SuperSecret123!
      - API_KEY=sk_live_51H8xyzABCDEFGHIJKLMNOP
      - SECRET_KEY=django-insecure-changeme
      - APP_ENV=production
      - DEBUG=true
    volumes:
      - ./app:/app
      - /app/data:/app/data
    depends_on:
      - database
    restart: always
    privileged: true

  database:
    image: postgres
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=SuperSecret123!
      - POSTGRES_DB=appdb
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

[← Back to CYBER HW 14]({% link homework/cyber-hw-14.md %})

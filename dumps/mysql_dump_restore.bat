#!/usr/bin/env bash
docker exec mysql /usr/bin/mysqldump -u root --password=157266 -r taxi | Set-Content db_dump.sql
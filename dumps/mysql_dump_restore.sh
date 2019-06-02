#!/usr/bin/env bash
cat db_dump.sql | docker exec -i mysql /usr/bin/mysql -u root --password=157266 taxi
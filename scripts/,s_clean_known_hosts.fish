#!/usr/bin/env fish

sed -i -e '/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/d' ~/.ssh/known_hosts  scripts/

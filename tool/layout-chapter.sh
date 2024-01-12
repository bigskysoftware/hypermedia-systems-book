#!/usr/bin/env bash
set -euxo pipefail
set 

content=$(cat)
title=$(grep '^= .*' <<<"$content" | sed 's/^= //')
chapter_no=$1

cat <<HTML
<!DOCTYPE html>
<html lang=en>
<meta charset=utf-8>
<link rel=stylesheet href=/style.css>
<title>$title</title>

$content

<footer>
  Hypermedia Systems |
  <a href="/">Cover</a> |
  <a href="/contents">Contents</a>
</footer>
HTML

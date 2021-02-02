#!/bin/bash
pm2 stop hexo_blog_run.js
hexo clean
hexo g
pm2 start hexo_blog_run.js

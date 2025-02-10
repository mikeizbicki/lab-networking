#!/bin/sh
nohup python -m http.server 5000 --directory 5000 &
nohup python -m http.server 5001 --directory 5001 &
nohup python -m http.server 8080 --directory 5000 &

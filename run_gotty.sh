#!/bin/bash
service ssh start
/usr/local/bin/gotty -w --port 80 --address 0.0.0.0 /bin/bash
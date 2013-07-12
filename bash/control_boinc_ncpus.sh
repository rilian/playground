#!/bin/bash

echo 'Current Load Average:'
awk '{print $3}' /proc/loadavg


#!/bin/bash

for port in {3000..3999}; do
  sudo ufw delete allow ${port}/tcp 2>/dev/null
done
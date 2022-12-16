#!/bin/bash
set -eux

script_dir=$(dirname "$0")

bash $script_dir/start_provider.sh
bash $script_dir/start_consumer.sh
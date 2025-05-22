set shell := ['bash', '-euo', 'pipefail', '-c']

test:
    ruby test/import_env_test.rb

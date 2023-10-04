set -eux

NEW_RELIC_CONFIG_FILE=newrelic.ini newrelic-admin run-program gunicorn --workers=1 --timeout=5400 --bind=0.0.0.0:5000 --access-logfile=- --error-logfile=- app:create_app\(\)

#!bin/bash

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
  echo "Bench already exists, skipping init"
else
   echo "Creating new bench..."

  bench init --skip-redis-config-generation frappe-bench

  cd /home/frappe/frappe-bench

  # Use containers instead of localhost
  bench set-mariadb-host db
  bench set-redis-cache-host redis-cache:6379
  bench set-redis-queue-host redis-queue:6379
  bench set-redis-socketio-host websocket:6379
  # bench set-ssl-certificate
  # bench set-ssl-key
  # bench set-url-root
  # bench set-nginx-port


  # Remove redis, watch from Procfile
  sed -i '/redis/d' ./Procfile
  sed -i '/watch/d' ./Procfile

   echo "Installing builder..."
  bench get-app builder https://github.com/frappe/builder --branch develop
fi

cd /home/frappe/frappe-bench

echo "Installing site-1 and applications"

bench set-config -g root_login root
bench set-config -g root_password admin

bench config dns_multitenant on

bench new-site crm.localhost --db-type mariadb \
--mariadb-user-host-login-scope='%' \
--db-type mariadb \
--db-host db \
--db-port 3306 \
--db-name nextdb \
--db-password admin \
--mariadb-root-username root \
--mariadb-root-password admin \
--admin-password admin
 # These are for use with databases other than mariadb and frappe v16 and up 
  # --db-user nextdb
  # --db-root-username root
  # --db-root-password admin 

echo "Adding applications to site"
bench --site crm.localhost install-app erpnext
bench --site crm.localhost install-app insights
bench --site crm.localhost install-app hrms
bench --site crm.localhost install-app crm
bench --site crm.localhost install-app helpdesk
# bench --site crm.localhost install-app property_management_system
bench --site crm.localhost install-app non_profit
bench --site crm.localhost install-app lending
bench --site crm.localhost install-app lms
bench --site crm.localhost install-app studio
bench --site crm.localhost install-app builder
bench --site crm.localhost install-app print_designer
bench --site crm.localhost install-app webshop
bench --site crm.localhost install-app payments
bench --site crm.localhost install-app wiki
bench --site crm.localhost install-app raven
bench --site crm.localhost install-app nextproject
bench --site crm.localhost install-app erpnext_price_estimation
bench --site crm.localhost install-app csf_tz
bench pip install geopy
bench --site crm.localhost install-app propms
bench --site crm.localhost install-app twilio_integration
bench --site crm.localhost install-app newsletter
bench pip install uuid_utils
# bench --site crm.localhost install-app mail --force
bench --site crm.localhost install-app drive

echo "Updateing Default Configurations"

bench --site crm.localhost set-config default_country "United States"
bench --site crm.localhost set-config default_currency "USD"
bench --site crm.localhost set-config default_company "Dynamic Solutions"
bench --site crm.localhost set-config fiscal_year "2025-2026"

echo "Finalizing site setup"

bench update --requirements
bench use crm.localhost

bench setup nginx --yes
service nginx reload

# For Production Setup
# bench setup supervisor
# bench set-nginx-port localhost 8080
# Nginx config
# bench setup production

echo "Doing some houskekeeping"

# Migrate each site to apply new app changes
bench ready-for-migration
bench --site crm.localhost migrate
bench --site crm.localhost clear-cache

# Enable schedulers on each site
bench --site crm.localhost enable-scheduler

# bench --site localhost set-config developer_mode 1
# bench start
bench restart
echo "Applications Installed on site"
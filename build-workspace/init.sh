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
  # --db-user nextdb
  # --db-root-username root \
  # --db-root-password admin \ 
  #
echo "Adding applications to site"
bench --site crm.localhost install-app erpnext
bench --site crm.localhost set-config default_country "United States"
bench --site crm.localhost set-config default_currency "USD"
bench --site crm.localhost set-config default_company "Dynamic Solutions"
bench --site crm.localhost set-config fiscal_year "2025-2026"
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
bench --site crm.localhost install-app insights
bench update --requirements

echo "Installing additional Applications for site-1"
  # Remove after next rebuild
  # bench get-app drive https://github.com/frappe/drive.git --branch main --resolve-deps
  # bench get-app newsletter https://github.com/frappe/newsletter.git --branch develop
  # bench get-app mail https://github.com/frappe/mail.git --branch develop --resolve-deps
  # bench get-app twilio_integration https://github.com/frappe/twilio-integration --branch master
  # bench get-app productivity_next https://github.com/finbyz/Productivity-Next.git --branch version-15
  # bench get-app csf_tz https://github.com/aakvatech/csf_tz.git --branch version-15
  # bench get-app PropMS https://github.com/aakvatech/PropMS.git --branch version-15

  # bench --site localhost install-app drive
  # bench --site localhost install-app productivity_next
  # bench pip install uuid_utils
  # bench --site localhost install-app mail --force
  # bench pip install geopy
  # bench --site localhost install-app propms
  # bench --site localhost install-app newsletter

bench use crm.localhost

# Nginx config
bench setup nginx --yes
service nginx reload
# bench setup supervisor

# bench set-nginx-port localhost 8080
# bench setup production

echo "Applications Installed on site-1, installing additional applications and sites 2-3"

bench pip install uuid_utils
bench --site crm.localhost install-app mail --force
bench --site crm.localhost install-app drive

# Migrate each site to apply new app changes
bench ready-for-migration
bench --site crm.localhost migrate
bench --site crm.localhost clear-cache

# Enable schedulers on each site
bench --site crm.localhost enable-scheduler

# bench --site localhost set-config developer_mode 1
# bench start
bench restart
echo "Applications Installed on sites 2-3"
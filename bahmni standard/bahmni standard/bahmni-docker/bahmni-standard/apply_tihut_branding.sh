#!/bin/bash
# Tihut Medium Clinic Branding Script
# This script applies permanent branding changes to Bahmni

echo "Applying Tihut Medium Clinic branding..."

# 1. Replace bahmniLogoFull.png with Tihut logo
docker cp bahmni_config/openmrs/apps/home/logo.png bahmni-standard-bahmni-web-1:/usr/local/apache2/htdocs/bahmni/images/bahmniLogoFull.png

# 2. Update locale files
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's/\"LOGIN_PAGE_TITLE_TEXT\": \"TITLE TEXT\"/\"LOGIN_PAGE_TITLE_TEXT\": \"\"/g' /usr/local/apache2/htdocs/bahmni/i18n/home/locale_en.json"
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's/\"LOGIN_PAGE_HEADER_TEXT\": \"BAHMNI EMR LOGIN\"/\"LOGIN_PAGE_HEADER_TEXT\": \"TIHUT EMR LOGIN\"/g' /usr/local/apache2/htdocs/bahmni/i18n/home/locale_en.json"
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's/\"BAHMNI_PAGE_TITLE_KEY\": \"Bahmni Home\"/\"BAHMNI_PAGE_TITLE_KEY\": \"Tihut Medium Clinic\"/g' /usr/local/apache2/htdocs/bahmni/i18n/home/locale_en.json"

# 3. Update HTML templates
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's|../images/bahmniLogoFull.png|/bahmni_config/openmrs/apps/home/logo.png|g' /usr/local/apache2/htdocs/bahmni/home/views/login.html"
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's|../images/bahmniLogoFull.png|/bahmni_config/openmrs/apps/home/logo.png|g' /usr/local/apache2/htdocs/bahmni/home/views/loginLocation.html"
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's/Bahmni Help/Tihut Clinic Help/g' /usr/local/apache2/htdocs/bahmni/home/views/login.html"
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's/Bahmni Help/Tihut Clinic Help/g' /usr/local/apache2/htdocs/bahmni/home/views/loginLocation.html"

# 4. Update page title
docker exec bahmni-standard-bahmni-web-1 sh -c "sed -i 's|<title>Bahmni Home</title>|<title>Tihut Medium Clinic - EMR</title>|g' /usr/local/apache2/htdocs/bahmni/home/index.html"

# 5. Restart services
docker compose restart bahmni-web proxy

echo "Branding applied! Clear your browser cache and reload https://localhost"
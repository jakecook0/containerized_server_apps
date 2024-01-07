#!/bin/bash

rootdomain="reclusivy.com"
namecheap_dns_password=$(cat .env)
namecheap_update_address=https://dynamicdns.park-your-domain.com/update?
subdomains=(www mealie nextcloud @ photos music)

# Get current public IP
public_ip=$(curl -s 'https://api.ipify.org')
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
  echo "failed to get public IP, curl error code: $exit_code"
else
  echo "Public IP: $public_ip"
fi

# Get the current DNS records
current_dns=$(dig www.reclusivy.com +short)
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
  echo "Failed to lookup DNS records, error code: $exit_code"
else
  echo "Current DNS record: $current_dns"
fi

# Compare current vs retrieved public IPs
if [[ "$public_ip" == "$current_dns" ]]; then
  echo "Public IP has not changed, exiting..."
  exit 0
fi

# Update the namecheap DNS entries when record & public IP differ
for subdomain in "${subdomains[@]}"; do
  echo -e "\n\nUpdating record for \"$subdomain.$rootdomain\"\n"
  curl "${namecheap_update_address}host=${subdomain}&domain=${rootdomain}&password=${namecheap_dns_password}&ip=${public_ip}"
  update_err=$?
  if [[ $update_err -ne 0 ]]; then
    echo "Error updating DNS record, error code: $update_err"
  fi
done

---
makina-states.haproxy_registrations.gitlab:
  - frontends:
      {{gitlab_public_http_port}}:
        mode: http
        to_port: {{gitlab_http_port}}
      {{gitlab_public_https_port}}:
        mode: https
        to_port: {{gitlab_http_port}}
        http_fallback: false
        ssl_terminated: true
    hosts: {{gitlab_hosts | to_nice_json}}
    wildcards:
      {% for i in [gitlab_pages_domain] + gitlab_pages_extra_domains %}
      - "*.{{i}}"
      {% endfor %}
    ip: "{{gitlab_ip}}"

{% from 'docker_app/map.jinja' import config with context %}

{%- for app in config.apps %}
{{ app.location }}/.env:
  file.managed:
  - source: salt://docker_app/files/.env.jinja2
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - file_mode: 744
  - context:
      config: {{ config.get(app, {}) }}
      app: {{ app }}

{{ app.location }}/docker-compose.yml:
  file.managed:
  - source:
    - salt://docker_app/files/app.service.jinja2
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - file_mode: 744
  - context:
      config: {{ config.get(app, {}) }}
      app: {{ app }}

/etc/systemd/system/{{ app.name }}.service:
  file.managed:
  - source:
    - salt://docker_app/files/app.service.jinja2
  - template: jinja
  - replace: True
  - context:
      config: {{ config.get(app, {}) }}
      app: {{ app }}

{{ app.name }}:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/systemd/system/{{ app.name }}.service
      - file: {{ app.location }}/docker-compose.yml
      - file: {{ app.location }}/.env
{%- endfor %}
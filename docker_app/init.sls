{% from 'docker_app/map.jinja' import config with context %}


{{ config.app.location }}/.env:
  file.managed:
  - source: salt://docker_app/files/.env.jinja2
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - file_mode: 744

{{ config.app.location }}/docker-compose.yml:
  file.managed:
  - source:
    - salt://docker_app/files/app.service.jinja2
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - file_mode: 744
  - context:
      config: {{ config }}

/etc/systemd/system/{{ config.app.name }}.service:
  file.managed:
  - source:
    - salt://docker_app/files/app.service.jinja2
  - template: jinja
  - replace: True
  - context:
      config: {{ config }}

{{ config.app.name }}:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/systemd/system/{{ config.app.name }}.service
      - file: {{ config.app.location }}/docker-compose.yml
      - file: {{ config.app.location }}/.env
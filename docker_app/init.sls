{% from 'docker_app/map.jinja' import config with context %}

# sudo apt-get install -y jq yq httpie
# sudo apt-get install -y jq httpie
# sudo apt-cache search docker-ce
# sudo apt-get remove docker docker-engine docker.io containerd runc
# sudo apt-get install -y apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

docker_app_pkgs:
  pkg.installed:
  - pkgs:
    - docker-ce
    - docker-ce-cli
    - containerd.io
    - docker-compose

{%- for nw in config.networks | default([]) %}
docker_network_{{ nw.name }}:
  {%- if nw.state == 'present' %}
  docker_network.present:
  {%- else %}
  docker_network.absent:
  {%- endif %}
    - name: {{ nw.name }}
{%- endfor %}

{%- for app in config.apps %}
{{ app.location }}/docker-compose.yml:
  file.managed:
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - mode: 744
  - contents_pillar: docker_app:{{app.name}}:docker_compose_yaml

{{ app.location }}/.env:
  file.managed:
  - source: salt://docker_app/files/env_file.jinja2
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - mode: 744
  - context:
      app: {{ app }}

/etc/systemd/system/{{ app.name }}.service:
  file.managed:
  - source:
    - salt://docker_app/files/app.service.jinja2
  - template: jinja
  - replace: True
  - context:
      app: {{ app }}

{{ app.name }}:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/systemd/system/{{ app.name }}.service
      - file: {{ app.location }}/docker-compose.yml
      - file: {{ app.location }}/.env
#
# Supporting files
#
{%- for file in app.supporting_files | default([]) %}
{%- set default_file_name = app.location ~ "/" ~ file.name %}
{{ app.name }}_{{ file.name }}:
  file.managed:
  # use location if specified otherwise the default location + name
  - name: {{ file.location | default( default_file_name ) }}
  - replace: True
  - makedirs: True
  - mode: {{ file.mode | default(744) }}
  - contents: |
      {{ file.contents }}
{% endfor %}
{%- endfor %}
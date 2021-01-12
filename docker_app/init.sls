{% from 'docker_app/map.jinja' import config with context %}

# sudo apt-get install -y jq yq httpie
# sudo apt-get install -y jq httpie
# sudo apt-cache search docker-ce
# sudo apt-get remove docker docker-engine docker.io containerd runc
# sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

docker_app_pkgs:
  pkg.installed:
  - pkgs:
    - docker-ce
    - docker-ce-cli
    - containerd.io


{%- for app in config.apps %}
{{ app.location }}/.env:
  file.managed:
  - source: salt://docker_app/files/env_file.jinja2
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - mode: 744
  - context:
      app_config: {{ config.get(app.name, {}) }}
      app: {{ app }}

{{ app.location }}/docker-compose.yml:
  file.managed:
  - template: jinja
  - makedirs: True
  - replace: True
  - dir_mode: 755
  - mode: 744
  - contents_pillar: docker_app:{{app.name}}:docker_compose_yaml

/etc/systemd/system/{{ app.name }}.service:
  file.managed:
  - source:
    - salt://docker_app/files/app.service.jinja2
  - template: jinja
  - replace: True
  - context:
      app_config: {{ config.get(app.name, {}) }}
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
{% set filebeat = pillar['filebeat'] %}

add filebeat repo:
  pkgrepo.managed:
    - humanname: filebeat Repo {{ filebeat['repo'] }}
    - name: deb https://artifacts.elastic.co/packages/{{ filebeat['repo'] }}/apt stable main
    - file: /etc/apt/sources.list.d/filebeat.list
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch

install filebeat:
  pkg.installed:
    - name: filebeat
    - version: {{ filebeat['version'] }}
    - hold: {{ filebeat['hold'] | default(False) }}
    - require:
      - pkgrepo: add filebeat repo

filebeat:
  service.running:
    - restart: {{ filebeat['restart'] | default(True) }}
    - enable: {{ filebeat['enable'] | default(True) }}
    - require:
      - install filebeat
    - watch:
      - pkg: filebeat
      {% if salt['pillar.get']('filebeat:config', {}) %}
      - file: /etc/filebeat/filebeat.yml
      {% endif %}
      {% if salt['pillar.get']('filebeat:config', {}) %}
      - file: /etc/filebeat/modules.d/*.yml
      {% endif %}

{% if salt['pillar.get']('filebeat:config') %}
/etc/filebeat/filebeat.yml:
  file.serialize:
    - dataset_pillar: filebeat:config
    - formatter: yaml
    - user: root
    - group: root
    - mode: 644
    - require:
      - install filebeat
{% endif %}

{% if salt['pillar.get']('filebeat:modules') %}
{% for module in pillar.get('filebeat:modules', {}).items() %}
/etc/filebeat/modules.d/{{ module:filename }}.yml:
  file.serialize:
    - dataset_pillar: module:config
    - formatter: yaml
    - user: root
    - group: root
    - mode: 644
    - require:
      - install filebeat
{% endfor %}
{% endif %}

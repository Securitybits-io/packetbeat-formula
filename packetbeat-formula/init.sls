{% set packetbeat = pillar['packetbeat'] %}

add packetbeat repo:
  pkgrepo.managed:
    - humanname: packetbeat Repo {{ packetbeat['repo'] }}
    - name: deb https://artifacts.elastic.co/packages/{{ packetbeat['repo'] }}/apt stable main
    - file: /etc/apt/sources.list.d/packetbeat.list
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch

install packetbeat:
  pkg.installed:
    - name: packetbeat
    - version: {{ packetbeat['version'] }}
    - hold: {{ packetbeat['hold'] | default(False) }}
    - require:
      - pkgrepo: add packetbeat repo

packetbeat:
  service.running:
    - restart: {{ packetbeat['restart'] | default(True) }}
    - enable: {{ packetbeat['enable'] | default(True) }}
    - require:
      - install packetbeat
    - watch:
      - pkg: packetbeat
      {% if salt['pillar.get']('packetbeat:config', {}) %}
      - file: /etc/packetbeat/packetbeat.yml
      {% endif %}

{% if salt['pillar.get']('packetbeat:config') %}
/etc/packetbeat/packetbeat.yml:
  file.serialize:
    - dataset_pillar: packetbeat:config
    - formatter: yaml
    - user: root
    - group: root
    - mode: 644
    - require:
      - install packetbeat
{% endif %}

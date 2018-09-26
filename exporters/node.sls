{% from "prometheus/map.jinja" import exporters with context %}


node_exporter_group:
  group.present:
    - name: {{ exporters.node.group }}
    - system: True

node_exporter_user:
  user.present:
    - name: {{ exporters.node.user }}
    - home: /var/lib/node_exporter
    - gid: {{ exporters.node.group }}
    - system: True

node_exporter_tarball:
  archive.extracted:
    - name: {{ exporters.node.install_dir }}
    - source: {{ exporters.node.source }}
    - source_hash: {{ exporters.node.source_hash }}
    - user: {{ exporters.node.user }}
    - group: {{ exporters.node.group }}
    - archive_format: tar
    - if_missing: {{ exporters.node.version_path }}

node_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/node_exporter
    - target: {{ exporters.node.version_path }}/node_exporter
    - require:
      - archive: node_exporter_tarball

node_exporter_defaults:
  file.managed:
    - name: /etc/default/node_exporter
    - source: salt://exporters/files/default-node_exporter.jinja
    - template: jinja

node_exporter_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/node_exporter.service
    - source: salt://exporters/files/node_exporter.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/node_exporter.conf
    - source: salt://exporters/files/node_exporter.upstart.jinja
{%- endif %}
    - require_in:
      - file: node_exporter_service

node_exporter_service:
  service.running:
    - name: node_exporter
    - enable: True
    - reload: True
    - watch:
      - file: node_exporter_service_unit
      - file: node_exporter_defaults
      - file: node_exporter_bin_link

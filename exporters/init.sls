{%- if pillar.prometheus.exporters is defined %}
include:
  {%- if pillar.prometheus.exporters.node is defined %}
  - prometheus.node_exporter
  {%- endif %}
{%- endif %}

{%- if pillar.prometheus.exporters is defined %}
include:
  {%- if pillar.prometheus.exporters.node is defined %}
  - exporters.node
  {%- endif %}
{%- endif %}

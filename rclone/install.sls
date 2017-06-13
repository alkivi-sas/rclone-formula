# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "rclone/map.jinja" import rclone with context %}
{% set tmp_path = rclone.tmp_dir + '/rclone-v' + rclone.version|string + '-linux-amd64' %}

rclone-temp-dir:
  file.directory:
    - name: {{ rclone.tmp_dir }}
    - mode: 0775

rclone-zip:
  archive.extracted:
    - name: {{ rclone.tmp_dir }}
    - source: https://github.com/ncw/rclone/releases/download/v{{ rclone.version }}/rclone-v{{ rclone.version }}-linux-amd64.zip
    - skip_verify: True
    - if_missing: {{ tmp_path }}

rclone-binary:
  file.copy:
    - name: {{ rclone.binary_dir }}/rclone
    - source: {{ tmp_path }}/rclone
    - mode: 0755
    - user: root
    - group: root
    - require:
      - archive: rclone-zip

rclone-manpage:
  file.copy:
    - name: {{ rclone.manpage_dir }}/rclone.1
    - source: {{ tmp_path }}/rclone.1
    - mode: 0755
    - user: root
    - group: root
    - require:
      - archive: rclone-zip

rclone-update-manpage:
  cmd.wait:
    - name: mandb
    - watch:
      - file: rclone-manpage

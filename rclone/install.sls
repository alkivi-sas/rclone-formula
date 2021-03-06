# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "rclone/map.jinja" import rclone with context %}

{% set arch = grains.get('osarch') %}
{% if arch == 'armhf' %}
{% set arch = 'arm' %}
{% endif %}

{% set tmp_path = rclone.tmp_dir + '/rclone-v' + rclone.version|string + '-linux-' + arch %}

{{ rclone.tmp_dir }}:
  file.directory:
    - makedirs: True
    - mode: 0775

rclone-man-db:
  pkg.installed:
    - name: man-db

rclone-zip:
  archive.extracted:
    - name: {{ rclone.tmp_dir }}
    - source: https://github.com/ncw/rclone/releases/download/v{{ rclone.version }}/rclone-v{{ rclone.version }}-linux-{{ arch }}.zip
    - skip_verify: True
    - if_missing: {{ tmp_path }}

rclone-binary:
  file.copy:
    - name: {{ rclone.binary_dir }}/rclone
    - source: {{ tmp_path }}/rclone
    - mode: 0755
    - user: root
    - group: root
    - force: True
    - unless: diff {{ tmp_path }}/rclone {{ rclone.binary_dir }}/rclone
    - require:
      - archive: rclone-zip

rclone-manpage:
  file.copy:
    - name: {{ rclone.manpage_dir }}/rclone.1
    - source: {{ tmp_path }}/rclone.1
    - mode: 0755
    - user: root
    - group: root
    - force: True
    - unless: diff {{ tmp_path }}/rclone.1 {{ rclone.manpage_dir}}/rclone.1
    - require:
      - pkg: rclone-man-db
      - archive: rclone-zip

rclone-update-manpage:
  cmd.wait:
    - name: mandb
    - watch:
      - file: rclone-manpage

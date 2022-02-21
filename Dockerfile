FROM gentoo/stage3:desktop

COPY entrypoint.sh /entrypoint.sh
COPY old_ver.py /root/.local/bin/old_ver

ENTRYPOINT ["/entrypoint.sh"]

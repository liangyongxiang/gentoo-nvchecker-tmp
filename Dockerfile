FROM ghcr.io/liangyongxiang/gentoo-testing

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

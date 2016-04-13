FROM openshift/base-centos7

RUN yum install -y \
    https://www.softwarecollections.org/en/scls/rhscl/httpd24/epel-7-x86_64/download/rhscl-httpd24-epel-7-x86_64.noarch.rpm && \
    yum install -y --setopt=tsflags=nodocs httpd24 && \
    yum clean all -y

EXPOSE 8080

COPY contrib /opt/app-root
COPY bin/run /usr/bin/run

RUN sed -i -f /opt/app-root/etc/httpdconf.sed /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    head -n151 /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf | tail -n1 | grep "AllowOverride All" || exit && \
    cat /opt/app-root/etc/httpdconf_append.txt >> /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf && \
    chmod -R a+rwx /opt/rh/httpd24/root/var/run/httpd && \
    chown -R 1001:0 /opt/app-root

COPY assets/dist /opt/app-root/src
COPY assets/dist.java /opt/app-root/src

ENV OSC_CONTEXT_ROOT=/
# Default to an "empty" public master URL, this env should always end with the same value as OSC_CONTEXT_ROOT
ENV OSC_ASSET_PUBLIC_URL=/
USER 1001
CMD ["run"]
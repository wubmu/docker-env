FROM n8nio/runners:2.0.2
USER root
# Set pnpm registry to npm mirror
# RUN cd /usr/local/bin && npm config set registry https://registry.npmmirror.com
RUN cd /opt/runners/task-runner-javascript && pnpm add moment uuid
RUN cd /opt/runners/task-runner-javascript && pnpm dlx puppeteer browsers install
# Set UV mirror to Aliyun
RUN cd /opt/runners/task-runner-python && UV_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/ uv pip install numpy pandas markdown html2image
COPY n8n-task-runners.json /etc/n8n-task-runners.json
USER runner
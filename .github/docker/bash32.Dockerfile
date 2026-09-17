ARG BASH32_IMAGE=bash:3.2.57-alpine3.22
FROM ${BASH32_IMAGE}
RUN apk add --no-cache python3 \
    && python3 -c 'import sys; assert sys.version_info >= (3, 10)' \
    && bash --version

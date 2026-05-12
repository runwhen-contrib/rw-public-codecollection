# Production codecollection image — the CCV image the RunWhen platform pulls.
#
# Source FROM the unified rw-base-runtime, which ships:
#   - Python 3 + the worker binary at /home/runwhen/worker
#   - rw-core-keywords pip-installed system-wide (RW.Core / RW.platform /
#     RW.fetchsecrets) and the rw-base-runtime helper scripts at
#     /home/runwhen/robot-runtime/
#   - Standard CLI tooling (kubectl, aws, az, gcloud, helm, gh, jq, yq, ...)
#
# Source: https://github.com/runwhen-contrib/rw-base-runtime
#
# For interactive local development see Dockerfile.devcontainer (referenced
# by .devcontainer.json). It still uses codecollection-devtools and ships
# extra dev tooling. The two image families are intentionally separate
# during the transition; long-term we'll converge.
#
# Override at build time to pin a specific runtime sha or test a BYO base:
#
#   docker build \
#     --build-arg BASE_IMAGE=ghcr.io/runwhen-contrib/rw-base-runtime:<sha7> \
#     ...
#
# The CI workflow (.github/workflows/build-push.yaml) resolves the
# `runtime_ref` dispatch input to an rw-base-runtime commit sha and bakes
# that sha into the resulting image tag suffix.
ARG BASE_IMAGE=ghcr.io/runwhen-contrib/rw-base-runtime:latest
FROM ${BASE_IMAGE}
USER root

ENV RUNWHEN_HOME=/home/runwhen
ENV PATH "$PATH:/usr/local/bin:/home/runwhen/.local/bin"

RUN mkdir -p $RUNWHEN_HOME/codecollection
WORKDIR $RUNWHEN_HOME/codecollection

COPY --chown=runwhen:0 . .

RUN if [ -f "requirements.txt" ]; then pip install --no-cache-dir -r requirements.txt; else echo "requirements.txt not found, skipping pip install"; fi

RUN echo "runwhen ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /var/tmp/runwhen && chmod 1777 /var/tmp/runwhen
ENV TMPDIR=/var/tmp/runwhen

RUN chown runwhen:0 -R $RUNWHEN_HOME/codecollection

USER runwhen

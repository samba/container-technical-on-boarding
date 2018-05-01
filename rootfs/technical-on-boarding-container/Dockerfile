FROM golang:1.9


ARG BUILD

ENV BUILD=${BUILD}
ENV PACKAGE_PATH "/go/src/github.com/samsung-cnct/container-technical-on-boarding"
ENV ONBOARD_TASKS_FILE "/workload/onboarding-issues.yaml"

RUN apt-get -qq update && apt-get install -y -q build-essential

WORKDIR ${PACKAGE_PATH}
COPY . ${PACKAGE_PATH}
COPY .versionfile /

RUN make build
RUN mkdir /workload && \
    cp -v ${PACKAGE_PATH}/onboarding-issues.yaml ${ONBOARD_TASKS_FILE}

VOLUME ["/go/"]
EXPOSE 9000

CMD ["revel", "run", "github.com/samsung-cnct/container-technical-on-boarding"]

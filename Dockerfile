FROM node:8 as app-builder

WORKDIR /app-build

COPY . .
RUN npm run prepublishOnly

FROM node:8

RUN groupadd -r signalk && useradd --no-log-init -r -g signalk signalk
WORKDIR /home/signalk
RUN chown -R signalk /home/signalk
USER signalk


COPY package*.json ./
RUN npm install --only=production

RUN git clone https://github.com/canboat/canboat.git && cd canboat && make bin && make -C analyzer
ENV PATH="/home/signalk/canboat/rel/linux-x86_64:${PATH}"

COPY . .
COPY --from=app-builder /app-build/admin-ui/public admin-ui/public
COPY --from=app-builder /app-build/plugin-config/public plugin-config/public

EXPOSE 3000
ENTRYPOINT bin/signalk-server
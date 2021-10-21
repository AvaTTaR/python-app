FROM python:3.9.7-alpine3.14

COPY ./application/ /home/appuser/app/
WORKDIR /home/appuser/app/

RUN  addgroup -S appgroup && adduser -S appuser -G appgroup && \
    pip3 install aiohttp multidict==4.5.2 yarl==1.3.0 && \
	python3 setup.py install

USER appuser
CMD ["python3", "-m", "demo"]

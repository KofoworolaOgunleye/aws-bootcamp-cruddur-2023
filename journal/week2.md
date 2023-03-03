# Week 2 — Distributed Tracing

* [Required Homework](#required-homework)

## Required Homework

### [HoneyComb](https://docs.honeycomb.io/getting-data-in/opentelemetry/python/)
- Using the api key from honeycomb;
    ```
    export HONEYCOMB_API_KEY=""
    gp env HONEYCOMB_API_KEY=""
    ```
    
    add the following to `docker-compose.yml`
    ```
    OTEL_SERVICE_NAME: 'backend-flask'
    OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
    OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
    ```
- cd into `backend-flask` install opentelementry `pip3 install opentelemetry-api`
- add the following to `requirements.txt` and run `pip3 install -r requirements.txt` to install these packages to instrument a Flask app with OpenTelemetry
```
    opentelemetry-api 
    opentelemetry-sdk 
    opentelemetry-exporter-otlp-proto-http 
    opentelemetry-instrumentation-flask 
    opentelemetry-instrumentation-requests
```
- add the following to `app.py` for honeycomb. These updates will create and initialize a tracer and Flask instrumentation to send data to Honeycomb:

```
    from opentelemetry import trace
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    from opentelemetry.instrumentation.requests import RequestsInstrumentor
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
```

```
    # Initialize tracing and an exporter that can send data to Honeycomb
    provider = TracerProvider()
    processor = BatchSpanProcessor(OTLPSpanExporter())
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    tracer = trace.get_tracer(__name__)
```

```
    # Initialize automatic instrumentation with Flask
    app = Flask(__name__)
    FlaskInstrumentor().instrument_app(app)
    RequestsInstrumentor().instrument()
```
- To create spans, you need to get a Tracer, add the following to `backend-flask > services > home-activities`
```
from opentelemetry import trace

tracer = trace.get_tracer("home.activities")
```
```
# create spans to describe what is happening in your application.

with tracer.start_as_current_span("home-activities-mock-data"):
        # do something
```
```
Adds Attributes to Span, adds instrumentation
      span = trace.get_current_span()
      now = datetime.now(timezone.utc).astimezone()
      span.set_attribute("app.now", now.isoformat()) 
      ...
      span.set_attribute("app.result_length",len(results)) 
      return results
```

- run `docker compose up`
- Check your `honeycomb > home > recent traces`, you should see:
<img width="1579" alt="Screenshot 2023-03-01 at 17 57 30" src="https://user-images.githubusercontent.com/22412589/222222898-f70de2a2-05cd-4257-b649-db775768133d.png">
<img width="1213" alt="Screenshot 2023-03-01 at 17 59 15" src="https://user-images.githubusercontent.com/22412589/222223279-5b07e748-21d3-481c-ad98-a1d2e5d528b7.png">

### XRAY
`Middleware:` it allows you to pass filtering, postprocessing and formatting of incoming request before they reach the application. e.g middleware for authentication, whitelist/blacklist certain addresses, filter file format etc

- Install AWS SDK by adding `aws-xray-sdk` to `backend-flask/requirements.txt` and run `pip3 install -r requirements.txt ` in `backend-flask` folder
- Add the following to `app.py`
```
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

xray_url = os.getenv("AWS_XRAY_URL") # xray url so the endpoint knows where to send the data
xray_recorder.configure(service='backend-flask', dynamic_naming=xray_url)
XRayMiddleware(app, xray_recorder)
```
- set up a sampling rule by adding `aws/json/xray.json`
```
{
  "SamplingRule": {
      "RuleName": "Cruddur",
      "ResourceARN": "*",
      "Priority": 9000,
      "FixedRate": 0.1,
      "ReservoirSize": 5,
      "ServiceName": "Cruddur",
      "ServiceType": "*",
      "Host": "*",
      "HTTPMethod": "*",
      "URLPath": "*",
      "Version": 1
  }
}
```
- create an xray group
```
aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"backend-flask\")"
```

- create a sampling rule, it determines how much information you want to see. To save money, collect data from important data points
`aws xray create-sampling-rule --cli-input-json file://aws/json/xray.json`

- Run xray as a container by add this to `docker-compose.yml` 
```
  xray-daemon:
    image: "amazon/aws-xray-daemon"
    environment:
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      AWS_REGION: "us-east-1"
    command:
      - "xray -o -b xray-daemon:2000"
    ports:
      - 2000:2000/udp
 ```
- add evironment variables to `backend-flask` in `docker-compose.yml`
```
AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
```
- run `docker-compose up`
<img width="1416" alt="Screenshot 2023-03-03 at 12 33 59" src="https://user-images.githubusercontent.com/22412589/222721365-8845dced-2158-4f9d-81ff-b8adfc4e5a47.png">

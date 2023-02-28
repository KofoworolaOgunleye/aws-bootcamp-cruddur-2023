# Week 2 — Distributed Tracing

* [Required Homework](#required-homework)

## Required Homework

### HoneyComb
- Using the api key from honeycomb;
    export HONEYCOMB_API_KEY=""
    gp env HONEYCOMB_API_KEY=""

    add the following to `docker-compose.yml`
    ```
    OTEL_SERVICE_NAME: 'backend-flask'
    OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
    OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
    ```
- install opentelementry `pip3 install opentelemetry-api
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
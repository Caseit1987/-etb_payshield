import os
import json
import uuid
from datetime import datetime, timezone

def generate_stix_bundle(anomaly_data):
    # 1. Initialize Identifiers & Timestamp
    bundle_id = f"bundle--{uuid.uuid4()}"
    indicator_id = f"indicator--{uuid.uuid4()}"
    observed_id = f"observed-data--{uuid.uuid4()}"
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

    # 2. Build STIX 2.1 Indicator Object
    indicator = {
        "type": "indicator",
        "spec_version": "2.1",
        "id": indicator_id,
        "created": timestamp,
        "modified": timestamp,
        "name": f"ETB LayerZero Intercept: {anomaly_data.get('class', 'Unknown Threat Classification')}",
        "description": "Anomalous transactional telemetry structure neutralized at the system boundary gate.",
        "indicator_types": ["malicious-activity"],
        "pattern": f"[network-traffic:dst_port = {os.getenv('GATE_PORT', '8080')}]",
        "pattern_type": "stix",
        "valid_from": timestamp
    }

    # 3. Build STIX 2.1 Observed Data Object
    observed = {
        "type": "observed-data",
        "spec_version": "2.1",
        "id": observed_id,
        "created": timestamp,
        "modified": timestamp,
        "first_observed": timestamp,
        "last_observed": timestamp,
        "number_observed": 1,
        "objects": {
            "0": {
                "type": "file",
                "name": "raw_transaction_payload.json",
                "hashes": {
                    "SHA-256": str(uuid.uuid4().hex) # Placeholder mapping hash value
                }
            }
        }
    }

    # 4. Wrap into a Structured STIX 2.1 Bundle Array
    stix_bundle = {
        "type": "bundle",
        "id": bundle_id,
        "objects": [indicator, observed]
    }
    return stix_bundle

if __name__ == "__main__":
    # Test pipeline parsing logic locally
    sample_anomaly = {"status": "Anomaly Neutralized", "class": "Malformed JSON Input Pattern"}
    compiled_bundle = generate_stix_bundle(sample_anomaly)
    print(json.dumps(compiled_bundle, indent=4))

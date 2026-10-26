#!/usr/bin/env python3
import json
import uuid
import sys
from datetime import datetime, timezone

class STIXMappingEngine:
    def __init__(self):
        self.identity_id = f"identity--{uuid.uuid4()}"
        
    def generate_header_objects(self):
        return {
            "type": "identity",
            "spec_version": "2.1",
            "id": self.identity_id,
            "name": "ETB PayShield Engine",
            "identity_class": "organization",
            "created": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
        }

    def compute_deterministic_priority(self, env, accessibility, criticality):
        env_map = {"production": 1.5, "staging": 1.0, "development": 0.5}
        access_map = {"external": 2.0, "adjacent": 1.0, "internal": 0.5}
        
        env_coeff = env_map.get(env.lower(), 1.0)
        access_weight = access_map.get(accessibility.lower(), 1.0)
        criticality_base = float(criticality)
        
        calculated_score = env_coeff * access_weight * criticality_base
        return round(min(calculated_score, 10.0), 2)

    def process_log_stream(self, line):
        try:
            log_data = json.loads(line)
            
            cve_id = log_data.get("cve_id", "CVE-UNKNOWN")
            asset_id = log_data.get("asset_id", "localhost")
            env = log_data.get("environment", "production")
            accessibility = log_data.get("accessibility", "external")
            criticality = log_data.get("cvss_base", 5.0)
            
            true_risk = self.compute_deterministic_priority(env, accessibility, criticality)
            timestamp = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
            
            vulnerability = {
                "type": "vulnerability",
                "spec_version": "2.1",
                "id": f"vulnerability--{uuid.uuid4()}",
                "name": cve_id,
                "description": f"Risk Score: {true_risk} | Env: {env} | Access: {accessibility}",
                "created": timestamp,
                "modified": timestamp
            }
            
            infrastructure = {
                "type": "infrastructure",
                "spec_version": "2.1",
                "id": f"infrastructure--{uuid.uuid4()}",
                "name": asset_id,
                "description": f"Target Environment Node: {env}",
                "created": timestamp,
                "modified": timestamp
            }
            
            relationship = {
                "type": "relationship",
                "spec_version": "2.1",
                "id": f"relationship--{uuid.uuid4()}",
                "relationship_type": "targets",
                "source_ref": vulnerability["id"],
                "target_ref": infrastructure["id"],
                "created": timestamp,
                "modified": timestamp
            }
            
            bundle = {
                "type": "bundle",
                "id": f"bundle--{uuid.uuid4()}",
                "objects": [
                    self.generate_header_objects(),
                    vulnerability,
                    infrastructure,
                    relationship
                ]
            }
            return bundle
            
        except (json.JSONDecodeError, KeyError, ValueError) as e:
            sys.stderr.write(f"[*] Parse Exception: {str(e)}\n")
            return None

if __name__ == '__main__':
    engine = STIXMappingEngine()
    # Process inputs line by line from standard input
    for line in sys.stdin:
        if line.strip():
            stix_bundle = engine.process_log_stream(line)
            if stix_bundle:
                sys.stdout.write(json.dumps(stix_bundle, indent=2) + '\n')
                sys.stdout.flush()
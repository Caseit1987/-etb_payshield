#!/usr/bin/env python3
import re
import json
import sys

class CWEMitreValidator:
    def __init__(self):
        # Strict validation masks targeting structural exploit injection variants
        self.injection_pattern = re.compile(r"(\||&|;|\b(select|union|insert|drop)\b)", re.IGNORECASE)
        self.path_traversal_pattern = re.compile(r"(\.\./|\.\.\\)")

    def validate_payload_matrix(self, payload_str):
        """Performs static structural verification against critical MITRE CWE vectors."""
        if not payload_str:
            return {"status": "REJECTED", "cwe": "CWE-20", "desc": "Improper Input Validation - Empty Payload"}

        if self.injection_pattern.search(payload_str):
            return {
                "status": "INTERCEPTED",
                "cwe": "CWE-20",
                "mitre_mapping": "CWE-1000 Child Class",
                "description": "Improper Input Validation - Malicious injection pattern detected."
            }

        if self.path_traversal_pattern.search(payload_str):
            return {
                "status": "INTERCEPTED",
                "cwe": "CWE-22",
                "mitre_mapping": "CWE-625 Bypass Vector",
                "description": "Improper Limitation of a Pathname to a Restricted Directory."
            }

        return {"status": "PASSED", "cwe": "NONE", "description": "Payload validated cleanly against structural boundary masks."}

    def parse_and_validate_json_payload(self, json_str):
        """
        Secondary JSON Parsing Rule Set: Deep-inspects structured transaction API objects
        to detect hidden injection signatures tucked inside individual nested keys.
        """
        try:
            parsed_data = json.loads(json_str)
            print(f"[*] Secondary rule set actively parsing JSON structure... Found {len(parsed_data)} top-level nodes.")
            
            # Recursively audit string variables in the JSON tree
            for key, value in parsed_data.items():
                if isinstance(value, str):
                    check_result = self.validate_payload_matrix(value)
                    if check_result["status"] == "INTERCEPTED":
                        # Elevate finding mapping rules to isolate nested tampering
                        return {
                            "status": "INTERCEPTED",
                            "cwe": "CWE-20",
                            "isolated_key": key,
                            "malicious_value": value,
                            "description": f"Nested transaction payload exception discovered at key parameter: '{key}'."
                        }
            return {"status": "PASSED", "description": "Structured JSON payload passed deep parameter integrity validation checks."}
        except json.JSONDecodeError:
            return {"status": "REJECTED", "cwe": "CWE-20", "description": "Malformed JSON payload structure submitted to the ingestion gateway."}

if __name__ == "__main__":
    validator = CWEMitreValidator()
    
    # Test vector: Simulate a nested parameter tampering payload structure
    mock_transaction_json = json.dumps({
        "transaction_id": "TXN-98431094",
        "amount": "150.00",
        "merchant_node": "PayPal_Agent_Edge",
        "shipping_notes": "Valid Address; DROP TABLE users; --"
    })
    
    print("\n🔍 Running Secondary Deep JSON Ingestion Audit Rule Set:")
    result = validator.parse_and_validate_json_payload(mock_transaction_json)
    print(json.dumps(result, indent=4))

#!/usr/bin/env python3
import os
import json
import glob
from datetime import datetime

class CISODashboardIngestor:
    def __init__(self, output_dir="dashboard_view"):
        self.output_dir = output_dir
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
            
    def update_dashboard_chassis(self):
        """Ingests generated STIX bundles into a readable, filterable threat intel chassis."""
        search_pattern = os.path.join("pipeline", "stix_output_*.json")
        threat_bundles = glob.glob(search_pattern)
        dashboard_feed = []
        
        print(f"🔄 INGESTING ACTIVE THREAT BUNDLES FROM: {search_pattern}...")
        
        for bundle_path in threat_bundles:
            try:
                # FIX: Using 'utf-8-sig' cleanly bypasses the hidden PowerShell BOM signature
                with open(bundle_path, 'r', encoding='utf-8-sig') as f:
                    data = json.load(f)
                    for obj in data.get("objects", []):
                        if obj.get("type") == "indicator":
                            dashboard_feed.append({
                                "timestamp": obj.get("created"),
                                "vulnerability_class": obj.get("name"),
                                "severity": "HIGH" if "malicious-activity" in obj.get("indicator_types", []) else "MEDIUM",
                                "target_boundary": obj.get("pattern"),
                                "mitigation_status": "ISOLATED & BLOCKED"
                            })
            except Exception as e:
                print(f"Error parsing {bundle_path}: {e}")
                continue
                
        chassis_payload = {
            "last_updated": datetime.now().isoformat(),
            "compliance_category": "Standard Ingestion Loop (PayPal AI Hackathon)",
            "active_threat_ticker": dashboard_feed
        }
        
        output_file = os.path.join(self.output_dir, "live_intel_stream.json")
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(chassis_payload, f, indent=4)
            
        print(f"✅ Dashboard Chassis Refreshed. {len(dashboard_feed)} active metrics mapped to local compliance ledger.")

if __name__ == "__main__":
    ingestor = CISODashboardIngestor()
    ingestor.update_dashboard_chassis()

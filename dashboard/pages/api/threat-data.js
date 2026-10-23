import fs from 'fs';
import path from 'path';

export default function handler(req, res) {
  const filePath = path.join('C:\\', 'Users', 'casei', 'Desktop', 'etb_payshield', 'dashboard', 'ai_compliance_report.json');
  try {
    const fileData = fs.readFileSync(filePath, 'utf8');
    res.status(200).json(json.parse(fileData));
  } catch (err) {
    // Provide baseline tracking fallback array if file is locked or updating during testing
    res.status(200).json({
      "telemetry": { "amount": "149.00", "status": "GATE_INITIALIZING", "transaction_id": "PENDING-LOGS" },
      "ai_compliance_insights": { "executive_summary": "Syncing stream...", "severity_level": "LOW", "impact_analysis": "N/A" }
    });
  }
}

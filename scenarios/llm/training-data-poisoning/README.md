# Training Data Poisoning
**MITRE ATT&CK:** [T1195](https://attack.mitre.org/techniques/T1195/) — Supply Chain Compromise  
**OWASP LLM Top 10:** [LLM03:2025](https://owasp.org/www-project-top-10-for-large-language-model-applications/) — Training Data Poisoning
**Tactic:** Impact

## Description
Training Data Poisoning occurs when an attacker tampers with the data used to train a machine learning model, causing the model to learn incorrect patterns and produce inaccurate predictions.

> [!NOTE]
> **Training Data Poisoning vs RAG Poisoning**  
> These attacks share a similar vector (tampering with data the model relies on) but operate at different layers. RAG Poisoning corrupts the retrieval layer at inference time — the model itself is unchanged. Training Data Poisoning corrupts the model during training, permanently embedding the poisoned behaviour into its weights. Every prediction the model makes thereafter is affected, and retraining on clean data is required to remediate it.

Training Data Poisoning is commonly associated with **supply chain attacks**, where adversaries target open-source datasets or model repositories used by many downstream consumers. A single poisoned dataset can affect every organisation that trains on it.

In this scenario, a diabetes prediction model classifies patients as diabetic or non-diabetic based on age and blood glucose levels. An attacker with access to the training pipeline poisons the dataset by **flipping labels** for high-risk patients, causing the retrained model to produce dangerous false negatives — predicting non-diabetic for patients who are actually diabetic.

## Remediation
- Restrict write access to training datasets.
- Implement dataset versioning. Never overwrite training data in place. Every dataset version should be **immutable** once registered, with a clear audit trail of who created it and when.
- Implement retraining governance. Training pipeline runs should require explicit authorisation and be logged, particularly in safety-critical domains such as healthcare or finance.
- For third-party/open-source datasets,
  - Treat datasets as untrusted by default. Validate label distributions and statistical properties of external datasets before using them for training.

## References
- [OWASP LLM03:2025 — Training Data Poisoning](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [MITRE ATT&CK T1195 — Supply Chain Compromise](https://attack.mitre.org/techniques/T1195/)
- [Microsoft: Azure ML Dataset Versioning](https://learn.microsoft.com/en-us/azure/machine-learning/how-to-version-track-datasets)
- [Microsoft: Model Monitoring in Azure ML](https://learn.microsoft.com/en-us/azure/machine-learning/concept-model-monitoring)
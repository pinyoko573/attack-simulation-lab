# RAG Poisoning
**MITRE ATT&CK:** [T1565.001](https://attack.mitre.org/techniques/T1565/001/) — Data Manipulation: Stored Data Manipulation  
**OWASP LLM Top 10:** [LLM03:2025](https://owasp.org/www-project-top-10-for-large-language-model-applications/) — Training Data Poisoning  
**Tactic:** Impact

## Description
RAG Poisoning occurs when an attacker tampers with the data source used by a Retrieval-Augmented Generation (RAG) system, causing the LLM to retrieve and present false information as fact.

> [!NOTE]
> **RAG Poisoning vs Indirect Prompt Injection**  
> These attacks share the same vector (poisoning the knowledge base) but differ in goal. Indirect Prompt Injection embeds *executable instructions* in documents to manipulate the model's behaviour. RAG Poisoning injects *false factual content* that the model retrieves and presents as truth, without any manipulation of the model's behaviour or guardrails.

RAG Poisoning is commonly associated with **supply chain attacks**, where adversaries target shared open-source datasets or repositories used by many downstream consumers. A single poisoned dataset can affect every organisation that ingests it.

In this scenario, the target is a medical assistant that provides recommended medication dosages. An attacker with write access to the knowledge source modifies the document to contain dangerous dosage information. Future patients who rely on the assistant's recommendations are exposed to serious health risk.

## Remediation
- Restrict write access to knowledge sources. Only authorised administrators should be able to upload or modify documents in the RAG data source.
- Implement document review workflows. Any new or modified document added to the knowledge base should go through an approval process before being indexed, particularly in environments where multiple staff have upload permissions.
- For third-party/open-source datasets,
  - Maintain an authoritative copy of all knowledge base documents in a separate, write-protected location. Periodically verify that indexed content matches the authoritative source.
  - Treat datasets as untrusted by default. Validate the content before indexing rather than trusting it implicitly.
  - Display the source document and version alongside AI-generated responses. This allows users to verify the information independently and makes tampering more visible.

## References
- [OWASP LLM03:2025 — Training Data Poisoning](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [MITRE ATT&CK T1565.001 — Stored Data Manipulation](https://attack.mitre.org/techniques/T1565/001/)
- [Microsoft: Azure Storage Audit Logging](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-storage-monitoring-scenarios)
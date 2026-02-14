# Services required to simulate attacks

1. AI jailbreak to bypass Entra group-based RBAC on Azure OpenAI
  - Entra ID: Group's ObjectId
  - Logic Apps: Runbook to validate if the email address typed is a member of the Entra ID group
  - Azure OpenAI: Fine-tuning **required**
2. OS Command Injection on Azure OpenAI
  - Functions App: Python function to run `echo <input>`
  - Logic Apps: Runbook to call the Function App
  - Azure OpenAI: Fine-tuning **not required**

# Setup Instructions

This page covers the instructions for setting up the Azure OpenAI and other Azure services required for simulating the attacks, **after deploying Terraform**.

# Functions App

1\. On Azure portal, navigate to Function App > `func-openai-oscommand` and click `http_trigger`

<img width="502" height="204" alt="Image" src="https://github.com/user-attachments/assets/b6a6973c-1a61-4e51-9a9d-53e804e06d3c" />

2\. Paste the code from function_app-oscommand.py and click Save

<img width="514" height="188" alt="Image" src="https://github.com/user-attachments/assets/9d13d85d-e2c3-4ef4-bd3b-dd0fb1bca871" />

# Logic Apps

1\. On Azure portal, navigate to Deploy a custom template and click `Build your own template in the editor`

<img width="638" height="189" alt="Image" src="https://github.com/user-attachments/assets/b4a723e1-51ff-4757-b92c-85e323cd15ad" />

2\. Click Load file with the `template_rbac.json`/`template_oscommand.json` and click Save

<img width="549" height="141" alt="Image" src="https://github.com/user-attachments/assets/7ce6a5c7-4bce-4c66-a73e-69d66b8da6fb" />

3\. Modify the parameters shown

<img width="638" height="276" alt="Image" src="https://github.com/user-attachments/assets/6a18ebbd-bacb-4f76-9236-7144e8cba98e" />

# Azure OpenAI

You can access Azure OpenAI via the *Foundry portal*.

## Fine-tuning

Fine-tuning provides the domain-specific data to the model. Here, training data is used to populate the HR-related FAQs and no validation data/test data is used, so the model sorts of *memorise* instead of *learning* the data.

To learn more about training/validation/test data: Codecademy's [Training Set vs Validation Set vs Test Set](https://www.codecademy.com/article/training-validation-test-set)

1\. On Foundry portal, navigate to Tools > Fine-tuning and click Fine-tune model

<img width="532" height="365" alt="Image" src="https://github.com/user-attachments/assets/7378fd60-ef51-4819-8cbe-69bb56f742f4" />

2\. Choose gpt-4.1-mini (or other mini models if no longer available) and click Next

<img width="532" height="365" alt="Image" src="https://github.com/user-attachments/assets/814992f4-5e26-4083-a082-bde10eb2d62d" />

3\. Click Add training data, Upload files and select `data.jsonl`.

<img width="536" height="404" alt="Image" src="https://github.com/user-attachments/assets/7837a688-8a1f-463d-ba6d-25cf668de3f3" />

4\. Click Apply and Submit.

<img width="541" height="494" alt="Image" src="https://github.com/user-attachments/assets/773c244d-c2b7-4d8a-ab2e-0575ad4a95b6" />

If the attack does not work, redo the steps and set the Seed to 278818263.

## Content Filter

By default, Azure OpenAI blocks any jailbreaking attempts which you need to disable.

1\. On Foundry portal, navigate to Tools > Shared resources and Guardrails + Controls > Content filters and click Create Content Filter.

<img width="628" height="577" alt="Image" src="https://github.com/user-attachments/assets/8bc1b9a8-6438-4aa1-96cc-7076ace4a64a" />

2\. On Input filter and Output filter, adjust the levels as shown.

<img width="1156" height="688" alt="Image" src="https://github.com/user-attachments/assets/852cf291-408b-4dfa-a029-c08f81e811b9" />

<img width="1157" height="688" alt="Image" src="https://github.com/user-attachments/assets/46d3113e-858d-4db6-b9be-9f5fa87d0675" />

3\. Click Create Filter

## Deployments

1\. After the fine-tuning model has been completed, navigate to Shared resources > Deployments and click Deploy model > Deploy fine-tuned model.

<img width="566" height="388" alt="Image" src="https://github.com/user-attachments/assets/c1a33c1a-a831-43cb-b722-121e9a56fadc" />

2\. Select the model, change the Content filter and click Deploy.

<img width="576" height="696" alt="Image" src="https://github.com/user-attachments/assets/a0dd9d56-f40a-494c-a99f-b5d9aabb49a6" />

3\. Navigate to Playgrounds > Assistants and Create an assistant.

<img width="268" height="297" alt="Image" src="https://github.com/user-attachments/assets/69c8364e-fb62-41f5-bb3f-19a4106c5448" />

4\. Use the prompts in `prompt.md` and start chatting!

# Defender for Cloud AI Workload

1\. On Azure Portal, navigate to Microsoft Defender for Cloud > Management > Environment Settings and click on your subscription.

<img width="321" height="125" alt="Image" src="https://github.com/user-attachments/assets/4424987c-aa1a-44f5-92cc-047b4a27c5fb" />

2\. Turn on AI Services and click Save.

<img width="929" height="489" alt="Image" src="https://github.com/user-attachments/assets/ea5d90c9-be45-45fe-9726-2a643d4fa8b1" />

3\. Alerts should be generated within 1~2 minutes after a jailbreaking attack is attempted.
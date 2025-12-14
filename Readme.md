The development of this project utilized the Google Gemini 1.5 Flash model for assistance in refactoring existing code, troubleshooting Terraform configuration blocks, and performing syntax cleanup. All core architectural decisions and functional requirements were defined by the Burhan Ahmed, and all AI-generated output was reviewed, tested, and modified for correctness and alignment with project goals. Specific contributions are noted in file comments where appropriate.


Document Expiry Reminder with API Gateway, Lambda, DynamoDB, EventBridge, and SNS
App Name: OOSOOM (Out of sight out of mind)
Problem
In our daily life, we manage a lot of important documents with varying expiration dates (Passports, Licenses, Insurance Policies, Visas, Memberships etc.). Missing a renewal date can lead to frustrations, legal penalties, travel disruptions, or gaps in coverage. 
Solution
A centralized system that tracks document expirations and proactively alerts users can eliminate these risks.
Demo
Creating user document entry using Lambda CRUD and storing it in DynamoDB. Triggering a reminder notification (SMS, Push, Email etc.) based on selected reminder period. 
Architecture
API Gateway + Lambda to handle CRUD Operations
Dynamo DB for storing document information
Event bridge to trigger daily expiry date checks.
Amazon SNS/SES for notifications 


Benefits
This project gives me hands-on experience with multiple AWS serverless services while addressing a real-world problem. After completing the demo POC for the final presentation, I plan to explore by adding a web or mobile front end that allows users to upload document photos, with OCR and AI automatically extracting key information. Future enhancements could include full document management features, such as marking items as renewed and updating expiration dates seamlessly.

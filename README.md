---
runme:
  id: 01JDMZ1BTQXH9M03YKJ7CJAZ7R
  version: v3
---

# sec-labs

Options to Access the Service in the Browser
1. Use Authentication in the URL
You can include the credentials directly in the URL:

http://user:password@<node-ip>:<node-port>/
For example:

http://user:password@localhost:31779/
Open this URL in your browser.
The browser will automatically use the provided credentials.
2. Use the Authentication Prompt
If you omit the credentials in the URL, the browser should prompt for them:

Open the URL:

http://localhost:31779/
Enter the credentials when prompted:

Username: user
Password: password

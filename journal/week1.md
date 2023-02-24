# Week 1 — App Containerization
- created the notification feature for the frontend and backend
![Screenshot 2023-02-24 at 10 28 58](https://user-images.githubusercontent.com/22412589/221156102-6ee589d2-a2ef-4e73-a242-6e2dd768fa86.png)

# Stretched Homework
  - using the GitPod documentation, I changed gitpod port visibility to public in .gitpod.yml file
  ```
  ports:
  - name: Backend
    port: 4567
    visibility: public
  - name: Frontend
    port: 3000
    visibility: public
  - name: Dynamodb
    port: 8000
    visibility: public
  - name: Postgres
    port: 5432
    visibility: public
  ```
 - Added npm install to .gitpod.yaml file to all npm be automatically installed on launching gitpod
 ```
 - name: npm-install
    init: |
      cd /workspace/aws-bootcamp-cruddur-2023/frontend-react-js
      npm install
  ```

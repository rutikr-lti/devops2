## ansible playbook for deploying application in kubernetes.
#Before running playbook ensure to have below packages installed on both the ansible server and k8s server. 
# or this can be done using ansible command module. 
# 1) yum install pip 
# 2) pip install openshift kubernetes


---
- hosts: 172.31.5.42 #private ip of remote-host, in this case k8s 
  gather_facts: no
  tasks:
    - name: Deploy application in Kubernetes
      k8s:                        #this module is k8s module in which we can define k8s deployment and service scripts using definition module.
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: my-app
            namespace: default
            labels:
              app: my-app
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: my-app
            template:
              metadata:
                labels:
                  app: my-app
              spec:
                containers:
                - name: my-app
                  image: 039612874025.dkr.ecr.ap-south-1.amazonaws.com/my-data:latest 
                  imagePullPolicy: Always
                  ports:
                  - containerPort: 8080
            strategy:
              type: RollingUpdate
              rollingUpdate:
                maxSurge: 1
                maxUnavailable: 1
    - name: Copy service file to target # for this service.yml file must be there on the ansible server.
      copy:
        src: service.yml #path to service file
        dest: /tmp/service.yml #path to copy the file in host(k8s)  server .
 
    - name: Create Kubernetes Service
      command: kubectl apply -f /tmp/service.yml
      register: service_output

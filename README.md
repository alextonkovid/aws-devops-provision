This repository is configured for deploying Prometheus on a K3s cluster.  
Additionally, the Blackbox Exporter operator is installed. You can find more information about it here: [Blackbox Exporter GitHub Repository](https://github.com/prometheus/blackbox_exporter).

### Deployment Instructions

To deploy Prometheus, you need to run the `terraform apply` command. This will:  
1. Provision the resources defined in `aws-devops-provision/provision.tf`.  
2. Execute the script `aws-devops-provision/data/bootstrap-k3s.sh` to set up the environment.  

---

## Submission

- Provide a PR with automation of a Prometheus deployment in Kubernetes with IaC or CI/CD pipeline.
- Provide an output of `kubectl get pods` with running Prometheus.
![alt text](<img/image copy 2.png>)
- Include a screenshot of any metrics (e.g. node disk space usage) shown in the Prometheus web UI.
![alt text](<img/image copy.png>)
- Provide a README file documenting the Prometheus deployment and configuration.

## Evaluation Criteria (100 points for covering all criteria)

1. **Prometheus Installation (20 points)**
   - Prometheus is installed and running on the K8s cluster.
			![alt text](<img/image copy 2.png>)
2. **Deployment Automation (30 points)**
   - Automation of deployment with IaC or CI/CD pipeline is created.
			[provision.tf](provision.tf)
			[bootstrap-k3s.sh](data/bootstrap-k3s.sh)

3. **Web interface is available (10 points)**
   - Metrics can be checked via Prometheus web interface.
			![alt text](<img/image copy.png>)
4. **Metrics Collection (35 points)**
   - Prometheus is collecting essential cluster-specific metrics, such as nodes' memory usage.
			![alt text](img/image.png)
5. **Documentation is created (5 points)**
   - A README file is created or updated documenting the Prometheus deployment and configuration.


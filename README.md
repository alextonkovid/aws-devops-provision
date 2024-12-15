# Alertmanager Configuration and Verification in Grafana

This documentation provides a comprehensive guide to configuring and verifying Alertmanager within Grafana using Helm and Kubernetes. All configurations are managed through code, ensuring reproducibility and version control.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
   - [Helm Installation Command](#helm-installation-command)
   - [Custom `values.yaml` Configuration](#custom-valuesyaml-configuration)
3. [Configuration](#configuration)
   - [Grafana INI Configuration](#grafana-ini-configuration)
   - [Alerting Contact Points Configuration](#alerting-contact-points-configuration)
   - [Alert Rules Configuration](#alert-rules-configuration)
4. [Verification](#verification)
   - [Accessing Grafana](#accessing-grafana)
   - [Testing Alert Rules](#testing-alert-rules)
   - [Verifying Alert Notifications](#verifying-alert-notifications)
5. [Conclusion](#conclusion)

---

## Prerequisites

Before proceeding, ensure you have the following:

- **Kubernetes Cluster**: A running Kubernetes cluster.
- **Helm**: Installed and configured to interact with your Kubernetes cluster.
- **kubectl**: Installed and configured to communicate with your Kubernetes cluster.
- **Domain and SMTP Server**: Accessible SMTP server for sending alert emails.

## Installation

### Helm Installation Command

Use the following Helm command to install or upgrade Grafana in the `monitoring` namespace. This command sets up Grafana with a `NodePort` service type, exposing it on port `32003`.

```bash
helm upgrade -n monitoring --create-namespace --install grafana bitnami/grafana -f ./values.yaml \
  --set service.type=NodePort \
  --set service.nodePorts.grafana=32003
```

**Explanation:**

- `helm upgrade`: Upgrades a release. If the release doesn't exist, it will install it.
- `-n monitoring`: Specifies the Kubernetes namespace as `monitoring`.
- `--create-namespace`: Creates the namespace if it doesn't exist.
- `--install grafana bitnami/grafana`: Installs the `grafana` release using the Bitnami Grafana chart.
- `-f ./values.yaml`: Uses the custom `values.yaml` for configuration.
- `--set service.type=NodePort`: Sets the service type to `NodePort`.
- `--set service.nodePorts.grafana=32003`: Specifies the NodePort for Grafana.

### Custom `values.yaml` Configuration

Create a `values.yaml` file with the following content to customize Grafana's configuration and alerting settings:

```yaml
config:
  useGrafanaIniFile: true
  grafanaIniConfigMap: "grafana-ini"

alerting:
  configMapName: "grafana-contact-points"
```

**Explanation:**

- `config.useGrafanaIniFile`: Enables the use of a custom Grafana INI file.
- `config.grafanaIniConfigMap`: Specifies the name of the ConfigMap containing the Grafana INI configuration.
- `alerting.configMapName`: Specifies the ConfigMap containing alerting contact points.

## Configuration

All configurations are managed through Kubernetes ConfigMaps, ensuring they are version-controlled and easily maintainable.

### Grafana INI Configuration

Create a ConfigMap named `grafana-ini` in the `monitoring` namespace to configure SMTP settings for email alerts.

**File:** `data/grafana/grafana-ini-config-map.yml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-ini
  namespace: monitoring
data:
  grafana.ini: |-
    #################################### SMTP / Emailing ##########################
    [smtp]
    enabled = true
    host = mail.alextonkovid.site:25
    user = mail@alextonkovid.site
    # If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
    password = your-password
    ;cert_file =
    ;key_file =
    skip_verify = true
    from_address = mail@alextonkovid.site
    from_name = Grafana
    # EHLO identity in SMTP dialog (defaults to instance_name)
    ;ehlo_identity = dashboard.example.com
    # SMTP startTLS policy (defaults to 'OpportunisticStartTLS')
    ;startTLS_policy = NoStartTLS
    # Enable trace propagation in e-mail headers, using the 'traceparent', 'tracestate' and (optionally) 'baggage' fields (defaults to false)
    ;enable_tracing = false
```

**Explanation:**

- **SMTP Configuration:**
  - `enabled`: Enables SMTP for email notifications.
  - `host`: SMTP server address and port.
  - `user`: SMTP username.
  - `password`: SMTP password. If it contains special characters like `#` or `;`, wrap it in triple quotes.
  - `skip_verify`: Skips SSL certificate verification (use with caution).
  - `from_address`: The email address from which alerts will be sent.
  - `from_name`: The display name for the sender.

**Apply the ConfigMap:**

```bash
kubectl apply -f data/grafana/grafana-ini-config-map.yml
```

### Alerting Contact Points Configuration

Define contact points for alert notifications by creating a ConfigMap named `grafana-contact-points`.

**File:** `data/grafana/grafana-contact-points-config-map.yml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-contact-points
  namespace: monitoring
data:
  grafana-mail-contact: |-
    type: email
    settings:
      addresses: alex.tonkovid@gmail.com
      singleEmail: false
      message: test
      subject: |
        {{ template "default.title" . }}
```

**Explanation:**

- **Contact Point Configuration:**
  - `type`: Specifies the notification channel type (`email` in this case).
  - `settings.addresses`: List of email addresses to receive alerts.
  - `singleEmail`: If `false`, Grafana sends individual emails for each alert.
  - `message`: The body of the alert email.
  - `subject`: The subject line of the alert email, utilizing Grafana's templating.

**Apply the ConfigMap:**

```bash
kubectl apply -f data/grafana/grafana-contact-points-config-map.yml
```

### Alert Rules Configuration

Configure alert rules to monitor specific metrics. Alerts are defined in YAML files and managed through code.

**Alert Rules to Configure:**

1. **High CPU Utilization on Any Node**
2. **Lack of RAM Capacity on Any Node**

**Example Alert Rule Configuration:**

Create a ConfigMap or use Grafana's provisioning to define alert rules. Here's an example using a ConfigMap.

**File:** `data/grafana/grafana-alert-rules.yml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-alert-rules
  namespace: monitoring
data:
  high-cpu-utilization.yml: |-
    apiVersion: 1
    groups:
      - name: NodeAlerts
        rules:
          - alert: HighCPUUtilization
            expr: avg by(instance) (rate(node_cpu_seconds_total{mode!="idle"}[5m])) > 0.9
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "High CPU utilization detected on {{ $labels.instance }}"
              description: "CPU usage is above 90% for more than 5 minutes."

  low-ram-capacity.yml: |-
    apiVersion: 1
    groups:
      - name: NodeAlerts
        rules:
          - alert: LowRAMCapacity
            expr: node_memory_available_bytes / node_memory_total_bytes < 0.1
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Low RAM capacity on {{ $labels.instance }}"
              description: "Available RAM is below 10% for more than 5 minutes."
```

**Explanation:**

- **HighCPUUtilization Alert:**
  - **expr:** Calculates the average CPU usage excluding idle mode over 5 minutes. Triggers if above 90%.
  - **for:** Duration the condition must persist before firing.
  - **labels.severity:** Sets the alert severity.
  - **annotations:** Provides details for the alert notification.

- **LowRAMCapacity Alert:**
  - **expr:** Calculates the ratio of available RAM to total RAM. Triggers if below 10%.
  - **for:** Duration the condition must persist before firing.
  - **labels.severity:** Sets the alert severity.
  - **annotations:** Provides details for the alert notification.

**Apply the ConfigMap:**

```bash
kubectl apply -f data/grafana/grafana-alert-rules.yml
```

**Note:** Ensure that Grafana is configured to load these alert rules. This might involve additional configuration depending on your Grafana setup.

## Verification

After configuring Alertmanager, it's essential to verify that everything is set up correctly.

### Accessing Grafana

1. **Retrieve Grafana URL:**

   Since Grafana is exposed via a `NodePort` on port `32003`, access it using any Kubernetes node's IP address.

   ```
   http://<Node_IP>:32003
   ```

2. **Login to Grafana:**

   Use your Grafana credentials to log in. If using default credentials:

   - **Username:** `admin`
   - **Password:** Retrieved from the Helm release or set in `values.yaml`.

   ```bash
   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
   ```

### Testing Alert Rules

1. **Navigate to Alerting Section:**

   In Grafana, go to **Alerting** > **Alert Rules** to view the configured alerts.

2. **Simulate Alert Conditions:**

   - **High CPU Utilization:**
     - Use load testing tools or scripts to increase CPU usage on a node.
   - **Low RAM Capacity:**
     - Allocate memory-intensive processes to consume RAM.

3. **Verify Alert Firing:**

   Once the conditions persist for the specified duration (`5m`), alerts should fire and appear in the Alerting dashboard.

### Verifying Alert Notifications

1. **Check Email Inbox:**

   Alerts should trigger emails to `your-email@example.com`. Verify that emails are received with the correct subject and message.

2. **Grafana Alert History:**

   In Grafana, navigate to **Alerting** > **Alert Rules**, select an alert, and view its history to confirm that notifications have been sent.

3. **SMTP Server Logs:**

   Check your SMTP server logs to ensure that emails are being sent from Grafana.

   ```bash
   # Example for checking logs
   kubectl logs <smtp-pod-name> -n <smtp-namespace>
   ```

   Replace `<smtp-pod-name>` and `<smtp-namespace>` with your SMTP server's pod name and namespace.


---

**Additional Tips:**

- **Version Control:** Store all configuration files in a version control system like Git to track changes and collaborate with your team.
- **Security:** Secure sensitive information like SMTP passwords using Kubernetes Secrets instead of ConfigMaps.
- **Monitoring:** Continuously monitor the health of your monitoring stack to ensure alerts are functioning as expected.


---

## Submission

- Provide a PR with the changes in configuration files.
- Include into PR (description or in changes) screenshots of:
  - Contact Points.
  ![alt text](<img/image copy 11.png>)
  - Alert Rules in normal and firing state.
   - firing ![alt text](<img/image copy 10.png>)
   - normal ![alt text](<img/image copy 12.png>)
  - Alert Rules configuration.

   High CPU utilization 
   ![alt text](<img/image copy 14.png>)

   Lack of RAM
   ![alt text](<img/image copy 13.png>)

  - Received emails.
![alt text](<img/image copy 8.png>)  
![alt text](<img/image copy 9.png>)

- Provide a README file documenting the setup and alert configuration.



## Evaluation Criteria 

1. **Contact Points created (10 points)** Done

2. **Alert Rules created (40 points)** Done
   - Alert Rules are configured to send alerts for the following events:
     - High CPU utilization on any node of the cluster.
     - Lack of RAM capacity on any node of the cluster.
   - Alerts are configured to be delivered to your email address.

3. **Alert Rules are working as expected (20 points)** Done
   - Alert Rules are firing when the specified events occur.

4. **Email is received (10 points)** Done

5. **Additional Tasks (20 points)**
   - **Documentation (10 points)**
     - The Alertmanager setup and alert configuration are documented in a README file. Done
   - **Configuration is done completely in code (10 points)**
     - Alert Rules, Contact Points, and SMTP settings are configured using YAML files or other code-based methods.

     [grafana-contact-points-config-map.yml](data/grafana/grafana-contact-points-config-map.yml)

     [grafana-ini-config-map.yml](data/grafana/grafana-ini-config-map.yml)
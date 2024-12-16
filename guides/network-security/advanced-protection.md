# Advanced Network Protection Guide 🌐

## Network Segmentation

### VLAN Configuration
```bash
# Create VLANs
vlan 10 # Corporate
vlan 20 # Guest
vlan 30 # IoT
vlan 40 # Management

# Configure access ports
interface GigabitEthernet0/1
 switchport mode access
 switchport access vlan 10
 switchport port-security
```

### Network Isolation
1. Separate Networks
   - Corporate Network (10.0.10.0/24)
   - Guest Network (10.0.20.0/24)
   - IoT Devices (10.0.30.0/24)
   - Management (10.0.40.0/24)

2. Access Control Lists
```bash
# Block inter-VLAN routing
access-list 100 deny ip 10.0.20.0 0.0.0.255 10.0.10.0 0.0.0.255
access-list 100 deny ip 10.0.30.0 0.0.0.255 10.0.10.0 0.0.0.255
access-list 100 permit ip any any
```

## Intrusion Detection/Prevention

### Suricata Setup
```yaml
# /etc/suricata/suricata.yaml
vars:
  address-groups:
    HOME_NET: "[10.0.0.0/8]"
    EXTERNAL_NET: "!$HOME_NET"

detect-engine:
  - profile: medium
  - custom-rules:
      - protocol: tcp
      - source: external
      - destination: $HOME_NET
```

### Snort Configuration
```bash
# /etc/snort/snort.conf
var HOME_NET 10.0.0.0/8
var EXTERNAL_NET !$HOME_NET

# Rule sets
include $RULE_PATH/emerging-threats.rules
include $RULE_PATH/custom.rules
```

## Advanced Firewall

### Layer 7 Filtering
```nginx
# Application layer filtering
stream {
    upstream backend {
        server 10.0.10.10:80;
    }
    
    server {
        listen 443 ssl;
        proxy_pass backend;
        ssl_protocols TLSv1.2 TLSv1.3;
    }
}
```

### State-based Rules
```bash
# IPTables stateful firewall
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
iptables -P INPUT DROP
```

## Network Monitoring

### Netflow Analysis
```python
from scapy.all import *

def analyze_flow(pkt):
    if IP in pkt:
        print(f"Source: {pkt[IP].src}")
        print(f"Dest: {pkt[IP].dst}")
        print(f"Protocol: {pkt[IP].proto}")

sniff(prn=analyze_flow, store=0)
```

### Traffic Analysis
```powershell
# PowerShell network monitoring
Get-NetAdapterStatistics | 
    Select-Object Name, ReceivedBytes, SentBytes |
    Format-Table -AutoSize
```

## Security Automation

### Auto-Response Script
```python
import subprocess
import re

def detect_attack(log_file):
    attack_patterns = [
        r'multiple failed login attempts',
        r'port scan detected',
        r'unusual outbound traffic'
    ]
    
    with open(log_file, 'r') as f:
        for line in f:
            for pattern in attack_patterns:
                if re.search(pattern, line):
                    block_ip(extract_ip(line))

def block_ip(ip):
    subprocess.run(['iptables', '-A', 'INPUT', '-s', ip, '-j', 'DROP'])
```

## Secure Remote Access

### VPN Configuration
```bash
# OpenVPN server config
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
cipher AES-256-GCM
auth SHA512
tls-crypt ta.key
```

### SSH Hardening
```bash
# /etc/ssh/sshd_config
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers secureuser
MaxAuthTries 3
```

## Threat Detection

### Log Analysis
```python
import re
from collections import defaultdict

def analyze_logs(logfile):
    ip_attempts = defaultdict(int)
    
    with open(logfile, 'r') as f:
        for line in f:
            if 'Failed password' in line:
                ip = re.search(r'\d+\.\d+\.\d+\.\d+', line)
                if ip:
                    ip_attempts[ip.group()] += 1
    
    return {ip: count for ip, count in ip_attempts.items() if count > 5}
```

### Network Scanning
```bash
# Regular network scanning
nmap -sS -sV -p- --script vuln 10.0.0.0/24
```

## Incident Response

### Automated Response
```python
class SecurityIncident:
    def __init__(self):
        self.triggers = {
            'brute_force': self.handle_brute_force,
            'ddos': self.handle_ddos,
            'malware': self.handle_malware
        }
    
    def handle_brute_force(self, source_ip):
        # Block IP
        subprocess.run(['iptables', '-A', 'INPUT', '-s', source_ip, '-j', 'DROP'])
        # Alert security team
        send_alert(f"Brute force attempt from {source_ip}")
    
    def handle_ddos(self, target_ip):
        # Enable DDoS protection
        subprocess.run(['iptables', '-A', 'INPUT', '-p', 'tcp', '--dport', '80', 
                       '-m', 'limit', '--limit', '25/minute', '--limit-burst', '100', 
                       '-j', 'ACCEPT'])
```

## Network Hardening

### Device Hardening
```bash
# Disable unused services
systemctl disable telnet
systemctl disable rsh
systemctl disable tftp

# Enable secure services
systemctl enable fail2ban
systemctl enable auditd
```

### Port Security
```python
def check_open_ports(host):
    """Monitor open ports and alert on unauthorized changes"""
    baseline_ports = {22, 80, 443}
    current_ports = set()
    
    # Scan ports
    for port in range(1, 1025):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((host, port))
        if result == 0:
            current_ports.add(port)
        sock.close()
    
    # Check for unauthorized ports
    unauthorized = current_ports - baseline_ports
    if unauthorized:
        alert(f"Unauthorized ports detected: {unauthorized}")
```

## Best Practices

### Regular Maintenance
1. Weekly Tasks
   - Log review
   - Port scanning
   - Update rules
   - Backup configs

2. Monthly Tasks
   - Security audit
   - Policy review
   - Performance check
   - Threat assessment

### Documentation
- Network diagrams
- Security policies
- Incident responses
- Change management

# Reserved IP Configuration Guide

## Getting a Reserved IP from the Panel

To obtain a reserved IP, follow these steps:

1. Log in to your ParsPack user panel.  
2. From the Cloud Server menu, go to the IP Management section.  
3. Click on the “New IP” button.  
4. Select a server to attach the IP to.  
5. After allocation, you must manually configure the reserved IP on your server’s network interface.

---

## Important Note

- A 30-day fee is charged upfront from your cloud wallet balance.  
- After that, the cost is calculated daily.

---

# Reserved IP Configuration on Different Operating Systems

## ✅ Primary Method (Recommended)

### Ubuntu / Debian (Netplan)

Edit the following file:

```
/etc/netplan/50-cloud-init.yaml
```

Configuration:

```
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 203.0.113.10   # Primary IP (DO NOT REMOVE)
        - <RESERVED_IP>  # Add reserved IP here
      gateway4: 203.0.113.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

Apply changes:

```
sudo netplan apply
```

---

## 🧪 Temporary Method (Testing - All Linux)

Add temporary IP:

```
ip addr add <RESERVED_IP> dev eth0
```

Remove temporary IP:

```
ip addr del <RESERVED_IP> dev eth0
```

---

# Alternative Methods

## Debian / Ubuntu (ifupdown - without Netplan)

Edit:

```
/etc/network/interfaces.d/eth0.cfg
```

Configuration:

```
auto eth0
iface eth0 inet static
    address 203.0.113.10
    netmask 255.255.255.255
    gateway 203.0.113.1
    dns-nameservers 8.8.8.8 1.1.1.1

iface eth0 inet static
    address <RESERVED_IP>
    netmask 255.255.255.255
```

Apply changes:

```
sudo ifdown eth0 && sudo ifup eth0
```

---

## CentOS / RHEL (NetworkManager)

Edit:

```
/etc/sysconfig/network-scripts/ifcfg-eth0
```

Configuration:

```
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=203.0.113.10
NETMASK=255.255.255.255
GATEWAY=203.0.113.1
DNS1=8.8.8.8
DNS2=1.1.1.1

IPADDR2=<RESERVED_IP>
NETMASK2=255.255.255.255
```

Apply changes:

```
sudo systemctl restart NetworkManager
```

---

## AlmaLinux 8/9 (nmtui)

1. Open tool:

```
sudo nmtui
```

2. Edit connection:
- Select Edit a connection
- Choose your network interface (e.g. ens33)
- Go to IPv4 Configuration
- Set Method = Manual

3. Configure:
- Address → <RESERVED_IP>
- Netmask → 255.255.255.255
- Gateway → your network gateway

4. Apply changes:

```
sudo systemctl restart network
```

---

## Windows Server

### PowerShell

```
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "<RESERVED_IP>"
```

---

### GUI Method

1. Control Panel → Network and Sharing Center  
2. Click Change adapter settings  
3. Right-click Ethernet → Properties  
4. Double-click Internet Protocol Version 4 (TCP/IPv4)  
5. Click Advanced  
6. Under IP Addresses, click Add and enter the reserved IP  

---

# Important Notes

- “Unassign” and “Reassign” are not supported for IPs in Iran-based services.  
- Purchasing IP requires wallet balance in your cloud account.  
- Charges are:
  - Upfront (initial)
  - Then calculated daily
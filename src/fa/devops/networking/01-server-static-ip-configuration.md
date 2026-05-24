# راهنمای پیکربندی IP رزرو شده

## دریافت IP رزرو شده از پنل

برای دریافت یک IP رزرو شده، مراحل زیر را دنبال کنید:

1. وارد پنل کاربری پارس پک شوید.  
2. از منوی سرور ابری، به بخش مدیریت IP بروید.  
3. روی دکمه «IP جدید» کلیک کنید.  
4. یک سرور برای اتصال IP انتخاب کنید.  
5. پس از تخصیص، باید IP رزرو شده را به صورت دستی روی رابط شبکه سرور خود پیکربندی کنید.

---

## نکته مهم

- هزینه ۳۰ روزه پیش‌پرداخت از موجودی کیف پول ابری شما کسر می‌شود.  
- پس از آن، هزینه به صورت روزانه محاسبه می‌گردد.

---

# پیکربندی IP رزرو شده روی سیستم‌عامل‌های مختلف

## ✅ روش اصلی (توصیه می‌شود)

### اوبونتو / دبیان (Netplan)

فایل زیر را ویرایش کنید:

```
/etc/netplan/50-cloud-init.yaml
```

پیکربندی:

```
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 203.0.113.10   # IP اصلی (حذف نشود)
        - <RESERVED_IP>  # IP رزرو شده را اینجا اضافه کنید
      gateway4: 203.0.113.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

اعمال تغییرات:

```
sudo netplan apply
```

---

## 🧪 روش موقت (آزمایشی - تمام لینوکس‌ها)

اضافه کردن IP موقت:

```
ip addr add <RESERVED_IP> dev eth0
```

حذف IP موقت:

```
ip addr del <RESERVED_IP> dev eth0
```

---

# روش‌های جایگزین

## دبیان / اوبونتو (ifupdown - بدون Netplan)

ویرایش:

```
/etc/network/interfaces.d/eth0.cfg
```

پیکربندی:

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

اعمال تغییرات:

```
sudo ifdown eth0 && sudo ifup eth0
```

---

## CentOS / RHEL (NetworkManager)

ویرایش:

```
/etc/sysconfig/network-scripts/ifcfg-eth0
```

پیکربندی:

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

اعمال تغییرات:

```
sudo systemctl restart NetworkManager
```

---

## AlmaLinux 8/9 (nmtui)

1. ابزار را باز کنید:

```
sudo nmtui
```

2. اتصال را ویرایش کنید:
- گزینه Edit a connection را انتخاب کنید
- رابط شبکه خود را انتخاب کنید (مثلاً ens33)
- به بخش IPv4 Configuration بروید
- Method را روی Manual تنظیم کنید

3. پیکربندی:
- Address → <RESERVED_IP>
- Netmask → 255.255.255.255
- Gateway → درگاه شبکه خود را وارد کنید

4. اعمال تغییرات:

```
sudo systemctl restart network
```

---

## ویندوز سرور

### پاورشل

```
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "<RESERVED_IP>"
```

---

### روش گرافیکی

1. کنترل پنل → Network and Sharing Center  
2. روی Change adapter settings کلیک کنید  
3. روی Ethernet راست کلیک → Properties  
4. روی Internet Protocol Version 4 (TCP/IPv4) دوبار کلیک کنید  
5. روی Advanced کلیک کنید  
6. در بخش IP Addresses، روی Add کلیک کنید و IP رزرو شده را وارد کنید  

---

# نکات مهم

- عملیات «لغو تخصیص» و «تخصیص مجدد» برای IP در سرویس‌های مستقر در ایران پشتیبانی نمی‌شود.  
- خرید IP نیاز به موجودی کیف پول در حساب ابری شما دارد.  
- هزینه‌ها به صورت زیر است:
  - پیش‌پرداخت (اولیه)
  - سپس محاسبه روزانه

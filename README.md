# 🏗️ iac-deployment-lab

> Proyecto de Infraestructura como Código (IaC) que implementa la gestión integral de un entorno virtualizado sobre **Proxmox**, utilizando **Terraform** para el aprovisionamiento de la infraestructura y **Ansible** para la automatización de la configuración.

---

## 📋 Tabla de contenidos

- [Descripción](#descripción)
- [Arquitectura](#arquitectura)
- [Stack tecnológico](#stack-tecnológico)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Requisitos previos](#requisitos-previos)
- [Despliegue rápido](#despliegue-rápido)
- [Seguridad](#seguridad)
- [Monitorización](#monitorización)
- [Estudio económico](#estudio-económico)
- [Autoras](#autoras)

---

## Descripción

Este proyecto implementa **desde cero** la infraestructura tecnológica completa de una inmobiliaria, integrando todos los bloques de un entorno de producción real:

- Red segmentada por VLANs con firewall perimetral
- Virtualización de todos los servicios en un único servidor físico (Proxmox VE)
- Portal web en contenedores Docker (WordPress + MariaDB)
- Monitorización con Zabbix
- Acceso remoto seguro vía Tailscale
- Proxy inverso con certificados SSL automáticos (Traefik + Let's Encrypt)
- **Despliegue completamente automatizado**: Terraform + Ansible permiten reconstruir toda la infraestructura desde cero en minutos

---

## Arquitectura

### Diagrama de red

```
Internet
    │
    ▼
OPNsense (VM 201) — Firewall · DHCP · VLANs · NAT
    │
    ├── VLAN 10 — Management (10.0.10.0/24)
    │       └── VM 200 · Central-Node   10.0.10.200
    │
    ├── VLAN 20 — Servers (10.0.20.0/24)
    │       └── VM 202 · Zabbix  10.0.20.202
    │
    ├── VLAN 30 — DMZ (10.0.30.0/24)
    │       └── VM 203 · WordPress         10.0.30.203
    │
    └── VLAN 40 — Database (10.0.40.0/24)
            └── VM 204 · MariaDB           10.0.40.204
```

El acceso administrativo remoto se realiza a través de **Tailscale**, sin exponer ningún puerto crítico a internet.

---

## Stack tecnológico

| Categoría | Tecnología |
|---|---|
| Hipervisor | Proxmox VE |
| IaC — Aprovisionamiento | Terraform (`bpg/proxmox` provider) |
| IaC — Configuración | Ansible|
| Firewall / Red | OPNsense · VLANs 802.1Q |
| Web | WordPress + Apache · Docker Compose |
| Base de datos | MariaDB 10.11 |
| SSL | Let's Encrypt |
| Monitorización | Zabbix 7.0 |
| Acceso remoto | Tailscale (WireGuard) |
| DNS dinámico | Dinahosting |
| Backup | Proxmox Backup + estrategia 3-2-1 |

---

## Estructura del repositorio

```
iac-deployment-lab/
├── terraform/
│   ├── main.tf               # Proveedor Proxmox y definición de VMs
│   ├── variables.tf           # Variables (contraseñas marcadas como sensitive)
│   └── modules/
│          └── vm/
│                ├── main.tf        #
│                └── variables.tf   #
├── ansible/
│   ├── inventory.ini           # Inventario de hosts por VLAN
│   └── playbook.yml            # Playbook donde está toda la configuración de los servidores
└── wordpress-docker-proyecto/  # Submodulo: docker-compose donde esta la web dockerizada
    ├── docker-compose.yml
   ...
```

---

## Requisitos previos

- Servidor físico con **Proxmox VE** instalado
- Terraform ≥ 1.6 instalado en el Central-Node
- Ansible ≥ 2.14 instalado en el Central-Node
- Par de claves SSH generado en `~/.ssh/id_rsa`
- Cuenta en [Tailscale](https://tailscale.com) para acceso remoto
- Acceso a la API de Proxmox (`root@pam` o usuario con permisos equivalentes)

---

## Despliegue rápido

### 1. Clonar el repositorio

```bash
git clone --recurse-submodules https://github.com/<usuario>/iac-deployment-lab.git
cd iac-deployment-lab
```

### 2. Configurar Terraform

```bash
cd terraform
export TF_VAR_pm_password="tu_contraseña_proxmox"
terraform init
terraform plan
terraform apply
```

### 3. Ejecutar playbook

```bash
# Desplegar base de datos
ansible-playbook -i inventory.ini playbook.yml
```

---

## Seguridad

La seguridad se implementa mediante **defensa en profundidad**: múltiples capas independientes.

- **Firewall perimetral** (OPNsense): todo el tráfico inter-VLAN pasa por reglas explícitas. Por defecto, todo está bloqueado.
- **Segmentación por VLANs**: la base de datos solo acepta conexiones desde la DMZ en el puerto de MariaDB.
<!-- **Gestión de secretos** (HashiCorp Vault): ninguna contraseña aparece en texto plano en ningún archivo del repositorio. -->
- **Acceso remoto** (Tailscale/WireGuard): la interfaz de Proxmox (`:8006`) no está expuesta a internet.
<!--  **Detección de intrusiones** (CrowdSec): análisis en tiempo real de logs con bloqueo automático de IPs maliciosas. -->
- **TLS automático** (Let's Encrypt): todos los servicios web viajan cifrados.
- **Backup Proxmox + Backups 3-2-1**: 3 copias, 2 soportes distintos, 1 copia en la nube.

---

## Monitorización

Zabbix monitoriza los siguientes hosts y métricas clave:

| Host | IP | Métricas |
|---|---|---|
| Proxmox (host físico) | 192.168.1.220 | CPU, RAM, temperatura, estado de VMs |
| Central-Node | 10.0.10.10 | CPU, RAM, disco |
| WordPress | 10.0.30.204 | CPU, RAM, tiempo de respuesta HTTP |
| MariaDB | 10.0.40.205 | CPU, RAM, conexiones activas, queries lentas |

Alertas configuradas con envío por email para: disco > 80%, servicios caídos, CPU sostenida > 85%, y timeout HTTP.

Acceso a la interfaz: `http://10.0.20.202/zabbix` (requiere Tailscale activo).

---

## Estudio económico

Toda la infraestructura se construye sobre **hardware de segunda mano** y **software open source** exclusivamente.

| Concepto | Importe |
|---|---|
| Servidor Proxmox (torre + HDD 4 TB) | 360 € |
| Switch gestionable + Router | 250 € |
| **Total infraestructura de servidor** | **610 €** |

Costes operativos mensuales de TI: **≈ 15 €/mes** (dominio + backup en nube).

---

## Autoras

- **Joseanía González Cuerdo** - (https://github.com/CuerdoG)
- **Iria Barciela Cabaleiro** - (https://github.com/IriaBarciela) 

Proyecto de Fin de Ciclo · ASIR · 2026


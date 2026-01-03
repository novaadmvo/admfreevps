


<img width="516" height="301" alt="image" src="https://github.com/user-attachments/assets/e947f0c4-51e8-4d4f-84dd-cdaeeb7b42aa" />






# 🚀 ADM FREE — Panel de Administración para VPS (Debian/Ubuntu)

**ADM FREE** es un panel de administración en Bash para servidores VPS que permite gestionar usuarios, conexiones, seguridad y servicios desde una interfaz terminal con un diseño moderno (*ZySSH / Glass / Premium*).

> ⚠️ **Estado:** Esta es una versión **BETA**, funcional en su mayoría.  
> Algunas opciones todavía están en desarrollo o no implementadas por completo.

---

## ✨ Características

- 🖥️ Interfaz terminal interactiva con diseño premium.
- 👤 Gestión completa de usuarios:
  - Crear, borrar, bloquear y desbloquear usuarios.
  - Cambiar contraseñas.
- 🔌 Monitor de conexiones (SSH / Dropbear).
- 🚫 Bloqueo automático de IPs por exceso de conexiones.
- 🔐 Seguridad:
  - Instalación de Fail2Ban
  - Firewall básico
  - Cambiar puerto SSH
- 📦 Instalación de servicios:
  - Dropbear
  - SSL (stunnel)
  - V2Ray
  - Trojan-Go
  - Webmin (instalación corregida con método soportado por sistemas modernos)
- 📊 Información del VPS (uptime, uso de RAM/CPU, disco)
- 🔄 Animaciones de carga y diseño atractivo.
- 📁 Logs para eventos importantes.

---

## 🧪 Estado BETA

Este proyecto **sí es funcional**, pero todavía hay opciones visuales o menús que están en desarrollo o pueden requerir mejoras adicionales antes de estar completos.

No es una versión final, pero es plenamente utilizable en servidores Debian/Ubuntu.

---

## 🔒 Seguridad y Transparencia

ADM FREE está:

✔️ **Libre de minería de criptomonedas**  
✔️ **Libre de procesos ocultos**  
✔️ Código abierto y auditable

No ejecuta tareas en segundo plano sin avisar ni envía datos a terceros.

---

## 🐧 Requisitos del Sistema

- Debian 10 / 11 / 12
- Ubuntu 20.04 / 22.04 / 24.04
- Acceso root

---

## ⚡ Instalación

Ejecuta este comando como **root**:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/novaadmvo/admfreevps/main/adm-free.sh)

```

Ejecuta este comando como **root**:

```bash

adm-free

```

📌 Advertencias

Este script realiza cambios de configuración en el sistema (usuarios, SSH, firewall, etc.).
Usa bajo tu propia responsabilidad y preferiblemente en entornos de pruebas antes de producción.


📞 Créditos

ADM FREE
Desarrollado por GusDev
Telegram: https://t.me/gusdev06



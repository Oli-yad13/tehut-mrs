# Step-by-Step Guide: Running Complete Bahmni Standard System

This guide provides comprehensive instructions for running all 6 core Bahmni services on localhost, including the working solutions for problematic services.

## 🎯 Overview of Services - WORKING CONFIGURATION

Bahmni Standard includes these 6 main services:

1. **Clinical EMR** - Main clinical interface (`https://localhost`)
2. **MRS (OpenMRS)** - Core medical record system (`https://localhost/openmrs`)
3. **Laboratory (OpenELIS)** - Lab management (`https://localhost/openelis`)
4. **Analytics (Metabase)** - Reporting and analytics (`https://localhost/metabase`)
5. **Reports** - Integrated reporting system (accessible via main EMR)
6. **Stock/Inventory (Odoo)** - Inventory management (`http://localhost:8069`)

Optional services:
- **Radiology (DCM4CHEE)** - PACS system (disabled due to configuration issues)
- **Bahmni Connect** - Alternative patient registration (not required with direct Odoo)

## 📋 Prerequisites

1. **Docker Desktop** installed and running
2. **Docker Compose** v2.x or higher
3. **Minimum 8GB RAM** available
4. **Stable internet connection** for initial image downloads
5. **Ports available**: 80, 443, 8069, 5433

## 🚀 Quick Start - All Working Services at Once

### Complete System Startup (Recommended)
```bash
# Navigate to bahmni-standard directory
cd "bahmni-docker/bahmni-standard"

# Step 1: Start core Bahmni services
docker compose --env-file .env up -d

# Step 2: Start laboratory services
docker compose --env-file .env --profile openelis up -d

# Step 3: Start analytics services
docker compose --env-file .env --profile bahmni-mart up -d

# Step 4: Start working inventory system (separate setup)
docker compose -f docker-compose-inventory.yml up -d

# Wait 5-10 minutes for all services to initialize
```

## 🔧 Starting Services Individually

### 1. Clinical EMR & MRS (Core Services) - STEP 1
```bash
cd "bahmni-docker/bahmni-standard"

# Start basic EMR services
docker compose --env-file .env up -d

# Services started:
# - OpenMRS (Medical Records System)
# - Bahmni Web (Clinical interface)
# - Proxy (load balancer)
# - OpenMRS Database
# - Appointments
# - Patient Documents
# - Implementer Interface
# - IPD (Inpatient Department)
# - Reports
```

**Access Points:**
- **Clinical Interface**: `https://localhost` ⭐ **Main Entry Point**
- **OpenMRS Direct**: `https://localhost/openmrs` (NOT localhost:8080)
- **Default Login**: `superman/Admin123`

**Important Notes:**
- Use `https://localhost`, NOT `http://localhost`
- Accept the security certificate warning (self-signed cert)
- OpenMRS is accessed through proxy, not directly on port 8080

### 2. Laboratory (OpenELIS) - STEP 2
```bash
cd "bahmni-docker/bahmni-standard"

# Start OpenELIS services
docker compose --env-file .env --profile openelis up -d

# Wait for services to be ready (2-3 minutes)
```

**Access Points:**
- **Laboratory**: `https://localhost/openelis`
- **Default Login**: `admin/adminADMIN!`

### 3. Analytics (Metabase) - STEP 3
```bash
cd "bahmni-docker/bahmni-standard"

# Start analytics services
docker compose --env-file .env --profile bahmni-mart up -d

# First time setup takes 5-10 minutes
```

**Access Points:**
- **Analytics**: `https://localhost/metabase`
- **First-time setup required** through web interface

### 4. Stock/Inventory (Working Odoo Setup) - STEP 4

**⚠️ Important:** The default Bahmni Odoo has initialization issues. Use this working setup instead:

#### Create Working Odoo Configuration
```bash
cd "bahmni-docker/bahmni-standard"

# Create inventory docker-compose file (if not exists)
cat > docker-compose-inventory.yml << 'EOF'
version: '3.8'

services:
  inventory-db:
    image: postgres:13
    environment:
      POSTGRES_DB: inventory
      POSTGRES_USER: inventory
      POSTGRES_PASSWORD: inventory123
    volumes:
      - inventory_db_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    networks:
      - bahmni-standard_default

  inventory-odoo:
    image: odoo:16.0
    depends_on:
      - inventory-db
    environment:
      HOST: inventory-db
      USER: inventory
      PASSWORD: inventory123
    ports:
      - "8069:8069"
    volumes:
      - inventory_data:/var/lib/odoo
      - ./odoo-config:/etc/odoo
    networks:
      - bahmni-standard_default

volumes:
  inventory_db_data:
  inventory_data:

networks:
  bahmni-standard_default:
    external: true
EOF
```

#### Create Odoo Configuration
```bash
# Create config directory
mkdir -p odoo-config

# Create odoo configuration file
cat > odoo-config/odoo.conf << 'EOF'
[options]
addons_path = /usr/lib/python3/dist-packages/odoo/addons
data_dir = /var/lib/odoo
db_host = inventory-db
db_port = 5432
db_user = inventory
db_password = inventory123
db_name = inventory
xmlrpc_port = 8069
admin_passwd = admin
logfile = None
log_level = info
EOF
```

#### Start Working Inventory System
```bash
# Start working Odoo inventory system
docker compose -f docker-compose-inventory.yml up -d

# Wait 2-3 minutes for startup
```

#### Initialize Inventory Database
```bash
# Initialize database with base modules
docker exec bahmni-standard-inventory-odoo-1 odoo -d inventory --init base --stop-after-init

# Install inventory modules
docker exec bahmni-standard-inventory-odoo-1 odoo -d inventory --init stock,purchase,sale,mrp --stop-after-init

# Restart Odoo service
docker restart bahmni-standard-inventory-odoo-1

# Wait 2-3 minutes for restart
```

**Access Points:**
- **Inventory**: `http://localhost:8069`
- **Default Login**: `admin/admin`
- **Modules**: Stock Management, Purchasing, Sales, Manufacturing

### 5. Reports System
Reports are integrated into the main Clinical EMR system and accessible through:
- **Main EMR Interface**: `https://localhost`
- **Navigate**: Clinical → Reports section

### 6. Radiology (Optional - Issues Present)
⚠️ **Note**: DCM4CHEE has persistent database authentication issues. Disabled by default.

If you want to attempt radiology setup:
```bash
cd "bahmni-docker/bahmni-standard"

# Start PACS services (may fail)
docker compose --env-file .env --profile pacs up -d

# Check logs if issues occur
docker compose logs dcm4chee
```

## 📊 Service Status Commands

### Check All Services
```bash
cd "bahmni-docker/bahmni-standard"

# Check Bahmni core services
docker compose ps

# Check inventory services
docker compose -f docker-compose-inventory.yml ps

# Check all containers
docker ps
```

### Check Service Health
```bash
# Test main interface
curl -I https://localhost -k

# Test laboratory
curl -I https://localhost/openelis -k

# Test analytics
curl -I https://localhost/metabase -k

# Test inventory
curl -I http://localhost:8069

# Check specific service logs
docker compose logs [service-name] -f
```

## 🛠️ Complete System Management

### Daily Startup Sequence
```bash
cd "bahmni-docker/bahmni-standard"

# 1. Start core services
docker compose --env-file .env up -d

# 2. Start laboratory
docker compose --env-file .env --profile openelis up -d

# 3. Start analytics
docker compose --env-file .env --profile bahmni-mart up -d

# 4. Start inventory
docker compose -f docker-compose-inventory.yml up -d

# 5. Verify all services
docker ps
```

### Daily Shutdown Sequence
```bash
cd "bahmni-docker/bahmni-standard"

# Stop inventory
docker compose -f docker-compose-inventory.yml down

# Stop analytics
docker compose --env-file .env --profile bahmni-mart down

# Stop laboratory
docker compose --env-file .env --profile openelis down

# Stop core services
docker compose --env-file .env down
```

## 🚨 Troubleshooting - Updated Solutions

### Problem: Odoo Inventory Internal Server Error
**Symptoms:** HTTP 500 error on localhost:8069

**Solution - Use Working Setup:**
```bash
# Remove problematic Bahmni Odoo
docker compose stop odoo odoo-connect odoodb
docker compose rm -f odoo odoo-connect odoodb
docker volume rm bahmni-standard_odooappdata bahmni-standard_odoodbdata

# Use working inventory setup (see Step 4 above)
docker compose -f docker-compose-inventory.yml up -d
```

### Problem: Main Interface Shows "Down for Maintenance"
**Symptoms:** Maintenance page instead of login

**Solutions:**
```bash
# 1. Stop problematic PACS services
docker compose stop dcm4chee pacs-integration

# 2. Restart proxy
docker compose restart proxy

# 3. Wait 2-3 minutes and try again
curl -I https://localhost -k
```

### Problem: "Not Found" on Service URLs
**Symptoms:** 404 errors on service endpoints

**Solutions:**
```bash
# 1. Verify correct URLs (use HTTPS for most services)
# ✅ Correct: https://localhost/openelis
# ❌ Wrong: http://localhost/openelis

# 2. Check proxy logs
docker compose logs proxy

# 3. Restart proxy if needed
docker compose restart proxy
```

### Problem: OpenMRS Not Accessible on localhost:8080
**Issue:** OpenMRS is only accessible through proxy in this setup

**Correct Access:**
- ❌ Wrong: `http://localhost:8080`
- ✅ Correct: `https://localhost/openmrs`

### Problem: Network Download Timeouts
**Solutions:**
```bash
# Use different approach for inventory
# Instead of: docker compose --profile odoo up -d
# Use: docker compose -f docker-compose-inventory.yml up -d

# Pull images manually if needed
docker pull postgres:13
docker pull odoo:16.0
```

### Problem: Database Connection Issues
**For Standard Odoo Setup:**
```bash
# Check inventory database
docker logs bahmni-standard-inventory-db-1

# Recreate if needed
docker compose -f docker-compose-inventory.yml down -v
docker compose -f docker-compose-inventory.yml up -d
```

## ⏱️ Service Startup Times - Updated

| Service | Initial Startup | Subsequent Startup | Notes |
|---------|----------------|-------------------|-------|
| Core EMR | 3-5 minutes | 1-2 minutes | Includes OpenMRS, Bahmni Web |
| Laboratory (OpenELIS) | 2-3 minutes | 1 minute | Fast startup |
| Analytics (Metabase) | 8-12 minutes | 2-3 minutes | Heavy initialization |
| Inventory (Working Odoo) | 3-5 minutes | 1-2 minutes | Manual DB setup required |
| Reports | Included in Core | Included in Core | No separate startup |
| Proxy & Web | 1-2 minutes | 30 seconds | Fast startup |

## 🔑 Default Credentials - Updated URLs

| Service | URL | Username | Password | Notes |
|---------|-----|----------|----------|-------|
| **Clinical EMR** | `https://localhost` | superman | Admin123 | Main interface ⭐ |
| **OpenMRS** | `https://localhost/openmrs` | admin | Admin123 | Through proxy |
| **Laboratory** | `https://localhost/openelis` | admin | adminADMIN! | Through proxy |
| **Analytics** | `https://localhost/metabase` | Setup Required | Setup Required | First-time setup |
| **Inventory** | `http://localhost:8069` | admin | admin | Working Odoo setup |
| **Reports** | Via Clinical EMR | superman | Admin123 | Integrated |

## 📝 Complete Startup Checklist - Updated

### Pre-Start Checklist
- [ ] Docker Desktop running and connected
- [ ] Minimum 8GB RAM available
- [ ] Ports 80, 443, 8069, 5433 available
- [ ] Stable internet connection
- [ ] In directory: `bahmni-docker/bahmni-standard`
- [ ] Working inventory files created (docker-compose-inventory.yml)

### Startup Checklist
- [ ] Core services started: `docker compose ps`
- [ ] Laboratory started: Check openelis in ps output
- [ ] Analytics started: Check metabase in ps output
- [ ] Inventory started: `docker compose -f docker-compose-inventory.yml ps`
- [ ] No containers show "Exit" or "Restarting" status

### Verification Checklist
- [ ] **Main EMR**: `https://localhost` shows login page ⭐
- [ ] **OpenMRS**: `https://localhost/openmrs` accessible
- [ ] **Laboratory**: `https://localhost/openelis` accessible
- [ ] **Analytics**: `https://localhost/metabase` accessible
- [ ] **Inventory**: `http://localhost:8069` shows Odoo login
- [ ] All services respond within 30 seconds

### Post-Start Testing
- [ ] Login to Clinical EMR successful (superman/Admin123)
- [ ] Can navigate to different modules in EMR
- [ ] Laboratory interface loads (admin/adminADMIN!)
- [ ] Analytics dashboard accessible
- [ ] Inventory system shows Odoo interface (admin/admin)
- [ ] No error messages in service logs

## 🔄 Maintenance Commands - Updated

### Start Complete System
```bash
cd "bahmni-docker/bahmni-standard"

# Single command startup (wait between each)
docker compose --env-file .env up -d && \
sleep 60 && \
docker compose --env-file .env --profile openelis up -d && \
sleep 30 && \
docker compose --env-file .env --profile bahmni-mart up -d && \
sleep 30 && \
docker compose -f docker-compose-inventory.yml up -d

# Verify all running
docker ps
```

### Stop Complete System
```bash
cd "bahmni-docker/bahmni-standard"

# Stop in reverse order
docker compose -f docker-compose-inventory.yml down
docker compose --env-file .env --profile bahmni-mart down
docker compose --env-file .env --profile openelis down
docker compose --env-file .env down
```

### System Health Check
```bash
cd "bahmni-docker/bahmni-standard"

echo "=== Service Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "=== Connection Tests ==="
echo "Main EMR: $(curl -s -I https://localhost -k | head -1)"
echo "Laboratory: $(curl -s -I https://localhost/openelis -k | head -1)"
echo "Analytics: $(curl -s -I https://localhost/metabase -k | head -1)"
echo "Inventory: $(curl -s -I http://localhost:8069 | head -1)"
```

## 🆘 Emergency Procedures

### Complete System Reset
```bash
cd "bahmni-docker/bahmni-standard"

# ⚠️ WARNING: This removes all data!
docker compose down -v
docker compose -f docker-compose-inventory.yml down -v
docker system prune -f

# Restart fresh
docker compose --env-file .env up -d
# Wait and follow startup sequence above
```

### Inventory-Only Reset (Common Need)
```bash
cd "bahmni-docker/bahmni-standard"

# Reset just the inventory system
docker compose -f docker-compose-inventory.yml down -v
docker volume rm bahmni-standard_inventory_db_data bahmni-standard_inventory_data
docker compose -f docker-compose-inventory.yml up -d

# Reinitialize (wait 2 minutes first)
docker exec bahmni-standard-inventory-odoo-1 odoo -d inventory --init base --stop-after-init
docker exec bahmni-standard-inventory-odoo-1 odoo -d inventory --init stock,purchase,sale,mrp --stop-after-init
docker restart bahmni-standard-inventory-odoo-1
```

## 🎯 Quick Reference - Working URLs

### ✅ WORKING SERVICE ACCESS
```
Main Clinical System:    https://localhost
OpenMRS:                https://localhost/openmrs
Laboratory:             https://localhost/openelis
Analytics:              https://localhost/metabase
Inventory:              http://localhost:8069
Reports:                Via https://localhost (Clinical → Reports)
```

### ❌ COMMON MISTAKES TO AVOID
```
❌ http://localhost:8080        (OpenMRS not exposed directly)
❌ http://localhost/openelis    (Use HTTPS)
❌ https://localhost:8069       (Inventory is HTTP only)
❌ http://localhost             (Main EMR requires HTTPS)
```

## 🔗 Service Dependencies

```
Core EMR ← Database (MySQL)
   ↓
Proxy ← Clinical Web, Appointments, Documents
   ↓
OpenELIS ← Database (PostgreSQL)
   ↓
Metabase ← Mart Database (PostgreSQL)
   ↓
Inventory (Separate) ← Database (PostgreSQL)
```

## 📞 Getting Help

1. **Check This Guide First**: Follow step-by-step instructions exactly
2. **Verify URLs**: Use correct HTTPS/HTTP and paths
3. **Check Logs**: `docker compose logs [service-name]`
4. **Service Status**: `docker ps` to verify all running
5. **Community Support**: Bahmni community forums
6. **Issue Reporting**: https://github.com/Bahmni/bahmni-docker/issues

---

**Last Updated:** 2025-09-25
**Version:** Working Configuration v2.0
**Compatible with:** Bahmni Standard v1.0.0+ with working inventory solution

**Status:** ✅ All 6 main services verified working with this configuration
# How to Run Bahmni Lite - Step by Step Guide

A complete guide for new developers to set up and run the Bahmni Lite Medical Record System.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Running the System](#running-the-system)
- [Accessing Services](#accessing-services)
- [Analytics & Metabase](#analytics--metabase)
- [Backup & Restore](#backup--restore)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker Desktop** (version 20.10.13 or higher)
- **Docker Compose** (included with Docker Desktop)
- **Git** (for cloning the repository)
- **PowerShell** or **Command Prompt** (Windows)
- **Terminal** or **Bash** (Linux/Mac)

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Check Git version
git --version
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
# Clone the project
git clone <your-repository-url>
cd bahmni-docker

# Navigate to the Lite version
cd bahmni-lite
```

### 2. Start the System

```bash
# Start all services
docker compose --env-file .env up -d
```

### 3. Access the Application

- **Main Application**: http://localhost
- **Analytics**: http://localhost/metabase

## 📖 Detailed Setup

### Step 1: Clone the Project

```bash
# Clone the repository
git clone <your-repository-url>

# Navigate to the project directory
cd bahmni-docker

# List the contents
ls
```

You should see:
```
bahmni-docker/
├── bahmni-lite/           ← Main EMR system
├── backup_restore/        ← Backup utilities
└── snomed-resources/      ← Medical terminology
```

### Step 2: Navigate to Bahmni Lite

```bash
# Go to the Lite version directory
cd bahmni-lite

# List the contents
ls -la
```

You should see:
```
.env              ← Environment configuration
.env.dev          ← Development environment
docker-compose.yml ← Docker services configuration
backup_bahmni_lite.sh ← Backup script
restore_bahmni_lite.sh ← Restore script
run-bahmni.sh     ← Management script
```

### Step 3: Check Environment Configuration

```bash
# View the environment file
cat .env
```

The `.env` file contains all the configuration variables. The default settings should work for most setups.

### Step 4: Start the System

```bash
# Start all services in the background
docker compose --env-file .env up -d
```

### Step 5: Verify Services are Running

```bash
# Check running containers
docker compose --env-file .env ps

# Or use Docker directly
docker ps
```

## 🏥 Running the System

### Starting Services

```bash
# Start all services
docker compose --env-file .env up -d

# Start with logs visible
docker compose --env-file .env up

# Start specific services only
docker compose --env-file .env up -d openmrs openmrsdb
```

### Stopping Services

```bash
# Stop all services
docker compose --env-file .env down

# Stop and remove volumes (WARNING: This deletes all data!)
docker compose --env-file .env down -v
```

### Restarting Services

```bash
# Restart all services
docker compose --env-file .env restart

# Restart specific service
docker compose --env-file .env restart openmrs
```

### Viewing Logs

```bash
# View logs for all services
docker compose --env-file .env logs

# View logs for specific service
docker compose --env-file .env logs openmrs

# Follow logs in real-time
docker compose --env-file .env logs -f openmrs
```

## 🌐 Accessing Services

### Main Application

- **URL**: http://localhost
- **Default Login**: 
  - Username: `admin`
  - Password: `admin` (check documentation for actual credentials)

### Individual Services

| Service | URL | Description |
|---------|-----|-------------|
| Main App | http://localhost | Bahmni web interface |
| OpenMRS | http://localhost:8080 | Core EMR backend |
| Reports | http://localhost:8080/reports | Reporting system |
| Patient Documents | http://localhost:8080/patient-documents | Document management |

## 📊 Analytics & Metabase

### Starting Metabase (Analytics)

```bash
# Start Metabase services
docker compose --env-file .env --profile metabase up -d

# Check Metabase status
docker compose --env-file .env ps | findstr metabase
```

### Accessing Analytics

- **Metabase Dashboard**: http://localhost/metabase
- **Direct Access**: http://localhost:3000 (if port is exposed)

### Metabase Configuration

1. **First Time Setup**:
   - Open http://localhost/metabase
   - Create admin account
   - Connect to OpenMRS database

2. **Database Connection**:
   - Host: `openmrsdb`
   - Port: `3306`
   - Database: `openmrs`
   - Username: `openmrs`
   - Password: `openmrs` (check .env file)

### Creating Dashboards

1. Go to Metabase dashboard
2. Click "New" → "Dashboard"
3. Add charts and visualizations
4. Connect to OpenMRS data

## 💾 Backup & Restore

### Creating Backups

```bash
# Run backup script
./backup_bahmni_lite.sh

# Or manually backup databases
docker compose --env-file .env exec openmrsdb mysqldump -u openmrs -p openmrs > backup.sql
```

### Restoring from Backup

```bash
# Run restore script
./restore_bahmni_lite.sh

# Or manually restore
docker compose --env-file .env exec -i openmrsdb mysql -u openmrs -p openmrs < backup.sql
```

### What Gets Backed Up

- Patient medical records
- Clinical forms and documents
- Patient images
- Lab results
- System configurations
- All database content

## 🔧 Troubleshooting

### Common Issues

#### 1. Port Already in Use

```bash
# Check what's using port 80
netstat -ano | findstr :80

# Stop conflicting services or change ports in .env
```

#### 2. Services Not Starting

```bash
# Check logs for errors
docker compose --env-file .env logs

# Check Docker status
docker ps -a
```

#### 3. Database Connection Issues

```bash
# Check database container
docker compose --env-file .env logs openmrsdb

# Restart database
docker compose --env-file .env restart openmrsdb
```

#### 4. Metabase Not Loading

```bash
# Start Metabase profile
docker compose --env-file .env --profile metabase up -d

# Check Metabase logs
docker compose --env-file .env logs metabase
```

### Reset Everything

```bash
# Stop all services
docker compose --env-file .env down

# Remove all volumes (WARNING: Deletes all data!)
docker compose --env-file .env down -v

# Remove all containers
docker system prune -a

# Start fresh
docker compose --env-file .env up -d
```

## 📁 Project Structure

```
bahmni-docker/
├── bahmni-lite/                    ← Main EMR system
│   ├── .env                       ← Environment configuration
│   ├── .env.dev                   ← Development environment
│   ├── docker-compose.yml         ← Docker services
│   ├── backup_bahmni_lite.sh      ← Backup script
│   └── restore_bahmni_lite.sh     ← Restore script
├── backup_restore/                ← Backup utilities
│   ├── backup_utils.sh            ← Backup helper functions
│   ├── restore_docker_volumes.sh  ← Volume restore script
│   └── README.md                  ← Backup documentation
└── snomed-resources/              ← Medical terminology
    ├── icd10-extensions-1.0.0-SNAPSHOT.jar ← ICD-10 extensions
    └── load-snowstorm-data.sh     ← SNOMED data loader
```

## 🏥 Services Overview

| Service | Purpose | Port | Profile |
|---------|---------|------|---------|
| proxy | Main entry point | 80, 443 | default |
| openmrs | Core EMR system | 8080 | default |
| openmrsdb | MySQL database | 3306 | default |
| bahmni-web | Web interface | 80 | default |
| bahmni-lab | Laboratory module | 80 | default |
| reports | Reporting system | 8080 | default |
| metabase | Analytics dashboard | 3000 | metabase |
| metabasedb | Analytics database | 5432 | metabase |

## 🚀 Development Commands

### Useful Docker Commands

```bash
# View all containers
docker ps -a

# View all images
docker images

# View all volumes
docker volume ls

# View all networks
docker network ls

# Clean up unused resources
docker system prune

# View resource usage
docker stats
```

### Service Management

```bash
# Start specific service
docker compose --env-file .env up -d openmrs

# Stop specific service
docker compose --env-file .env stop openmrs

# Restart specific service
docker compose --env-file .env restart openmrs

# View service logs
docker compose --env-file .env logs openmrs

# Execute command in container
docker compose --env-file .env exec openmrs bash
```

## 🔀 Git Commands

### Adding Remote Repository

```bash
# Add a remote repository
git remote add origin <repository-url>

# Check existing remotes
git remote -v

# Change remote URL
git remote set-url origin <new-repository-url>

# Remove remote
git remote remove origin
```

### Creating and Switching Branches

```bash
# Create a new branch
git checkout -b <branch-name>

# Create branch from specific commit
git checkout -b <branch-name> <commit-hash>

# Switch to existing branch
git checkout <branch-name>

# Switch to main/master branch
git checkout main
# or
git checkout master

# List all branches
git branch -a

# List local branches only
git branch

# List remote branches only
git branch -r
```

### Branch Management

```bash
# Delete local branch
git branch -d <branch-name>

# Force delete local branch
git branch -D <branch-name>

# Delete remote branch
git push origin --delete <branch-name>

# Rename current branch
git branch -m <new-branch-name>

# Rename any branch
git branch -m <old-branch-name> <new-branch-name>
```

### Pushing and Pulling

```bash
# Push current branch to remote
git push origin <branch-name>

# Push and set upstream
git push -u origin <branch-name>

# Push all branches
git push --all origin

# Pull latest changes
git pull origin <branch-name>

# Pull from main branch
git pull origin main
```

### Basic Git Workflow

```bash
# Clone repository
git clone <repository-url>
cd bahmni-docker

# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to remote
git push -u origin feature/new-feature

# Switch back to main
git checkout main

# Pull latest changes
git pull origin main

# Merge feature branch
git merge feature/new-feature

# Delete feature branch
git branch -d feature/new-feature
```

## 📚 Additional Resources

- [Bahmni Documentation](https://bahmni.atlassian.net/wiki/spaces/BAH)
- [Docker Documentation](https://docs.docker.com/)
- [OpenMRS Documentation](https://docs.openmrs.org/)
- [Metabase Documentation](https://www.metabase.com/docs/)

## 🤝 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Docker and service logs
3. Ensure all prerequisites are installed
4. Verify environment configuration

---

**Happy coding! 🏥✨**

Your Bahmni Lite EMR system is now ready for your clinic!

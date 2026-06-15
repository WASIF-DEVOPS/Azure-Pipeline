# Boardgame App — Architecture

## Overview

A Java Spring Boot board game review application built with a full CI/CD pipeline on Azure DevOps, containerized with Docker, infrastructure managed by Terraform, and hosted on Azure App Service.

---

## Architecture Diagram

```
Developer
    │
    │  git push
    ▼
┌─────────────────────────────────────────────────────────┐
│                        GitHub                           │
│              WASIF-DEVOPS/Azure-Pipeline                │
└─────────────────────┬───────────────────────────────────┘
                      │  trigger (main branch)
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  Azure DevOps Pipeline                  │
│                                                         │
│  ┌──────────┐    ┌─────────────┐    ┌────────────────┐  │
│  │  Stage 1 │───▶│   Stage 2   │───▶│    Stage 3     │  │
│  │  Build   │    │ DockerBuild │    │    Deploy      │  │
│  │          │    │             │    │                │  │
│  │ Maven    │    │ docker build│    │ Azure App      │  │
│  │ compile  │    │ docker push │    │ Service update │  │
│  │ test     │    │             │    │                │  │
│  └──────────┘    └──────┬──────┘    └───────┬────────┘  │
└─────────────────────────┼───────────────────┼───────────┘
                          │                   │
                          ▼                   ▼
              ┌───────────────────┐  ┌────────────────────┐
              │    Docker Hub     │  │       Azure        │
              │                   │  │                    │
              │ wassifstalker/    │  │  ┌──────────────┐  │
              │ boardshack:latest │  │  │ Resource Group│  │
              └───────────────────┘  │  │ boardgame-rg  │  │
                          │          │  └──────┬───────┘  │
                          │          │         │          │
                          │          │  ┌──────▼───────┐  │
                          └──────────┼─▶│  App Service │  │
                                     │  │  Plan (F1)   │  │
                                     │  └──────┬───────┘  │
                                     │         │          │
                                     │  ┌──────▼───────┐  │
                                     │  │  App Service │  │
                                     │  │ boardgame-app│  │
                                     │  │   (Linux)    │  │
                                     │  └──────────────┘  │
                                     └────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Java 17, Spring Boot, Thymeleaf |
| Build Tool | Maven 3.9.9 |
| Containerization | Docker (multi-stage build) |
| Container Registry | Docker Hub |
| CI/CD | Azure DevOps Pipelines |
| Infrastructure | Terraform (azurerm ~3.0) |
| Hosting | Azure App Service (F1 Free) |
| Source Control | GitHub |

---

## CI/CD Pipeline Stages

### Stage 1 — Build
- Triggered on every push to `main` branch
- Runs on `ubuntu-latest` agent
- Maven compiles the Java app
- Runs unit tests
- Publishes test results
- Artifacts saved for next stage

### Stage 2 — DockerBuild
- Downloads artifact from Stage 1
- Builds Docker image using multi-stage Dockerfile
- Stage 1 (build): `maven:3.9.9-eclipse-temurin-17` — compiles JAR
- Stage 2 (runtime): `eclipse-temurin:17-jre-alpine` — runs JAR
- Pushes image to Docker Hub as `wassifstalker/boardshack:latest`

### Stage 3 — Deploy
- Pulls latest image from Docker Hub
- Deploys to Azure App Service `boardgame-app`
- App is live at `https://boardgame-app.azurewebsites.net`

---

## Infrastructure (Terraform)

```
terraform/
├── provider.tf               → Azure provider configuration
├── main.tf                   → Root module, creates Resource Group
├── variable.tf               → Input variables
├── outputs.tf                → Output values (app URL)
├── terraform.tfvars          → Variable values (gitignored)
└── modules/
    └── appservies/
        ├── main.tf           → App Service Plan + App Service
        ├── vaiables.tf       → Module input variables
        └── outputs.tf        → App Service URL output
```

### Resources Created by Terraform

| Resource | Name | SKU |
|---|---|---|
| Resource Group | boardgame-rg | - |
| App Service Plan | boardgame-plan | F1 (Free) |
| App Service | boardgame-app | Linux Container |

---

## Application Structure

```
src/
└── main/
    ├── java/com/javaproject/
    │   ├── beans/            → BoardGame, Review, ErrorMessage models
    │   ├── controllers/      → BoardGameController, HomeController
    │   ├── database/         → DatabaseAccess
    │   └── security/         → SecurityConfig, LoggingAccessDeniedHandler
    └── resources/
        ├── templates/        → Thymeleaf HTML templates
        ├── static/           → CSS, JS, images
        ├── application.properties
        └── schema.sql
```

---

## Azure DevOps Service Connections

| Name | Type | Used For |
|---|---|---|
| docker | Docker Registry (Docker Hub) | Push Docker image |
| azure | Azure Resource Manager | Deploy to App Service |
| WASIF-DEVOPS | GitHub | Trigger pipeline on push |

---

## Flow Summary

```
1. Developer pushes code to GitHub
2. Azure DevOps detects push and triggers pipeline
3. Maven builds JAR and runs tests
4. Docker builds multi-stage image and pushes to Docker Hub
5. Azure App Service pulls new image from Docker Hub
6. App is live and updated at boardgame-app.azurewebsites.net
```

---

## Cost

| Resource | Cost |
|---|---|
| Azure App Service F1 | $0/month (Free) |
| Docker Hub | $0/month (Free) |
| Azure DevOps | $0/month (Free - 1 parallel job) |
| GitHub | $0/month (Free) |
| **Total** | **$0/month** |

# ARCHITECTURE KOLAB - NEXTCLOUD IAAC
 
## 1. Vue d'ensemble
 
L'infrastructure Kolab est une architecture AWS entièrement automatisée via Terraform.
 
Elle est composée de 4 modules principaux :
 
- networking → VPC, subnets, NAT
- security → SG, IAM, KMS, Secrets Manager
- data → RDS PostgreSQL + S3
- compute → ALB + ASG + EC2 Nextcloud
 
---
 
## 2. Schéma global (Mermaid)
```mermaid
flowchart TB
  user((Utilisateur))

  subgraph AWS
    subgraph compute[Compute Module]
      ALB[ALB — HTTPS 443]
      TG[Target Group — HTTP 80]
      ASG[Auto Scaling Group]
      EC2[EC2 — Nextcloud Docker]
    end

    subgraph network[Networking Module]
      VPC[VPC]
      PUB[Public Subnets]
      PRIV[Private Subnets]
    end

    subgraph security[Security Module]
      SGALB[SG ALB]
      SGAPP[SG App]
      IAM[IAM Instance Profile]
      KMS[KMS CMK]
    end

    subgraph data[Data Module]
      RDS[RDS PostgreSQL]
      S3[S3 Buckets]
      SECRETS[Secrets Manager]
    end
  end

  user   --> ALB
  ALB    --> TG
  TG     --> EC2
  ASG    --> EC2
  EC2    --> RDS
  EC2    --> S3
  EC2    --> SECRETS
  VPC    --> ALB
  VPC    --> EC2
  SGALB  --> ALB
  SGAPP  --> EC2
  IAM    --> EC2
  KMS    --> S3
```
 
## 3. Décisions d'architecture
 
#### 1. Auto Scaling uniquement pour HA
Le ASG est configuré en min=1 / desired=1 / max=2 afin de :
 
- assurer la haute disponibilité
- permettre le remplacement automatique en cas de crash
- éviter les problèmes de session Nextcloud sans Redis
 
#### 2. TLS auto-signé
Un certificat auto-signé est généré via le provider TLS.
 
- simplifie le TP
- évite la dépendance DNS / Route53
- accepté uniquement en environnement dev
 
#### 3. Stockage externalisé via S3
Nextcloud utilise S3 comme stockage principal :
 
- scalabilité illimitée
- découplage compute / data
- sécurité renforcée via IAM instance profile
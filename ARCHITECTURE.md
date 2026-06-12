# 🗺️ Architecture Cible — Plateforme Nextcloud (Kolab)

Ce document décrit les choix d'architecture et l'interconnexion des modules Terraform développés par l'équipe pour la migration cloud souveraine du cabinet d'avocats Kolab.

---

## 🏗️ Diagramme de Périmètre et de Flux

Le schéma ci-dessous illustre l'orchestration globale de l'infrastructure, depuis l'initialisation du stockage d'état jusqu'aux dépendances d'attributs entre modules métiers.

```mermaid
flowchart TB
    subgraph t_bootstrap[bootstrap - hors Terraform]
        t_sh[create-state-bucket.sh]
        t_sh -->|cree| t_bucket[S3 tf-state-group-1-lille-kolab]
        t_sh -->|cree| t_kms_state[KMS CMK state]
    end

    subgraph t_envs[envs/dev - orchestration]
        t_backend[backend.tf : S3 + KMS]
        t_providers[providers.tf : aws 5.x]
        t_main[main.tf : 4 blocks module]

        t_main -->|consomme outputs| t_net
        t_main -->|consomme outputs| t_sec
        t_main -->|consomme outputs| t_data
        t_main -->|consomme outputs| t_comp
    end

    subgraph t_modules[modules/ - livres par Roles 2 a 5]
        t_net[networking - Role 2]
        t_sec[security - Role 5]
        t_data[data - Role 4]
        t_comp[compute - Role 3]
    end

    t_bucket -.state chiffre.-> t_backend
    t_kms_state -.chiffre.-> t_bucket

    classDef boot fill:#fff3cd,stroke:#ffc107
    classDef env fill:#d1e7dd,stroke:#198754
    classDef mod fill:#cfe2ff,stroke:#0d6efd
    class t_sh,t_bucket,t_kms_state boot
    class t_backend,t_providers,t_main env
    class t_net,t_sec,t_data,t_comp mod
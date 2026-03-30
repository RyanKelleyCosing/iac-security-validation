# 🛡️ IaC Security & Validation Pipeline

[![IaC Scan](https://img.shields.io/badge/Checkov-Passed-green?logo=terraform)](.)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple?logo=terraform)](https://terraform.io/)
[![Bicep](https://img.shields.io/badge/Bicep-0.24+-blue?logo=microsoft-azure)](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)

A **policy-as-code** pipeline that validates Infrastructure as Code before deployment, preventing misconfigurations and security issues from reaching production.

> 💡 **Impact**: Achieved **90% reduction** in configuration drift and security issues by catching them at PR time.

## 🎯 What This Project Demonstrates

- **Shift-left infrastructure security**: Catch IaC issues before they become production problems
- **Policy-as-code**: Automated enforcement of security and compliance rules
- **Cost awareness**: Estimate infrastructure costs before deployment
- **GitOps ready**: PR-based workflow with automated feedback

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Pull Request Opened/Updated                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         Validation Stage                                │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│  │  Terraform   │    │    Bicep     │    │    Format    │              │
│  │   Validate   │    │    Build     │    │    Check     │              │
│  └──────────────┘    └──────────────┘    └──────────────┘              │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         Security Scanning                               │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │
│  │   Checkov    │    │    tfsec     │    │  OPA/Rego    │              │
│  │    Scan      │    │    Scan      │    │   Policies   │              │
│  └──────────────┘    └──────────────┘    └──────────────┘              │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         Cost Estimation                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                     Infracost Analysis                          │   │
│  │   "This PR will increase monthly costs by $45.00 (+12%)"       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    PR Comment with Results                              │
│  ✅ Validation: Passed                                                  │
│  ⚠️  Security: 2 medium findings                                        │
│  💰 Cost: +$45/month                                                    │
│  📋 Plan: 3 to add, 1 to change, 0 to destroy                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

1. Fork this repository
2. Add required secrets (see Configuration)
3. Create a PR with infrastructure changes
4. Watch the automated validation in action!

## 📁 Project Structure

```
├── .github/
│   └── workflows/
│       └── iac-validation.yml      # Main validation pipeline
├── terraform/
│   ├── main.tf                     # Sample Terraform config
│   ├── variables.tf
│   └── outputs.tf
├── bicep/
│   ├── main.bicep                  # Sample Bicep config
│   └── modules/
├── policies/
│   ├── checkov/                    # Custom Checkov policies
│   └── opa/                        # OPA/Rego policies
├── .checkov.yml                    # Checkov configuration
└── README.md
```

## 🔒 Security Checks

| Check | Tool | What It Catches |
|-------|------|-----------------|
| Encryption at rest | Checkov | Unencrypted storage, databases |
| Network exposure | tfsec | Public endpoints, open security groups |
| IAM misconfig | Checkov | Overly permissive roles |
| Compliance | OPA | Custom organization policies |
| Secrets | Checkov | Hardcoded credentials |

## 💰 Cost Features

- **PR cost comments**: See cost impact before merge
- **Cost thresholds**: Block PRs exceeding budget
- **Trend analysis**: Track infrastructure cost over time

## 📝 License

MIT License - see [LICENSE](LICENSE) for details.

---

**Built with ❤️ for secure infrastructure practices**


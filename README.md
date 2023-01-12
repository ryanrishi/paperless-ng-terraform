paperless-ng-terraform
===

This module creates the necessary resources to run [paperless-ng](https://paperless-ng.readthedocs.io/en/latest/index.html) on AWS.

The resources managed by this module are:
- Aurora RDS (serverless, Postgres)
- ElastiCache (Redis)
- EC2
- security groups, EBS attachments, passwords, etc. for the above 

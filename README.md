paperless-ng-terraform
===

This module creates the necessary resources to run paperless-ng on AWS.

The resources managed by this module are:
- Aurora RDS (serverless, Postgres)
- ElastiCache (Redis)
- EC2
- security groups, EBS attachments, passwords, etc. for the above 

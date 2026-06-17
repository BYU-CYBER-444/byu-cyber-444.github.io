---
title: "IT LAB 10 - Cloud IAM & Security Configuration"
parent: Labs
nav_order: 110
---

# IT LAB 10 - Cloud IAM & Security Configuration
{: .no_toc }

**Duration:** ~3 hours &nbsp;·&nbsp; **Week:** Week 10 &nbsp;·&nbsp; **Track:** IT
{: .fs-5 }

<details open markdown="block">
  <summary>Contents</summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Objectives

- Design and implement least-privilege IAM policies using identity-based and resource-based controls
- Configure IAM roles for EC2 instances and cross-account access patterns
- Enable CloudTrail with log integrity validation and CloudWatch alerting for privilege escalation
- Implement AWS Config rules for continuous compliance monitoring
- Conduct an IAM access review using AWS Access Analyzer and remediate findings

---

## Tools Required

- AWS Academy Learner Lab or equivalent sandbox
- AWS CLI v2
- Python 3 (for Lambda functions)
- `jq` for JSON parsing

---

## Background

Cloud IAM is the most frequently misconfigured control in AWS environments. The 2019 Capital One breach ($80M fine) resulted from an overly permissive EC2 instance role that could call `s3:GetObject` across all buckets - a classic violation of least privilege. AWS IAM follows a deny-by-default model: permissions must be explicitly granted, and explicit denies always override allows.

---

## Procedure

### Part 1 - Least-Privilege IAM Policy Design (45 min)

**1.1 Scenario-based policy writing**

Write least-privilege IAM policies for each of the following roles. Each policy must use specific actions (not `*`), specific resources (not `*`), and include meaningful condition keys where appropriate.

**Role A: S3 Read-Only for Application Logs**
The application running on EC2 instance `i-0abc123` needs to read objects from `s3://app-logs-prod/` but must NOT be able to list bucket contents or delete objects.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3ObjectRead",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::app-logs-prod/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

**Role B: DynamoDB CRUD for a specific table**
A Lambda function needs to create, read, update, and delete items in `DynamoDB:sessions-table` only. It must NOT access any other DynamoDB table.

Write this policy. Include `dynamodb:DescribeTable` (required for connection setup) and the specific table ARN.

**Role C: EC2 Describe-only for a monitoring tool**
A monitoring service needs to list all EC2 instances and their tags across the account but must NOT start, stop, or modify any instance.

Write this policy. Note: `ec2:Describe*` permissions are not resource-level - they only apply to `"Resource": "*"`. This is a known AWS limitation; document why it exists and what the risk is.

**1.2 Policy validation**

For each policy, use the IAM Policy Simulator or CLI to validate:

```bash
# Test policy A
aws iam simulate-principal-policy \
    --policy-source-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AppRole" \
    --action-names "s3:GetObject" "s3:DeleteObject" "s3:ListBucket" \
    --resource-arns "arn:aws:s3:::app-logs-prod/logfile.gz"
```

Document which actions are allowed vs. denied and confirm they match your intent.

---

### Part 2 - IAM Roles for EC2 and Cross-Account Access (30 min)

**2.1 EC2 Instance Role**

Create an IAM role for EC2 instances that need to write metrics to CloudWatch:

```bash
# Create trust policy
cat > ec2-trust.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role --role-name CloudWatchMetricsWriter \
    --assume-role-policy-document file://ec2-trust.json \
    --description "Allows EC2 instances to write custom metrics to CloudWatch"

# Create the permission policy
cat > cloudwatch-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ec2:DescribeTags"
    ],
    "Resource": "*",
    "Condition": {
      "StringEquals": {"cloudwatch:namespace": "LabMetrics"}
    }
  }]
}
EOF

aws iam put-role-policy --role-name CloudWatchMetricsWriter \
    --policy-name CloudWatchMetricsPolicy \
    --policy-document file://cloudwatch-policy.json

# Create instance profile
aws iam create-instance-profile --instance-profile-name CloudWatchMetricsWriter
aws iam add-role-to-instance-profile \
    --instance-profile-name CloudWatchMetricsWriter \
    --role-name CloudWatchMetricsWriter
```

**2.2 Cross-account role pattern**

Document (without implementing, since you have one account) the cross-account assume-role pattern:
- Account A (prod): Contains the resource (S3 bucket)
- Account B (dev): Developer needs read access to prod logs for debugging

Write the two-part configuration:
1. Trust policy in Account A that allows Account B's role to assume it
2. Permission policy in Account B that grants the developer `sts:AssumeRole` for the Account A role

Explain why this is safer than creating an IAM user in Account A with direct access credentials. Address: credential rotation, audit trail, time-limited sessions.

---

### Part 3 - CloudTrail and Privilege Escalation Detection (45 min)

**3.1 Enable CloudTrail with log integrity**

```bash
# Create S3 bucket for CloudTrail logs
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TRAIL_BUCKET="cloudtrail-logs-${ACCOUNT_ID}"

aws s3api create-bucket --bucket $TRAIL_BUCKET --region us-east-1
aws s3api put-bucket-policy --bucket $TRAIL_BUCKET --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [{
    \"Sid\": \"AWSCloudTrailAclCheck\",
    \"Effect\": \"Allow\",
    \"Principal\": {\"Service\": \"cloudtrail.amazonaws.com\"},
    \"Action\": \"s3:GetBucketAcl\",
    \"Resource\": \"arn:aws:s3:::${TRAIL_BUCKET}\"
  },{
    \"Sid\": \"AWSCloudTrailWrite\",
    \"Effect\": \"Allow\",
    \"Principal\": {\"Service\": \"cloudtrail.amazonaws.com\"},
    \"Action\": \"s3:PutObject\",
    \"Resource\": \"arn:aws:s3:::${TRAIL_BUCKET}/AWSLogs/${ACCOUNT_ID}/*\",
    \"Condition\": {\"StringEquals\": {\"s3:x-amz-acl\": \"bucket-owner-full-control\"}}
  }]
}"

# Create the trail
aws cloudtrail create-trail \
    --name lab-trail \
    --s3-bucket-name $TRAIL_BUCKET \
    --is-multi-region-trail \
    --enable-log-file-validation \
    --include-global-service-events

aws cloudtrail start-logging --name lab-trail
```

**3.2 Create CloudWatch metric filter for privilege escalation**

Privilege escalation events (IAM policy attachment, role creation) should trigger immediate alerts:

```bash
# Create log group for CloudTrail
aws logs create-log-group --log-group-name /cloudtrail/lab-trail

# Update trail to send to CloudWatch Logs
# (requires a CloudWatch Logs role - create first)
cat > cloudtrail-cloudwatch-trust.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "cloudtrail.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role --role-name CloudTrailCloudWatchRole \
    --assume-role-policy-document file://cloudtrail-cloudwatch-trust.json

aws iam put-role-policy --role-name CloudTrailCloudWatchRole \
    --policy-name CloudTrailLogsPolicy \
    --policy-document '{
      "Version":"2012-10-17",
      "Statement":[{
        "Effect":"Allow",
        "Action":["logs:CreateLogStream","logs:PutLogEvents"],
        "Resource":"arn:aws:logs:*:*:log-group:/cloudtrail/lab-trail:*"
      }]
    }'

# Create metric filter for IAM privilege escalation
aws logs put-metric-filter \
    --log-group-name /cloudtrail/lab-trail \
    --filter-name "IAMPrivilegeEscalation" \
    --filter-pattern '{($.eventName=AttachRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreateRole) || ($.eventName=AttachUserPolicy)}' \
    --metric-transformations \
        metricName=IAMPrivilegeEscalationAttempts,metricNamespace=SecurityAlerts,metricValue=1

# Create CloudWatch alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "IAMPrivilegeEscalationDetected" \
    --alarm-description "Alert on any IAM privilege escalation event" \
    --metric-name IAMPrivilegeEscalationAttempts \
    --namespace SecurityAlerts \
    --statistic Sum \
    --period 300 \
    --threshold 1 \
    --comparison-operator GreaterThanOrEqualToThreshold \
    --evaluation-periods 1 \
    --alarm-actions "arn:aws:sns:us-east-1:${ACCOUNT_ID}:SecurityAlerts"
```

**3.3 Trigger and verify the alarm**

Create an IAM role (legitimate action) and verify the alarm fires:

```bash
aws iam create-role --role-name TestRole \
    --assume-role-policy-document file://ec2-trust.json

# Wait a few minutes, then check alarm state
aws cloudwatch describe-alarms --alarm-names "IAMPrivilegeEscalationDetected" \
    --query "MetricAlarms[0].StateValue"
```

---

### Part 4 - AWS Config Compliance Rules (30 min)

AWS Config continuously evaluates your resources against defined rules and marks them COMPLIANT or NON_COMPLIANT.

```bash
# Enable AWS Config recorder
aws configservice put-configuration-recorder \
    --configuration-recorder name=default,roleARN="arn:aws:iam::${ACCOUNT_ID}:role/config-role"

# Create delivery channel
aws configservice put-delivery-channel \
    --delivery-channel name=default,s3BucketName=$TRAIL_BUCKET

aws configservice start-configuration-recorder --configuration-recorder-name default

# Deploy managed rules
aws configservice put-config-rule --config-rule '{
  "ConfigRuleName": "ec2-imdsv2-check",
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "EC2_IMDSV2_CHECK"
  }
}'

aws configservice put-config-rule --config-rule '{
  "ConfigRuleName": "iam-password-policy",
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "IAM_PASSWORD_POLICY"
  }
}'

aws configservice put-config-rule --config-rule '{
  "ConfigRuleName": "s3-bucket-public-read-prohibited",
  "Source": {
    "Owner": "AWS",
    "SourceIdentifier": "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}'
```

After a few minutes, check compliance:

```bash
aws configservice describe-compliance-by-config-rule \
    --config-rule-names ec2-imdsv2-check iam-password-policy s3-bucket-public-read-prohibited \
    --query "ComplianceByConfigRules[*].[ConfigRuleName,Compliance.ComplianceType]" \
    --output table
```

For any NON_COMPLIANT rule, identify the specific non-compliant resources and document what remediation is required.

---

### Part 5 - IAM Access Analyzer Review (30 min)

AWS Access Analyzer identifies resource policies that grant access to external principals - potential unintended exposure.

```bash
# Create an analyzer
aws accessanalyzer create-analyzer \
    --analyzer-name lab-analyzer \
    --type ACCOUNT

# Wait for initial scan (2-3 minutes), then list findings
aws accessanalyzer list-findings \
    --analyzer-arn "arn:aws:access-analyzer:us-east-1:${ACCOUNT_ID}:analyzer/lab-analyzer" \
    --query "findings[*].[id,resourceType,resource,status]" \
    --output table
```

For each finding:
1. Record the resource ARN, finding type, and external principal
2. Determine: Is this intended access or unintended exposure?
3. Archive intended findings; propose remediation for unintended ones

Write a 200-word **Access Review Summary** suitable for a security audit:
- Total findings
- How many were intentional vs. unintentional
- Remediations applied
- Ongoing monitoring recommendation

---

## Deliverables

1. Three least-privilege IAM policies with Policy Simulator validation output
2. IAM role creation commands + cross-account pattern documentation
3. CloudTrail configuration + metric filter + alarm configuration commands
4. Alarm trigger verification screenshot or CLI output
5. AWS Config rule compliance report (`describe-compliance` output)
6. Access Analyzer findings table + 200-word Access Review Summary

---

## Grading

| Item | Points |
|------|--------|
| Least-privilege policies (3) with validation | 25 |
| EC2 role + cross-account pattern explanation | 15 |
| CloudTrail + privilege escalation alarm | 25 |
| AWS Config compliance rules + report | 20 |
| Access Analyzer review + summary | 15 |
| **Total** | **100** |

---

{: .callout-grad }
> ##  Graduate Extension (CS/IT 544 - Master's Students Only)
>
> **This section is required for graduate students. +30 points.**
>
> ### Extension A - Automated IAM Remediation with AWS Lambda
>
> Continuous compliance requires automated remediation, not just detection. Build an event-driven remediation system:
>
> 1. Create a Lambda function triggered by an EventBridge rule that fires whenever `CreateAccessKey` is called for the root user (a critical security violation).
>
> 2. The Lambda should: (a) log the event details to CloudWatch Logs, (b) send an SNS notification with event context, (c) attempt to delete the newly created root access key using `iam:DeleteAccessKey` (this may fail due to permissions - document why and what the correct remediation is).
>
> 3. Create a second Lambda triggered by Config non-compliance events for `ec2-imdsv2-check`. When a non-compliant instance is detected, the Lambda should modify the instance metadata options to require IMDSv2.
>
> Test both Lambdas and provide CloudWatch Logs output showing successful execution.
>
> ### Extension B - Permission Boundary Deep Dive
>
> Permission Boundaries are an advanced IAM feature that cap the maximum permissions an IAM entity can have, regardless of what policies are attached. This enables delegation without privilege escalation.
>
> 1. Create a Permission Boundary policy that allows a "developer" role to create IAM roles but constrains those roles to never have `iam:*` or `sts:AssumeRole` on all resources.
>
> 2. Create a developer role with the Permission Boundary attached. Show that: (a) the developer can create a new role, but (b) the developer cannot create a role that has IAM admin permissions (even if they attach an AdministratorAccess policy).
>
> 3. Write a 300-word explanation of how Permission Boundaries enable "delegation without privilege escalation" and why this is valuable in large organizations with multiple teams managing their own IAM resources.
>
> Submit Lambda function code + execution logs, and Permission Boundary policy + demonstration of privilege escalation prevention.

[← Back to Labs]({{ site.baseurl }}/labs/)

#!/usr/bin/env bash
# bootstrap/create-state-bucket.sh
# Script d'initialisation One-Shot du Backend distant sécurisé

set -euo pipefail

USERNAME="kolab-team1"
REGION="eu-west-3" # Forcé sur Paris

BUCKET="tf-state-${USERNAME}-kolab"
KMS_ALIAS="alias/tf-state-${USERNAME}"

echo "=== 1. Creation de la Clé KMS CMK pour le State ==="
KMS_KEY_ID=$(aws kms list-aliases --region "${REGION}" \
  --query "Aliases[?AliasName=='${KMS_ALIAS}'].TargetKeyId" --output text)

if [ -z "${KMS_KEY_ID}" ] || [ "${KMS_KEY_ID}" == "None" ]; then
  KMS_KEY_ID=$(aws kms create-key \
    --region "${REGION}" \
    --description "CMK chiffrement du state Terraform Kolab Team 1" \
    --key-usage ENCRYPT_DECRYPT \
    --key-spec SYMMETRIC_DEFAULT \
    --query 'KeyMetadata.KeyId' --output text)

  aws kms enable-key-rotation --region "${REGION}" --key-id "${KMS_KEY_ID}"
  aws kms create-alias --region "${REGION}" --alias-name "${KMS_ALIAS}" --target-key-id "${KMS_KEY_ID}"
else
  echo "La clé KMS ${KMS_ALIAS} existe déjà."
fi

KMS_KEY_ARN=$(aws kms describe-key --region "${REGION}" --key-id "${KMS_KEY_ID}" --query 'KeyMetadata.Arn' --output text)

echo "=== 2. Creation du Bucket S3 ==="
if aws S3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "Le bucket ${BUCKET} existe déjà."
else
  aws S3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}" \
    --create-bucket-configuration "LocationConstraint=${REGION}"
fi

aws S3api put-bucket-versioning --bucket "${BUCKET}" --versioning-configuration Status=Enabled

aws S3api put-bucket-encryption --bucket "${BUCKET}" --server-side-encryption-configuration "{
    \"Rules\": [{
      \"ApplyServerSideEncryptionByDefault\": {
        \"SSEAlgorithm\": \"aws:kms\",
        \"KMSMasterKeyID\": \"${KMS_KEY_ARN}\"
      },
      \"BucketKeyEnabled\": true
    }]
  }"

aws S3api put-public-access-block --bucket "${BUCKET}" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Bootstrap terminé avec succès pour ${BUCKET} !"
module "sa" {
  source = "./iam/sa"
  name = var.sa.name
}

module "sa_roles" {
  source = "./rm/folder_iam_member"
  count = length(var.sa.roles)
  folder_id = var.folder_id
  member = "serviceAccount:${module.sa.id}"
  role = var.sa.roles[count.index]
}

module "sa_key" {
  source = "./iam/sa_key"
  service_account_id = module.sa.id
}

module "sa_key_file" {
  source = "./s3/object"
  bucket_name = module.bucket.bucket
  content = templatefile(
    "${path.root}/tftpl/sa_key.tftpl", {
      id = module.sa_key.id
      service_account_id = module.sa.id
      created_at = module.sa_key.created_at
      key_algorithm = var.sa.key_algorithm
      public_key = module.sa_key.public_key
      private_key = module.sa_key.private_key
    }
  )
  content_type = var.sa_key_file.content_type
  object_key = "${var.sa_key_file.dir_path}/${var.sa_key_file.name}"
}

module "sa_static_access_key" {
  source = "./iam/sa_static_access_key"
  service_account_id = module.sa.id
}

module "aws_access_file" {
  source = "./s3/object"
  bucket_name = module.bucket.bucket
  content = templatefile(
    "${path.root}/tftpl/aws_crd.tftpl", {
      aws_profile = var.aws_access_profile
      aws_access_key_id = module.sa_static_access_key.access_key
      aws_secret_access_key = module.sa_static_access_key.secret_key
    }
  )
  content_type = var.aws_access_file.content_type
  object_key = "${var.aws_access_file.dir_path}/${var.aws_access_file.name}"
}

module "symmetric_key" {
  source = "./kms/symmetric/key"
  name = var.symmetric_key.name
  default_algorithm = var.symmetric_key.algorithm
  deletion_protection = var.symmetric_key.deletion_protection
  rotation_period = var.symmetric_key.rotation_period
}

module "bucket" {
  source = "./s3/bucket"
  bucket_name = var.bucket.name
  versioning = var.bucket.versioning
  kms_master_key_id = module.symmetric_key.id
}

module "ydb_serverless" {
  source = "./ydb/db_serverless"
  deletion_protection = var.ydb.deletion_protection
  name = var.ydb.name
  serverless_database = {
    enable_throttling_rcu_limit = var.ydb.enable_throttling_rcu_limit
    storage_size_limit = var.ydb.size
    throttling_rcu_limit = var.ydb.throttling_rcu_limit
  }
}

module "dynamodb_table" {
  source = "./aws/aws_dynamodb_table"
  name = var.dynamodb_table.name
  hash_key = var.dynamodb_table.attribute[0].name
  attribute = var.dynamodb_table.attribute
}

module "backend_conf_file" {
  source = "./s3/object"
  bucket_name = module.bucket.bucket
  content = templatefile(
    "${path.root}/tftpl/backend.tftpl", {
      doc_api_endpoint = module.ydb_serverless.document_api_endpoint
      dynamodb_teble_name = var.dynamodb_table.name
      aws_access_file_path = "./${var.aws_access_file.dir_path}/${var.aws_access_file.name}"
      profile = var.aws_access_profile
      region = var.region
      bucket_name = var.bucket.name
    }
  )
  content_type = var.backend_file.content_type
  object_key = "${var.backend_file.dir_path}/${var.backend_file.name}"
}

module "variables_file" {
  source = "./s3/object"
  bucket_name = module.bucket.bucket
  content = templatefile(
    "${path.root}/tftpl/variables.tftpl", {
      service_account_id = module.sa.id
      service_account_key_file_path = "./${var.sa_key_file.dir_path}/${var.sa_key_file.name}"
    }
  )
  content_type = var.vars_file.content_type
  object_key = "${var.vars_file.dir_path}/${var.vars_file.name}"
}


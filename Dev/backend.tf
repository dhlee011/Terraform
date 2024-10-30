terraform {
  backend "s3" {
    bucket = "ldh-terraform-state-bucket"  
    key    = "Landingzone/Dev/terraform.tfstate"  # 상태 파일을 저장할 경로
    region = "ap-northeast-2"  
#    dynamodb_table = "terraform-state-lock-tables"  # 상태 파일 락을 위한 DynamoDB 테이블 (선택 사항)
  }
}



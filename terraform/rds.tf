/*
resource "aws_db_instance" "pmsi_dev_db" {
    allocated_storage    = 100
    db_subnet_group_name = "pmsi-db-subnetgrp"
    engine               = var.database_engine  
    engine_version       = "11.5"
    identifier           = "pmsidevdb"
    instance_class       = "db.t2.micro"
    password             =  var.database_password
    username             = var.database_username  
    skip_final_snapshot  = true
    storage_encrypted    = true
    //subnet_group = aws_db_subnet_group.default.name


}
*/

######## DATABASE VARIABLES ###########
variable "database_engine" {
  default = "postgres"
}
variable "database_username" {
  default = "postgres"
}

variable "database_password" {
  default = "247Secured"
}

variable "dev_database_name" {
  default = "tgpisdevdb"
}

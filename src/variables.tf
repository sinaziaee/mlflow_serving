variable "db_username" {
  type    = string
  default = "mlflow"
}

variable "db_password" {
  type      = string
  sensitive = true
}

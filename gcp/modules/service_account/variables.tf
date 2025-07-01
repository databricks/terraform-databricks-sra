variable "sa_name" {}

variable "project" {
  type    = string
}

variable "workspace_creator_creates_cmek"{
  type = bool
  default = false
}

variable "workspace_creator_creates_psc" {
  type = bool
  default = false
}

variable "workspace_create_modifies_compute_SA" {
  type = bool
  default = false
}

variable "delegate_from" {
  type = list(string)
  default = []
}
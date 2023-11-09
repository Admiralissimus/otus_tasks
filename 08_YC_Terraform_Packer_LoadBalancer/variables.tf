variable "az_default" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "folder_id" {
  description = "Default folder_id"
  type        = string
  default     = "b1grlgcpgp7enm4j8knb"
}

variable "platform_id" {
  description = "Type if instances"
  type        = string
  default     = "standard-v2"
}

variable "owner" {
  description = "Owner in labels"
  type        = string
  default     = "ushakou"
}


terraform {
  required_providers {
    databricks = {
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
      source  = "databricks/databricks"
      version = ">=1.54.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0"
<<<<<<< HEAD
    }
  }
  required_version = ">=1.0"
=======
      source = "databricks/databricks"
    }
  }
>>>>>>> c1185b0 (aws gov simplicity update)
=======
    }
  }
  required_version = ">=1.0"
>>>>>>> fc4eee5 ([aws-gov] fix(aws-gov) update naming convention of modules, update test, add required terraform provider)
}
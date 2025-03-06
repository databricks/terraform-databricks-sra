terraform {
  required_providers {
    aws = {
<<<<<<< HEAD
<<<<<<< HEAD
      source  = "hashicorp/aws"
      version = ">=5.76.0"
    }
  }
  required_version = ">=1.0"
<<<<<<< HEAD
=======
      source = "hashicorp/aws"
=======
      source  = "hashicorp/aws"
      version = "5.76.0"
>>>>>>> ecbeb76 (adding required provider versions)
    }
  }
>>>>>>> b3e4c6f (aws simplicity update)
=======
>>>>>>> 8eced5b (fix(aws) update naming convention of modules, update test, add required terraform provider)
}
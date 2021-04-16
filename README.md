# Using Cloud Object Storage as a backend

This repository shows how to use IBM Cloud Object Storage (COS) as a backend to store terraform state through COS [Terraform S3 compatibility](https://www.terraform.io/docs/backends/types/s3.html).

1. Create a COS instance and bucket in IBM Cloud. Terraform is used in this step to create the COS service and the bucket as it is easier than to list all instructions that you would need to perform in the UI or the CLI.

   ```sh
   cd 010-prepare-backend
   terraform init
   terraform apply
   ```

   > It generates a `backend.tf` file in `020-use-backend` with the COS service instance and bucket information. Later instead of hardcoding the values in `backend.tf`, you can use environment variables to initialize the backend as described in https://www.terraform.io/docs/language/settings/backends/s3.html.

2. Test the backend.

   ```sh
   cd 020-use-backend
   terraform init
   terraform apply
   ```

3. Look into your COS bucket for a file named `global.state`.

## License

This project is licensed under the Apache License Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0).

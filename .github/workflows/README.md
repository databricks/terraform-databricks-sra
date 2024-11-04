# Testing Workflows
<!-- TOC -->
* [Testing Workflows](#testing-workflows)
  * [Workflow features](#workflow-features)
    * [Caching](#caching)
    * [Test toggles](#test-toggles)
  * [Tests](#tests)
    * [TFLint](#tflint)
      * [Note on configuring TFLint](#note-on-configuring-tflint)
    * [Terraform Fmt](#terraform-fmt)
    * [Terraform test](#terraform-test)
      * [Basic test case](#basic-test-case)
  * [Workflow Inputs](#workflow-inputs)
    * [1. **Actions Settings**](#1-actions-settings)
    * [2. **TFLint Settings**](#2-tflint-settings)
    * [3. **Terraform Settings**](#3-terraform-settings)
    * [4. **Terraform Format (fmt) Settings**](#4-terraform-format-fmt-settings)
    * [5. **Terraform Test Settings**](#5-terraform-test-settings)
  * [Usage Example](#usage-example)
<!-- TOC -->

The terraform-ruw workflow runs three tests:

- `TFLint`
- `terraform fmt`
- `terraform test`

It is a reusable workflow, and is called by other workflows via the `workflow_call` feature in GitHub Actions. Each
Terraform module in this repo has a separate workflow with unique settings for testing. The workflow may be used
multiple time for one module, with different settings per workflow.

## Workflow features

### Caching

The workflow
uses [GitHub Actions caching](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/caching-dependencies-to-speed-up-workflows)
for:

- [Terraform provider caching](https://developer.hashicorp.com/terraform/cli/config/config-file#plugin_cache_dir) to
  reduce how frequently providers are downloaded on init.
- tflint plugins

### Test toggles

The workflow supports enabling/disabling test jobs using workflow inputs. For example, the tflint job can be disabled by
setting the `tflint_enabled` input to `false`.

## Tests

### TFLint

[TFLint](https://github.com/terraform-linters/tflint/) is a linter for Terraform that can search for:

- Resource misconfigurations (e.g. unavailable instance types)
- Deprecated syntax
- [Module style](https://developer.hashicorp.com/terraform/language/style) violations
- Misc. issues per provider [plugin](https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/plugins.md)

#### Note on configuring TFLint

TFLint can be configured using a .tflint.hcl file added to the `working_directory` of the workflow. This file is not
required, though it is recommended so that provider plugins can be used for deeper inspection of the module. For more
information on the configuration file,
see [here](https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md).

> Note that this file only applies to the terraform code that is colocated in the directory the file is in. TFLint is
> configured to use the `--recursive` option by default, so this means that only the root configuration of a module will
> use this configuration file by default. To avoid creating multiple .tflint.hcl files throughout a nested module
> configuration, it is recommended to use the `tflint_args` input of the reusable workflow to add the
`--config=$(pwd)/.tflint.hcl` argument. This will cause tflint to use the same configuration file as it recurses the
> working directory tree. See azure-test.yml for an example.

### Terraform Fmt

Terraform fmt is run to check if files are properly formatted in the module. This test is configured with `-write=false`
and `-check=false` by default, meaning that terraform fmt will not write changes to disk, and it will not fail the
workflow if it finds that files need to be formatted. If you choose to require that files must be formatted correctly
for this test to path, you may configure this requirement using the `terraform_fmt_check` input in the reusable
workflow.

### Terraform test

Terraform test is run in the `working_directory` by default. To learn more about terraform test, see Hashicorp's
documentation [here](https://developer.hashicorp.com/terraform/language/tests). It is up to each module developer to
implement terraform tests as they see fit, but some general guidelines are as follows:

- For consistency, tests should be placed in a directory called `tests` in each root module (e.g. `azure/tf/tests`).
- Provider authentication is not currently supported "out of the box" for this repo. Until this is
  implemented, [mock providers](https://developer.hashicorp.com/terraform/language/tests) can be used to replicate a
  working provider.

#### Basic test case

A basic test that can be added to a root module is below. This will execute a terraform plan for a root module using a
mocked provider (azurerm used as an example).

```hcl
mock_provider "azurerm" {}

run "plan_test" {
  command = plan
}
```

This test **does not require authentication**, and will run as is. This test should closely replicate what will happen
on a terraform plan if the provider were authenticated.

## Workflow Inputs

### 1. **Actions Settings**

| Input               | Type   | Required | Default         | Description                                                            |
|---------------------|--------|----------|-----------------|------------------------------------------------------------------------|
| `working_directory` | string | Yes      | N/A             | The working directory where the Terraform code is located.             |
| `environment`       | string | No       | `null`          | GitHub environment to use for the workflow. Can also be used for OIDC. |
| `runs_on`           | string | No       | `ubuntu-latest` | Sets the runs-on option for all jobs in the workflow.                  |

### 2. **TFLint Settings**

| Input                             | Type    | Required | Default   | Description                                                                       |
|-----------------------------------|---------|----------|-----------|-----------------------------------------------------------------------------------|
| `tflint_enabled`                  | boolean | No       | `true`    | Whether to enable TFLint-related jobs.                                            |
| `tflint_version`                  | string  | No       | `v0.52.0` | The version of TFLint to install.                                                 |
| `tflint_minimum_failure_severity` | string  | No       | `error`   | The minimum severity required before TFLint considers a rule violation a failure. |
| `tflint_args`                     | string  | No       | `null`    | Additional arguments to pass to the TFLint command. Example: `"-var 'foo=bar'"`.  |

### 3. **Terraform Settings**

| Input               | Type   | Required | Default | Description                                                                                                   |
|---------------------|--------|----------|---------|---------------------------------------------------------------------------------------------------------------|
| `terraform_version` | string | No       | `~>1.0` | The version of Terraform to install for both test and fmt. This supports version constraints (e.g., `~>1.0`). |

### 4. **Terraform Format (fmt) Settings**

| Input                   | Type    | Required | Default | Description                                                                                                      |
|-------------------------|---------|----------|---------|------------------------------------------------------------------------------------------------------------------|
| `terraform_fmt_enabled` | boolean | No       | `true`  | Whether to enable Terraform formatting jobs using `terraform fmt`.                                               |
| `terraform_fmt_check`   | boolean | No       | `false` | Whether a formatting issue should cause the workflow to fail (passed to the `-check` option of `terraform fmt`). |

### 5. **Terraform Test Settings**

| Input                    | Type    | Required | Default | Description                                                                                           |
|--------------------------|---------|----------|---------|-------------------------------------------------------------------------------------------------------|
| `terraform_test_enabled` | boolean | No       | `true`  | Whether to enable Terraform testing jobs.                                                             |
| `terraform_test_args`    | string  | No       | `null`  | Additional arguments to pass to the `terraform test` command (e.g., `-filter=tests/plan.tftest.hcl`). |

## Usage Example

```yaml
name: Azure Tests
on:
  push:
    paths:
      - 'azure/tf/**'
      - '.github/workflows/azure-test.yml'
  pull_request:
    paths:
      - 'azure/tf/**'
      - '.github/workflows/azure-test.yml'
jobs:
  test-azure:
    uses: ./.github/workflows/terraform-ruw.yml
    with:
      working_directory: azure/tf
      tflint_args: "--config=$(pwd)/.tflint.hcl" #This causes TFLint to reuse the same .tflint.hcl file for every subdirectory
```

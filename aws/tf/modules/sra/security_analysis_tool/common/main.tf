# Make sure Files in Repos option is enabled in Workspace Admin Console > Workspace Settings

resource "databricks_repo" "security_analysis_tool" {
  url    = "https://github.com/databricks-industry-solutions/security-analysis-tool.git"
  branch = "main"
  path   = "/Workspace/Applications/SAT_TF"
}

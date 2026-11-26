locals {

  default_app_settings = {

    node = {
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"

    }

    python = {
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
      "ENVIRONMENT"                    = "development"
      "PORT"                           = "8000"
    }

  }

  stack_app_settings = local.default_app_settings[
    var.webapp_config.app_type
  ]

  final_app_settings = merge(
    local.stack_app_settings,
    var.webapp_config.app_settings
  )

}

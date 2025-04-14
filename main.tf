module "example" {
  source = "./modules/argocd_blue_green"

  blue_version = "1.5.0"
  is_blue_up   = true

  green_version = "2.0.0"
  is_green_up   = false

  route_to_color = "blue"
}

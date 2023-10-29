resource "aws_iam_user" "admins_count" {
  count = length(var.admins_count)
  name  = var.admins_count[count.index]
}

resource "aws_iam_user" "admins_foreach" {
  for_each = toset(var.admins_foreach)
  name     = each.value
}

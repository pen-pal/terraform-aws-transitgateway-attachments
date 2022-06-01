locals {
  # List of maps with key and route values
  tgw_default_route_table_tags_merged = merge(
    var.tags,
    { Name = var.name },
    var.tgw_default_route_table_tags,
  )

  vpc_route_table_destination_cidr = flatten([
    for k, v in var.vpc_attachments : [
      for rtb_id in try(v.vpc_route_table_ids, []) : {
        rtb_id = rtb_id
        cidr   = v.tgw_destination_cidr
      }
    ]
  ])
}

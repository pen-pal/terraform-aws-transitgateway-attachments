################################################################################
# VPC Attachment
################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = var.create_tgw ? aws_ec2_transit_gateway.this[0].id : each.value.tgw_id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids

  dns_support                                     = try(each.value.dns_support, true) ? "enable" : "disable"
  ipv6_support                                    = try(each.value.ipv6_support, false) ? "enable" : "disable"
  appliance_mode_support                          = try(each.value.appliance_mode_support, false) ? "enable" : "disable"
  transit_gateway_default_route_table_association = try(each.value.transit_gateway_default_route_table_association, true)
  transit_gateway_default_route_table_propagation = try(each.value.transit_gateway_default_route_table_propagation, true)

  tags = merge(
    var.tags,
    { Name = var.name },
    var.tgw_vpc_attachment_tags,
  )
}

resource "aws_route" "this" {
  for_each = { for x in local.vpc_route_table_destination_cidr : x.rtb_id => x.cidr }

  route_table_id         = each.key
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.this[0].id
}

tgw_routes = [
  {
    destination_cidr_block = "30.0.0.0/16"
  },
  {
    blackhole              = true
    destination_cidr_block = "40.0.0.0/20"
  }
]

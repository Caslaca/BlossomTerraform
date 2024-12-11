resource "aws_subnet" "private_subnets" {
    vpc_id = aws_vpc.blossom_vpc.id
    availability_zone = data.aws_availability_zones.available_zones.names[count.index]
    count             = var.count_az
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)

    map_public_ip_on_launch = false # makes private subnet

    tags = {
        public = false
    }
}

resource "aws_eip" "gw" {
    count      = var.count_az
    # domain = "vpc"
    depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "gw" {
    count         = var.count_az
    subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
    allocation_id = element(aws_eip.gw.*.id, count.index)
}

resource "aws_route_table" "private" {
    count  = var.count_az
    vpc_id = aws_vpc.blossom_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
    }
}

resource "aws_route_table_association" "private" {
    count          = var.count_az
    subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
    route_table_id = element(aws_route_table.private.*.id, count.index)
}
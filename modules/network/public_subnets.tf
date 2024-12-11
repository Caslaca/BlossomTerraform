
resource "aws_subnet" "public_subnets" {
    vpc_id = aws_vpc.blossom_vpc.id
    availability_zone = data.aws_availability_zones.available_zones.names[count.index]
    count             = var.count_az
    cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, var.count_az + count.index)

    map_public_ip_on_launch = true # makes public subnet
    tags = {
        public = true
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.blossom_vpc.id
    tags = {
        Name = "internet_gateway"
    }

    # Description: This resource creates an Internet Gateway for the specified VPC.
    # It is tagged with the name "internet_gateway".
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.blossom_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }

    # Description: This resource creates a route table for the specified VPC.
    # It includes a route that directs all traffic (0.0.0.0/0) to the Internet Gateway.
}

resource "aws_route_table_association" "public" {
    count          = var.count_az
    subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
    route_table_id = element(aws_route_table.public.*.id, count.index)

    # Description: This resource associates the route table with each subnet in the VPC.
    # It uses a count to create an association for each subnet ID.
}
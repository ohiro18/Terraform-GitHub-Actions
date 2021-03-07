provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "alicloud_vpc" "vpc" {
  name = "${var.project_name}-vpc"
  cidr_block = "192.168.1.0/24"
  description = "Enable github-actions-test-Server vpc"  
}

resource "alicloud_vswitch" "vsw" {
  name = "${var.project_name}-vswitch"  
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "192.168.1.0/28"
  availability_zone = "${var.zone}"
  description = "Enable github-actions-test vswitch"  
}

resource "alicloud_security_group" "sg_ecs_server" {
  name   = "${var.project_name}_github-actions-test"
  description = "Enable SSH access via port 22"  
  vpc_id = "${alicloud_vpc.vpc.id}"
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.sg_ecs_server.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "github-actions-test" {
  instance_name   = "${var.project_name}-github-actions-test"
  host_name       = "${var.project_name}-github-actions-test"
  instance_type   = "ecs.xn4.small"
  image_id        = "centos_7_04_64_20G_alibase_201701015.vhd"
  system_disk_category = "cloud_efficiency"
  security_groups = ["${alicloud_security_group.sg_ecs_server.id}"]
  availability_zone = "${var.zone}"
  vswitch_id = "${alicloud_vswitch.vsw.id}"
  password = "${var.ecs_password}"
  internet_max_bandwidth_out = 5
}

output "github-actions-test_ecs_ip" {
  value = "${alicloud_instance.github-actions-test.*.public_ip}"
}

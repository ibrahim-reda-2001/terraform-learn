
provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA5CBGTGSPWMQHAX2Y"
  secret_key = "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"
}
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }

}
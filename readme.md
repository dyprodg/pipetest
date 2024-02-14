erstelle zusaetzlich eine .tfvars

codestar_connection_arn = "codestarconnectionarn"
das dort einfuegen (naturlich die eigene connection arn nehmen)


beim ausfuehren

terraform apply -var-file=".tfvars"

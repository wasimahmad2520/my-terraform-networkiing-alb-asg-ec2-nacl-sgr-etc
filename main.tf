
/* left:- variables names in ec2 module */
/* right:- outputs names in other modules */

/* Create networking */
module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}


/* Create SSH Key */
module "ssh-key" {
  source    = "./modules/ssh-key"
  namespace = var.namespace
}


/* Create Ec2 Instances */
module "ec2" {
  source     = "./modules/ec2"
  namespace  = var.namespace
  vpc        = module.networking.vpc
  sg_pub_id  = module.networking.sg_pub_id
  sg_priv_id = module.networking.sg_priv_id
  key_name   = module.ssh-key.key_name
}


/* Create Application Load Balancer */
module "alb" {
  source     = "./modules/alb"
  namespace  = var.namespace
  vpc        = module.networking.vpc
  key_name   = module.ssh-key.key_name
  ec2_instance = module.ec2.ec2_instance
}


/* Creating Auto Scalling Group */
module "asg"{
  source     = "./modules/asg"
  namespace  = var.namespace
  vpc        = module.networking.vpc
  key_name   = module.ssh-key.key_name
  demosg1=module.alb.demosg1
  my_ami =module.alb.my_ami
  alb=module.alb.alb
  lb_target=module.alb.lb_target
}


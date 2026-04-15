{ config, pkgs, ... }:

{
  # DevOps / Cloud tools (migrated from DevSecTools/devops.sh)
  environment.systemPackages = with pkgs; [
    awscli2
    aws-iam-authenticator
    eksctl
    kubectl
    terraform
    pgadmin4-desktopmode
  ];
}

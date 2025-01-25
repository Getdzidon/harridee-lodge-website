For the ECR private pipeline, you put in permissions with a comment that "Required for OIDC authentication with AWS" but you're not using OIDC for authentication. You're actually using Access Keys and ID. 

More so, you did not integrate SAST scan into the pipelines and matched the various obfuscations to the various SOC 2 controls. 

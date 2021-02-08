# terraform-vault-k8s
Code repo for demo/sandbox of Vault on Kubernetes via Terraform.

## Deploy the GCP/GKE resources

### Set TF Variables
- Make a copy of the "terraform.auto.tfvars.example" file and name it "terraform.auto.tfvars"


## Deploy the Vault Helm chart

### Set TF Variables
- Make a copy of the "terraform.auto.tfvars.example" file and name it "terraform.auto.tfvars"
- Update all the values in the "terraform.auto.tfvars" file to reflect the necessary information for the environment
- For the Vault Enterprise license string, clients should have their license as part of onboarding with HashiCorp.
- The Vault Consul ACL Token, enter the value you received from the steps above.

### Deploy Vault

`terrafrom init`
<br>
`terraform apply`
```
Outputs:
```

### Check On Vault Cluster Status
The Vault pods will likely show a "Ready" value of "0/1".  This is fine, as the Vault cluster is currently in a sealed state until we initialize it.

From your command line `kubectl exec -ti vault-0 -- vault status`

The Vault cluster should show as un-initialized and sealed. This is the expected behavior for a blank Vault cluster.

```
Key                      Value
---                      -----
Recovery Seal Type       gcpckms
Initialized              false
Sealed                   true
Total Recovery Shares    0
Threshold                0
Unseal Progress          0/0
Unseal Nonce             n/a
Version                  n/a
HA Enabled               true
```

### Initialize Vault and gather the recovery keys

###### This next part I have left manual by design. A majority of the time you will not want to automate this step, as it is ***extremely*** important.  These recovery keys and initial root token are how you will access vault after it is initialized, as well as unseal vault in the even of disaster recovery, generating a new root token, etc.

Open a shell session to one of the Vault server pods.
```
❯$ kubectl exec -ti vault-0 -- /bin/sh

/ $ vault status
Key                      Value
---                      -----
Recovery Seal Type       gcpckms
Initialized              false
Sealed                   true
Total Recovery Shares    0
Threshold                0
Unseal Progress          0/0
Unseal Nonce             n/a
Version                  1.6.2
Storage Type             raft
HA Enabled               true


/ $ vault operator init
Recovery Key 1: YIKoy6bxQ73aK5IVEXAMPLEb9tsrNFhE+FG0D8pBHxy
Recovery Key 2: hRuS+ZFK53LGdUSVEXAMPLEvgsGry0S2ReqUOb5l0SL
Recovery Key 3: YHFu2clW/1873UxUEXAMPLEk71DbX77M8HjY1PcyWe5
Recovery Key 4: 7JGm5BtByZieDfzcEXAMPLE9onf/cbpArZiG7i3tfkL/
Recovery Key 5: ryxjmMomKTdoSe2EXAMPLELguSVVe02AHWLFqlAbh9+d

Initial Root Token: s.EXAMPLE

Success! Vault is initialized

```

Once you have the recovery keys and initial root token, copy them down and save them!

login to Vault with the root token from above.
```
$ vault login s.EXAMPLE

Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.
```

### Viewing the Vault UI

```
$ kubectl port-forward vault-0 8200:8200
```

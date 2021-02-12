# Terraform code to launch a demo Vault cluster on GKE
Code repo for demo/sandbox of Vault on Kubernetes via Terraform.

## Deploy the GCP/GKE resources

For this section you will need to make sure you are in the **'vault-gke-cluster'** directory.
```
cd vault-gke-cluster
```

### Set TF Variables
- Make a copy of the "terraform.auto.tfvars.example" file and name it "terraform.auto.tfvars"
- Update all the values in the "terraform.auto.tfvars" file to reflect the necessary information for the environment

### Run Terraform code to provision infrastructure on GCP/GKE

```
`terrafrom init`
<br>
`terraform apply`
```


## Deploy the Vault Helm chart

For this section you will need to make sure you are in the **'vault-helm'** directory.
```
cd ../vault-helm
```

### Set TF Variables
- Make a copy of the "terraform.auto.tfvars.example" file and name it "terraform.auto.tfvars"
- Update all the values in the "terraform.auto.tfvars" file to reflect the necessary information for the environment
- If you did not use the `vault-gke-cluster` TF code and just want to use the helm chart, make sure to update data and variable calls to use relevant information


### Deploy Vault

`terrafrom init`
<br>
`terraform apply`
```
Outputs:
```

### Check On Vault Cluster Status

You can check and watch the status of the pods by running a 'get pods' *make sure if you have not updated your kubectl context to include the namespace that you use the --namespace falg.*

```
kubectl get pods --namespace=vault-demo

NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          20m
vault-1                                 1/1     Running   0          20m
vault-2                                 1/1     Running   0          20m
vault-agent-injector-6f95fbc99b-sb7t4   1/1     Running   0          20m
```

The Vault pods will sometimes show a "Ready" value of "0/1".  This is fine, as the Vault cluster is currently in a sealed state until we initialize it.

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

### Initialize Vault and Gather the Recovery Keys

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

Login to Vault with the root token from above.
```
$ vault login s.EXAMPLE

Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.
```

Alternatively you can export the token as an environment variable `export VAULT_TOKEN=s.EXAMPLE`

Now you can check and verify that the other vault nodes are joined to the cluster.

```
/ $ vault operator raft list-peers
Node       Address                        State       Voter
----       -------                        -----       -----
vault-0    vault-0.vault-internal:8201    leader      true
vault-2    vault-2.vault-internal:8201    follower    true
vault-1    vault-1.vault-internal:8201    follower    true
```

Occasionally I will see isues with auto-unseal not working properly after the first `operator init`. You can resolve this by simply deleting the pods and letting them auto-recreate.

`kubectl delete pods vault-1 vault-2`

### Viewing the Vault UI

We have not yet created any method to access Vault external to the k8s cluster.
If you would like to view the Vault UI, you can use port-forwarding.

```
$ kubectl port-forward vault-0 8200:8200
```

Then simply open your browser of choice and go to `http://127.0.0.1:8200/`


## Vault Agent Injector

For this section you will need to make sure you are in the **'vault-agent-injector'** directory.
```
cd ../vault-agent-injector
```

### Set TF Variables
- Make a copy of the "terraform.auto.tfvars.example" file and name it "terraform.auto.tfvars"
- Update all the values in the "terraform.auto.tfvars" file to reflect the necessary information for the environment

### Deploy Vault and K8s resources

Currently we have not setup a way to interact with the Vault service externally. For this demo we can use kubectl and port forwarding in order to interact with the cluster.

Open a port forwarding session in one cmd/terminal window: `kubectl port-forward vault-0 8200:8200`

Then you can set the 'vault_cluster_addr' in the 'terraform.auto.tfvars' file to be "http://127.0.0.1:8200" for terraform to reach the Vault cluster.

In a seperate cmd/terminal window apply the terraform code.

`terrafrom init`
<br>
`terraform apply`

If all goes according to plan this will create a number of items including:
- The pre-reqs for the agent-injector on the k8s cluster
- The k8s auth method configured in Vault
- A few random secrets to showcase how this all works

### Create a K8s deployments and Inject Secrets

##### The first deployment is a simple app to show how secrets can be injected to a file location.

First create the deployment:
```
$ kubectl create -f app.yaml
deployment.apps/vault-agent-demo created
```

You can check and verify that the pod launched properly. After a short time it should show ready and available.
```
$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          2h
vault-1                                 1/1     Running   0          2h
vault-2                                 1/1     Running   0          2h
vault-agent-demo-665bd47f7f-cvhm2       1/1     Running   0          23s
vault-agent-injector-6f95fbc99b-sb7t4   1/1     Running   0          2h
```

Next we will apply a patch to the deployment with annotations for injecting Vault secrets.

```
# basic-annotations.yaml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/auth-path: "auth/kubernetes/vault-k8s-demo/"
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "k8_demo"
        vault.hashicorp.com/tls-skip-verify : "true"
        vault.hashicorp.com/agent-inject-secret-secret2.txt: "secret/data/hello-world"

```
A few things to note here are the auth-path and role annotations. Since we enabled the k8s auth method at a non-standard path, we need to set it here. The role annotation relates to the k8s role we created in Vault. Finally the 'agent-inject-secret' annotation contains info on where to store the secret on the pod, and the secret path in Vault.

Now apply the patch, and check the progress of the secret injection.  

```
$ kubectl patch deployment vault-agent-demo --patch "$(cat basic-annotations.yaml)"
deployment.apps/vault-agent-demo patched
```

If you run a 'get pods' you can likely catch the process in action.
```
# First a new pod is spun up with multiple containers; the basic app, the vault-agent sidecar, and the vault-agent-init that actually

$ kubectl get pods
NAME                                    READY   STATUS     RESTARTS   AGE
vault-0                                 1/1     Running    0          2h
vault-1                                 1/1     Running    0          2h
vault-2                                 1/1     Running    0          2h
vault-agent-demo-78fdb9c5bd-gnw2s       0/2     Init:0/1   0          2s
vault-agent-demo-665bd47f7f-cvhm2       1/1     Running    0          2m
vault-agent-injector-6f95fbc99b-sb7t4   1/1     Running    0          2h

# Once the agent is up and running, and as long as the secret has been retrieved and injected properly, the old app pod is marked for termination.

$ kubectl get pods
NAME                                    READY   STATUS        RESTARTS   AGE
vault-0                                 1/1     Running       0          2h
vault-1                                 1/1     Running       0          2h
vault-2                                 1/1     Running       0          2h
vault-agent-demo-78fdb9c5bd-gnw2s       2/2     Running       0          6s
vault-agent-demo-665bd47f7f-cvhm2       0/1     Terminating   0          30s
vault-agent-injector-6f95fbc99b-sb7t4   1/1     Running       0          2h


$ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          2h
vault-1                                 1/1     Running   0          2h
vault-2                                 1/1     Running   0          2h
vault-agent-demo-78fdb9c5bd-gnw2s       2/2     Running   0          24s
vault-agent-injector-6f95fbc99b-sb7t4   1/1     Running   0          2h
```

We can manually check for the secret contents, as this example stores the secret in a file.

```
$ kubectl exec -ti vault-agent-demo-78fdb9c5bd-gnw2s -c vault-agent-demo -- cat /vault/secrets/secret.txt

data: map[my-secret:I just injected a secret]
metadata: map[created_time:2021-02-10T17:08:39.412637799Z deletion_time: destroyed:false version:1]
```

##### The second example shows how you can format your secret data with Vault Agent Templates.

We can use the same app and a new annotations file with template specifics.

```
# template-annotations.yaml
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/auth-path: "auth/kubernetes/vault-k8s-demo/"
        vault.hashicorp.com/role: "k8_demo"
        vault.hashicorp.com/tls-skip-verify : "true"
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-status: "update"
        vault.hashicorp.com/agent-inject-secret-secret2: "secret/secret2"
        vault.hashicorp.com/agent-inject-template-secret2: |
          {{- with secret "secret/secret2" -}}
          postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres:5432/wizard
          {{- end }}
```

Simply run the patch command again, this time referencing the 'template-annotations' file.

```
$ kubectl patch deployment vault-agent-demo --patch "$(cat template-annotations.yaml)"
deployment.apps/vault-agent-demo patched
```
Wait a few seconds for the new pods to come up and check for the templated secrets.

```
$ kubectl get pods

NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          2h
vault-1                                 1/1     Running   0          2h
vault-2                                 1/1     Running   0          2h
vault-agent-demo-665d5d7bc-jf57n        2/2     Running   0          80s
vault-agent-injector-6f95fbc99b-sb7t4   1/1     Running   0          2h

$ kubectl exec -ti vault-agent-demo-665d5d7bc-jf57n -c vault-agent-demo -- cat /vault/secrets/secret2
postgresql://user1:SuperSecret1@postgres:5432/wizard
```

Just like that we could use Vault Agent Templates to format secrets into more readily usable content.

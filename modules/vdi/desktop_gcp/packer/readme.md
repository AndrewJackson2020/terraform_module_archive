
TODO: Add .ssh keys to VM 
TODO: Pull git repos


```
packer init
```

Execute the below line to deploy to test
```
packer build project=primeval-door-374216 .\create_image.pkr.hcl
```

Execute the below line to deploy to prod
```
packer build -var "project=skilful-alpha-358420" .\create_image.pkr.hcl
```
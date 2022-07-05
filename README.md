# Introducción

Infraestructura como código - AKS.

__Prerrequisitos__

* Tener instalado [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
    > Fue probado con la versión 2.16.0 a mas

* Tener instalado HashiCorp [Terraform](https://terraform.io/downloads.html).
    > Fue probado con la version 0.12.8 a mas

__Configuración de las variables de entorno para Terraform__

Generar el Azure Client Id y el secret.

> Despues de crear el Service Principal, se debe dar permisos para __Azure Active Directory__ y activar los siguientes permisos:
> - Leer y escribir todas las aplicaciones.
> - Iniciar sesión y leer información del perfil del usuario.

Para crear el Service Principal con el AZ CLI se debe ejecutar:


```bash
# Crear el Service Principal
# Si utiliza PowerShell, utilizar:
# $Subscription=$(az account show --query id -otsv)
Subscription=$(az account show --query id -otsv)
az ad sp create-for-rbac --name "Terraform-Principal" --role="Owner" --scopes="/subscriptions/$Subscription"


# El resultado debe ser como el siguiente
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "Terraform-Principal",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

__Valores de referencia__

| Azure | Terraform |
|----- |----- |
| appId | Client id |
| password | Client secret |
| tenant | Tenant id |

Ahora es necesario exportar las variables de entorno para configurar el [Azure](https://www.terraform.io/docs/providers/azurerm/index.html) Terraform Provider.

> En sistemas operativos Unix (Linux, MacOS o WSL) se puede utilizar [direnv](https://direnv.net/) que nos permite tener variables de entorno por directorio, de manera que son cargadas automaticamente.

```bash
export ARM_SUBSCRIPTION_ID="SUBSCRIPTION_ID"
export ARM_TENANT_ID="TENANT_ID"
export ARM_CLIENT_ID="CLIENT_ID"
export ARM_CLIENT_SECRET="CLIENT_SECRET"

```

__AKS__


```yaml
## Azure resource provider ##
provider azurerm {
  version = "=2.36.0"
  features {}
}
...
```

```bash
terraform init

terraform plan

terraform apply
```


```bash
export KUBECONFIG=./output/aks_config
kubectl get pods
```


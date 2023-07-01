

package test


import (
	"testing"
	"os"
	"github.com/gruntwork-io/terratest/modules/terraform"
)


func TestTerraformHelloWorldExample(t *testing.T) {


	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		
		TerraformDir: "../example",

		Vars: map[string]interface{}{
			"AWS_ACCESS_KEY_ID": os.Getenv("AWS_ACCESS_KEY_ID"),
			"AWS_SECRET_ACCESS_KEY": os.Getenv("AWS_SECRET_ACCESS_KEY"),
			"AWS_REGION": os.Getenv("AWS_REGION"),
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

}



package test


import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)


func TestTerraformHelloWorldExample(t *testing.T) {


	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		
		TerraformDir: "../example",

	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

}

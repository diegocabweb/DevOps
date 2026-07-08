Iniciando un nuevo proceso de aprendizaje utilizando IA

## Alistamiento

# Instalar Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Instalar vscode
brew install --cask visual-studio-code

Se instala docker desktop

# Instalar AWS S3
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
which aws
aws --version

# Instalar floci
brew install floci-io/floci/floci
floci start
eval $(floci env)
#exports AWS_ENDPOINT_URL, AWS_ACCESS_KEY_ID,
#AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION

# Create a bucket
aws s3 mb s3://my-bucket

# Write a file and upload it
echo "Why pay for S3 when floci is free? 🎉" > hello-floci.txt
aws s3 cp hello-floci.txt \
  s3://my-bucket/hello-floci.txt

# Download it back and read it
aws s3 cp s3://my-bucket/hello-floci.txt \
  hello-back.txt
cat hello-back.txt

# Check status
floci status

# View logs
floci logs --follow

# Stop the emulator
floci stop

# Run health diagnostics
floci doctor

floci start --persist ./data
# state survives container restarts

# Save and restore state
floci snapshot save my-snapshot
floci snapshot restore my-snapshot
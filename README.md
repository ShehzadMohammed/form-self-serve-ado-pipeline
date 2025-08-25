# Azure DevOps Template Generator

A minimalist Flask web application for generating Azure DevOps deployment templates through a simple form interface.

## Features

- **Minimalist interface** - Clean, simple form with no decorations
- **Azure integration** - Fetches actual App Service Plans from Azure
- **Template generation** - Creates Azure DevOps YAML templates with proper variables
- **Environment mapping** - Automatically maps environments to infrastructure environments
- **Auto-assigned networking** - Virtual network configuration based on environment

## Prerequisites

- Python 3.8 or higher
- Azure subscription with appropriate permissions
- Azure CLI (for authentication)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd form-self-serve-ado-pipeline
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   
   # On Windows
   venv\Scripts\activate
   
   # On macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   Create a `.env` file in the project root:
   ```env
   AZURE_SUBSCRIPTION_ID=your-subscription-id
   AZURE_RESOURCE_GROUP=your-resource-group
   SECRET_KEY=your-secret-key-here
   ```

5. **Authenticate with Azure**
   ```bash
   az login
   az account set --subscription your-subscription-id
   ```

## Usage

1. **Start the application**
   ```bash
   python server.py
   ```

2. **Access the application**
   Open your browser and navigate to `http://localhost:5000`

3. **Fill out the form**
   - Enter your application name
   - Select the deployment environment (dev, qa, prod)
   - Choose an App Service Plan (loaded from Azure)
   - Provide Docker image details
   - Add optional tags

4. **Generate template**
   The application will create an Azure DevOps YAML template with all the required variables.

## Generated Template Structure

The application generates Azure DevOps templates with the following structure:

```yaml
resources:
  repositories:
  - repository: templates
    type: git
    name: templates

trigger:

variables:
- name: service_connection_name
  value: "service-connection-{env}"
- name: backend_service_connection_name
  value: "backend-service-connection-{env}"
- name: env
  value: "{env}"
- name: infraenv
  value: "{infraenv}"
- name: app
  value: "{app_name}"
- name: app_service_plan_name
  value: "{app_service_plan_name}"
- name: app_service_plan_resource_group
  value: "{app_service_plan_resource_group}"
- name: virtual_network_name
  value: "{vnet_name}"
- name: virtual_networks_resource_group_name
  value: "{vnet_resource_group}"
- name: subnet_name
  value: "{subnet_name}"
- name: docker_image_name
  value: "{docker_image_name}"
- name: docker_registry_url
  value: "{docker_registry_url}"
- name: tags
  value: '{tags}'

stages:
- template: appsvcapp-template.yml@templates
```

## Environment Mappings

- **dev** → infraenv: nonprod
- **qa** → infraenv: nonprod  
- **prod** → infraenv: prod

## Virtual Network Configuration

Virtual network settings are automatically assigned based on environment:

- **dev**: dev-vnet, dev-network-rg
- **qa**: qa-vnet, qa-network-rg
- **prod**: prod-vnet, prod-network-rg

## API Endpoints

- `GET /` - Main form page
- `GET /api/app-service-plans` - Get App Service Plans from Azure
- `POST /submit` - Submit form and generate template

## File Structure

```
form-self-serve-ado-pipeline/
├── server.py              # Main Flask application
├── requirements.txt       # Python dependencies
├── README.md             # This file
├── templates/
│   └── index.html        # Minimalist form template
└── generated_templates/  # Generated Azure DevOps templates
```

## Azure Integration

The application uses Azure SDK to:
- Fetch App Service Plans from your subscription
- Extract plan details (name, resource group, SKU, location)
- Provide real-time data for form selection

## Production Deployment

For production deployment on Azure App Service:

1. **Deploy to Azure App Service**
   - Use Python runtime
   - Set environment variables in App Service Configuration
   - Ensure managed identity has Reader access to subscription

2. **Security considerations**
   - Use managed identity for Azure authentication
   - Set proper CORS headers if needed
   - Use HTTPS in production

## Customization

### Adding New Environments

Update the `ENVIRONMENTS` list and `VNET_CONFIG` dictionary in `server.py`.

### Modifying Template Generation

Edit the `generate_azure_devops_template()` function to customize the YAML output.

## Troubleshooting

- **Azure authentication issues**: Ensure proper managed identity or service principal permissions
- **App Service Plans not loading**: Check subscription access and network connectivity
- **Template generation errors**: Verify all required form fields are filled

## License

This project is licensed under the MIT License.

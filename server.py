from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
import json
import os
from datetime import datetime
from azure.identity import DefaultAzureCredential
from azure.mgmt.web import WebSiteManagementClient
from azure.mgmt.resource import ResourceManagementClient

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-here')

# Azure configuration - different subscriptions per environment
SUBSCRIPTION_IDS = {
    'dev': os.environ.get('AZURE_DEV_SUBSCRIPTION_ID'),
    'qa': os.environ.get('AZURE_QA_SUBSCRIPTION_ID'), 
    'prod': os.environ.get('AZURE_PROD_SUBSCRIPTION_ID')
}

# Environment mappings
ENVIRONMENTS = ['dev', 'qa', 'prod']
ENV_TO_INFRAENV = {
    'dev': 'nonprod',
    'qa': 'nonprod', 
    'prod': 'prod'
}

# Virtual network mappings (auto-assigned based on env)
VNET_CONFIG = {
    'dev': {
        'vnet_name': 'dev-vnet',
        'vnet_resource_group': 'dev-network-rg',
        'subnet_name': 'app-subnet'
    },
    'qa': {
        'vnet_name': 'qa-vnet', 
        'vnet_resource_group': 'qa-network-rg',
        'subnet_name': 'app-subnet'
    },
    'prod': {
        'vnet_name': 'prod-vnet',
        'vnet_resource_group': 'prod-network-rg', 
        'subnet_name': 'app-subnet'
    }
}

def get_app_service_plans_from_azure(environment=None):
    """Get actual App Service Plans from Azure using environment-specific subscription"""
    try:
        # Get the subscription ID for the specific environment
        if not environment or environment not in SUBSCRIPTION_IDS:
            raise Exception(f"Environment '{environment}' not supported or not specified")
            
        subscription_id = SUBSCRIPTION_IDS[environment]
        if not subscription_id:
            raise Exception(f"No subscription ID configured for environment: {environment}")
            
        credential = DefaultAzureCredential()
        web_client = WebSiteManagementClient(credential, subscription_id)
        
        plans = []
        for plan in web_client.app_service_plans.list():
            # Get all plans from the environment-specific subscription
            plans.append({
                'name': plan.name,
                'resource_group': plan.id.split('/')[4],
                'sku': plan.sku.name,
                'location': plan.location
            })
        return plans
    except Exception as e:
        print(f"Error fetching App Service Plans for environment {environment}: {e}")
        # Return single dummy plan on exception
        return [
            {'name': 'dummy', 'resource_group': 'dummy-rg', 'sku': 'B1', 'location': 'East US'}
        ]

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/environments')
def get_environments():
    """Get available environments"""
    return jsonify(ENVIRONMENTS)

@app.route('/api/app-service-plans')
@app.route('/api/app-service-plans/<environment>')
def get_app_service_plans(environment=None):
    """Get available app service plans from Azure filtered by environment"""
    plans = get_app_service_plans_from_azure(environment)
    return jsonify(plans)

@app.route('/generate', methods=['POST'])
def generate_template():
    """Generate Azure DevOps template and return as JSON"""
    try:
        data = {
            'app_name': request.form.get('app_name'),
            'environment': request.form.get('environment'),
            'app_service_plan_name': request.form.get('app_service_plan_name'),
            'app_service_plan_resource_group': request.form.get('app_service_plan_resource_group'),
            'docker_image_name': request.form.get('docker_image_name'),
            'docker_registry_url': request.form.get('docker_registry_url', 'acr.azurecr.io'),
            'tags': request.form.get('tags', '{}')
        }
        
        # Validate required fields
        required_fields = ['app_name', 'environment', 'app_service_plan_name', 'app_service_plan_resource_group', 'docker_image_name']
        for field in required_fields:
            if not data[field]:
                return jsonify({'success': False, 'error': f'Field {field} is required'})
        
        # Generate Azure DevOps template
        template = generate_azure_devops_template(data)
        
        # Save the template
        save_template(template, data['app_name'], data['environment'])
        
        return jsonify({'success': True, 'template': template})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

def generate_azure_devops_template(data):
    """Generate Azure DevOps YAML template"""
    env = data['environment']
    infraenv = ENV_TO_INFRAENV[env]
    vnet_config = VNET_CONFIG[env]
    
    template = f"""resources:
  repositories:
  - repository: templates
    type: git
    name: templates

trigger:

variables:
- name: service_connection_name
  value: hard-coded
- name: backend_service_connection_name
  value: hard-coded
- name: env
  value: {env}
- name: infraenv
  value: {infraenv}
- name: app
  value: {data['app_name']}
- name: app_service_plan_name
  value: {data['app_service_plan_name']}
- name: app_service_plan_resource_group
  value: {data['app_service_plan_resource_group']}
- name: virtual_network_name
  value: {vnet_config['vnet_name']}
- name: virtual_networks_resource_group_name
  value: {vnet_config['vnet_resource_group']}
- name: subnet_name
  value: {vnet_config['subnet_name']}
- name: docker_image_name
  value: {data['docker_image_name']}
- name: docker_registry_url
  value: {data['docker_registry_url']}
- name: tags
  value: {data['tags']}

stages:
- template: appsvcapp-template.yml@templates"""
    return template

def save_template(template, app_name, environment):
    """Save the generated template"""
    templates_dir = 'generated_templates'
    os.makedirs(templates_dir, exist_ok=True)
    
    filename = f"{app_name}_{environment}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.yml"
    filepath = os.path.join(templates_dir, filename)
    
    with open(filepath, 'w') as f:
        f.write(template)
    
    print(f"Template saved to {filepath}")

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

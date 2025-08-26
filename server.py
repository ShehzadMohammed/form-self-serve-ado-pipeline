from flask import Flask, render_template, request, jsonify
import json
import os
import requests
import subprocess
from datetime import datetime

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-here')

# Azure configuration - single subscription, filter by tags
SUBSCRIPTION_ID = os.environ.get('AZURE_SUBSCRIPTION_ID')

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

def get_azure_access_token():
    """Get Azure access token using Azure CLI"""
    try:
        result = subprocess.run(['az', 'account', 'get-access-token'], 
                              capture_output=True, text=True, check=True)
        token_data = json.loads(result.stdout)
        return token_data['accessToken']
    except Exception as e:
        print(f"Error getting Azure access token: {e}")
        return None

def get_app_service_plans_from_azure(environment=None):
    """Get App Service Plans from Azure filtered by environment tags (with offline fallback)"""
    
    # Check if running in offline mode (Docker container or no Azure setup)
    offline_mode = not SUBSCRIPTION_ID or os.environ.get('OFFLINE_MODE', 'false').lower() == 'true'
    
    if not offline_mode:
        try:
            # Get access token using Azure CLI
            access_token = get_azure_access_token()
            if not access_token:
                raise Exception("Could not get Azure access token")
                
            # Call Azure REST API to get App Service Plans
            url = f"https://management.azure.com/subscriptions/{SUBSCRIPTION_ID}/providers/Microsoft.Web/serverfarms"
            headers = {
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json'
            }
            params = {'api-version': '2022-03-01'}
            
            response = requests.get(url, headers=headers, params=params, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            plans = []
            
            for plan in data.get('value', []):
                # Extract resource group from the id
                resource_group = plan['id'].split('/')[4]
                
                # Get the tags for this plan
                plan_tags = plan.get('tags', {})
                plan_env = plan_tags.get('env', '').lower()
                
                # Filter by environment if specified
                if environment and plan_env != environment.lower():
                    continue
                    
                plans.append({
                    'name': plan['name'],
                    'resource_group': resource_group,
                    'sku': plan.get('sku', {}).get('name', 'Unknown'),
                    'location': plan['location'],
                    'env': plan_env,
                    'tags': plan_tags
                })
            
            # If we got real data, return it
            if plans:
                return plans
            elif environment:
                print(f"No App Service Plans found with env tag '{environment}' in subscription {SUBSCRIPTION_ID}")
            
        except Exception as e:
            print(f"Error fetching App Service Plans for environment {environment}: {e}")
            print("Falling back to offline mode...")
    
    # Fallback to dummy plans (for offline mode or Azure API failures)
    print(f"Using offline/demo data for environment: {environment or 'all'}")
    dummy_plans = [
        {'name': 'demo-plan-dev', 'resource_group': 'demo-rg', 'sku': 'B1', 'location': 'East US', 'env': 'dev', 'tags': {'env': 'dev', 'mode': 'demo'}},
        {'name': 'demo-plan-qa', 'resource_group': 'demo-rg', 'sku': 'B1', 'location': 'East US', 'env': 'qa', 'tags': {'env': 'qa', 'mode': 'demo'}},
        {'name': 'demo-plan-prod', 'resource_group': 'demo-rg', 'sku': 'P1v3', 'location': 'East US', 'env': 'prod', 'tags': {'env': 'prod', 'mode': 'demo'}}
    ]
    
    if environment:
        # Filter dummy plans by environment
        filtered_plans = [plan for plan in dummy_plans if plan['env'] == environment.lower()]
        return filtered_plans if filtered_plans else [dummy_plans[0]]
    
    return dummy_plans

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
    app.run(debug=True, host='0.0.0.0', port=8080)

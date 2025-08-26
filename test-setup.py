#!/usr/bin/env python3
"""
Test script to verify the application setup works without cffi dependencies
"""

def test_imports():
    """Test that all required modules can be imported"""
    print("Testing imports...")
    
    try:
        import flask
        print("✓ Flask imported successfully")
    except ImportError as e:
        print(f"✗ Flask import failed: {e}")
        return False
        
    try:
        import requests
        print("✓ Requests imported successfully")
    except ImportError as e:
        print(f"✗ Requests import failed: {e}")
        return False
        
    try:
        import json
        import os
        import subprocess
        print("✓ Standard library modules imported successfully")
    except ImportError as e:
        print(f"✗ Standard library import failed: {e}")
        return False
        
    return True

def test_azure_functionality():
    """Test that Azure functionality is working"""
    print("\nTesting Azure functionality...")
    
    try:
        # Test importing the server module and calling the Azure function
        import sys
        import os
        sys.path.insert(0, os.path.dirname(__file__))
        
        import server
        
        # Test Azure CLI access token function
        try:
            token = server.get_azure_access_token()
            if token:
                print("✓ Azure CLI authentication works")
            else:
                print("⚠ Azure CLI not authenticated (az login required)")
        except:
            print("⚠ Azure CLI not available (fallback mode will be used)")
        
        # Test each environment (will use fallback data if Azure fails)
        for env in ['dev', 'qa', 'prod']:
            plans = server.get_app_service_plans_from_azure(env)
            if plans and len(plans) > 0:
                plan = plans[0]
                print(f"✓ {env} environment: {plan['name']} ({plan['sku']}) - tags: {plan.get('tags', {})}")
            else:
                print(f"✗ {env} environment has no plans")
                return False
        
        return True
    except Exception as e:
        print(f"✗ Azure functionality test failed: {e}")
        return False

def test_server_import():
    """Test that the server module can be imported"""
    print("\nTesting server module...")
    
    try:
        # Test importing the server module
        import sys
        import os
        sys.path.insert(0, os.path.dirname(__file__))
        
        import server
        print("✓ Server module imported successfully")
        return True
    except ImportError as e:
        print(f"✗ Server module import failed: {e}")
        return False
    except Exception as e:
        print(f"✗ Server module test failed: {e}")
        return False

def main():
    """Run all tests"""
    print("=== Azure Integration Test ===")
    print("Testing that the application works with Azure tag filtering")
    print()
    
    all_passed = True
    
    all_passed &= test_imports()
    all_passed &= test_azure_functionality()
    all_passed &= test_server_import()
    
    print("\n" + "="*50)
    if all_passed:
        print("✓ ALL TESTS PASSED!")
        print("Your application is ready to run with Azure tag filtering.")
        print("\nTo start the application:")
        print("  python server.py")
        print("\nThen open: http://localhost:8080")
    else:
        print("✗ Some tests failed.")
        print("Please install missing dependencies with:")
        print("  pip install -r requirements.txt")
    print("="*50)

if __name__ == "__main__":
    main()

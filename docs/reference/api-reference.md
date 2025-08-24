# Dolibarr API Reference

This document provides a comprehensive reference for the Dolibarr REST API, including authentication, endpoints, and usage examples.

## Table of Contents

- [API Overview](#api-overview)
- [Authentication](#authentication)
- [API Explorer](#api-explorer)
- [Common Patterns](#common-patterns)
- [Core Endpoints](#core-endpoints)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Examples](#examples)
- [SDKs and Libraries](#sdks-and-libraries)

---

## API Overview

The Dolibarr REST API provides programmatic access to most Dolibarr functionality, allowing you to integrate Dolibarr with other systems, build custom applications, or automate business processes.

### Base URL
```
http://localhost:8080/api/index.php
```

### API Version
The API follows semantic versioning and supports multiple versions. The current version is embedded in the response headers.

### Content Type
All API requests and responses use JSON format:
```
Content-Type: application/json
Accept: application/json
```

---

## Authentication

### API Key Authentication

Dolibarr uses API key authentication. Each user can have multiple API keys.

#### Generating API Keys

**Via Web Interface**:
1. Login to Dolibarr as an administrator
2. Go to `Users & Groups` > `Users`
3. Edit a user account
4. Navigate to `API Keys` tab
5. Generate a new API key

**Via Task Command**:
```bash
# Enable API module first
task config:enable-api

# Then generate keys via web interface
echo "API Explorer: http://localhost:${DOLIBARR_PORT:-8080}/api/index.php/explorer"
```

#### Using API Keys

Include the API key in the request header:

```bash
curl -X GET "http://localhost:8080/api/index.php/users" \
  -H "Accept: application/json" \
  -H "DOLAPIKEY: your_api_key_here"
```

Or as a query parameter:
```bash
curl "http://localhost:8080/api/index.php/users?api_key=your_api_key_here"
```

#### Security Best Practices

- **Never expose API keys**: Don't commit API keys to version control
- **Use environment variables**: Store API keys in environment variables
- **Rotate keys regularly**: Generate new keys and revoke old ones
- **Use HTTPS**: Always use HTTPS in production
- **Limit permissions**: Create users with minimal required permissions

---

## API Explorer

Dolibarr includes a built-in API explorer for testing and documentation.

### Accessing the Explorer

**URL**: `http://localhost:8080/api/index.php/explorer`

**Prerequisites**:
```bash
# Enable API module
task config:enable-api

# Ensure services are running
task services:start-with-tools
```

### Explorer Features

- **Interactive Documentation**: Browse all available endpoints
- **Try It Out**: Execute API calls directly from the browser
- **Schema Information**: View request/response schemas
- **Authentication**: Test API keys directly in the interface

---

## Common Patterns

### Request Format

#### Standard GET Request
```bash
curl -X GET "http://localhost:8080/api/index.php/endpoint" \
  -H "Accept: application/json" \
  -H "DOLAPIKEY: your_api_key"
```

#### POST Request with Data
```bash
curl -X POST "http://localhost:8080/api/index.php/endpoint" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{
    "field1": "value1",
    "field2": "value2"
  }'
```

#### PUT Request (Update)
```bash
curl -X PUT "http://localhost:8080/api/index.php/endpoint/123" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{"field1": "updated_value"}'
```

#### DELETE Request
```bash
curl -X DELETE "http://localhost:8080/api/index.php/endpoint/123" \
  -H "Accept: application/json" \
  -H "DOLAPIKEY: your_api_key"
```

### Response Format

#### Success Response
```json
{
  "success": {
    "code": 200,
    "message": "Operation successful"
  },
  "data": {
    // Response data here
  }
}
```

#### Error Response
```json
{
  "error": {
    "code": 400,
    "message": "Bad Request",
    "details": "Specific error description"
  }
}
```

### Pagination

For endpoints that return lists, use pagination parameters:

```bash
curl "http://localhost:8080/api/index.php/users?limit=20&page=1" \
  -H "DOLAPIKEY: your_api_key"
```

Parameters:
- `limit`: Number of items per page (default: 100, max: 1000)
- `page`: Page number (starts at 1)
- `sortfield`: Field to sort by
- `sortorder`: ASC or DESC

---

## Core Endpoints

### Users Management

#### List Users
```http
GET /api/index.php/users
```

**Parameters**:
- `sqlfilters`: SQL WHERE clause conditions
- `limit`: Results per page
- `page`: Page number

**Example**:
```bash
curl "http://localhost:8080/api/index.php/users?limit=10" \
  -H "DOLAPIKEY: your_api_key"
```

#### Get User by ID
```http
GET /api/index.php/users/{id}
```

**Example**:
```bash
curl "http://localhost:8080/api/index.php/users/1" \
  -H "DOLAPIKEY: your_api_key"
```

#### Create User
```http
POST /api/index.php/users
```

**Example**:
```bash
curl -X POST "http://localhost:8080/api/index.php/users" \
  -H "Content-Type: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{
    "login": "newuser",
    "firstname": "John",
    "lastname": "Doe",
    "email": "john.doe@example.com",
    "pass": "securepassword"
  }'
```

#### Update User
```http
PUT /api/index.php/users/{id}
```

#### Delete User
```http
DELETE /api/index.php/users/{id}
```

---

### Third Parties (Companies)

#### List Third Parties
```http
GET /api/index.php/thirdparties
```

**Parameters**:
- `sortfield`: Sort field (name, code, etc.)
- `sortorder`: ASC or DESC
- `limit`: Results per page
- `page`: Page number
- `mode`: 1 for customers, 2 for prospects, 3 for suppliers

**Example**:
```bash
curl "http://localhost:8080/api/index.php/thirdparties?mode=1&limit=20" \
  -H "DOLAPIKEY: your_api_key"
```

#### Get Third Party by ID
```http
GET /api/index.php/thirdparties/{id}
```

#### Create Third Party
```http
POST /api/index.php/thirdparties
```

**Example**:
```bash
curl -X POST "http://localhost:8080/api/index.php/thirdparties" \
  -H "Content-Type: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{
    "name": "Acme Corp",
    "client": 1,
    "email": "contact@acme.com",
    "phone": "+1-555-0123",
    "address": "123 Business St",
    "zip": "12345",
    "town": "Business City",
    "country_code": "US"
  }'
```

#### Update Third Party
```http
PUT /api/index.php/thirdparties/{id}
```

#### Delete Third Party
```http
DELETE /api/index.php/thirdparties/{id}
```

---

### Contacts

#### List Contacts
```http
GET /api/index.php/contacts
```

#### Get Contact by ID
```http
GET /api/index.php/contacts/{id}
```

#### Create Contact
```http
POST /api/index.php/contacts
```

**Example**:
```bash
curl -X POST "http://localhost:8080/api/index.php/contacts" \
  -H "Content-Type: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{
    "firstname": "Jane",
    "lastname": "Smith",
    "email": "jane.smith@example.com",
    "phone": "+1-555-0124",
    "socid": 1,
    "poste": "Manager"
  }'
```

---

### Products/Services

#### List Products
```http
GET /api/index.php/products
```

**Parameters**:
- `type`: 0 for products, 1 for services
- `category`: Filter by category ID
- `limit`: Results per page

#### Get Product by ID
```http
GET /api/index.php/products/{id}
```

#### Create Product
```http
POST /api/index.php/products
```

**Example**:
```bash
curl -X POST "http://localhost:8080/api/index.php/products" \
  -H "Content-Type: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{
    "ref": "PROD001",
    "label": "Premium Widget",
    "description": "High-quality widget for professional use",
    "price": 29.99,
    "type": 0,
    "status": 1
  }'
```

#### Update Product Stock
```http
POST /api/index.php/products/{id}/stock
```

---

### Invoices

#### List Invoices
```http
GET /api/index.php/invoices
```

**Parameters**:
- `thirdparty_ids`: Filter by third party ID(s)
- `status`: Filter by status
- `sqlfilters`: Custom SQL filters

#### Get Invoice by ID
```http
GET /api/index.php/invoices/{id}
```

#### Create Invoice
```http
POST /api/index.php/invoices
```

**Example**:
```bash
curl -X POST "http://localhost:8080/api/index.php/invoices" \
  -H "Content-Type: application/json" \
  -H "DOLAPIKEY: your_api_key" \
  -d '{
    "socid": 1,
    "date": "2024-01-15",
    "lines": [
      {
        "fk_product": 1,
        "qty": 2,
        "subprice": 29.99,
        "description": "Premium Widget"
      }
    ]
  }'
```

#### Validate Invoice
```http
POST /api/index.php/invoices/{id}/validate
```

#### Add Payment to Invoice
```http
POST /api/index.php/invoices/{id}/payments
```

---

### Orders

#### List Orders
```http
GET /api/index.php/orders
```

#### Get Order by ID
```http
GET /api/index.php/orders/{id}
```

#### Create Order
```http
POST /api/index.php/orders
```

#### Update Order Status
```http
POST /api/index.php/orders/{id}/status
```

---

### Proposals/Quotes

#### List Proposals
```http
GET /api/index.php/proposals
```

#### Get Proposal by ID
```http
GET /api/index.php/proposals/{id}
```

#### Create Proposal
```http
POST /api/index.php/proposals
```

#### Set Proposal Status
```http
POST /api/index.php/proposals/{id}/status
```

---

### Projects

#### List Projects
```http
GET /api/index.php/projects
```

#### Get Project by ID
```http
GET /api/index.php/projects/{id}
```

#### Create Project
```http
POST /api/index.php/projects
```

#### Add Task to Project
```http
POST /api/index.php/projects/{id}/tasks
```

---

## Error Handling

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request successful, no content returned |
| 400 | Bad Request | Invalid request format or parameters |
| 401 | Unauthorized | Invalid or missing API key |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource conflict (e.g., duplicate key) |
| 500 | Internal Server Error | Server error |

### Error Response Format

```json
{
  "error": {
    "code": 400,
    "message": "Validation failed",
    "details": {
      "field": "email",
      "message": "Invalid email format"
    }
  }
}
```

### Common Errors

#### Authentication Errors
```json
{
  "error": {
    "code": 401,
    "message": "Access denied. Wrong API key."
  }
}
```

#### Validation Errors
```json
{
  "error": {
    "code": 400,
    "message": "Bad parameters",
    "details": "Required field 'name' is missing"
  }
}
```

#### Permission Errors
```json
{
  "error": {
    "code": 403,
    "message": "Forbidden: You don't have permission to access this resource"
  }
}
```

---

## Rate Limiting

### Default Limits

Dolibarr doesn't enforce strict rate limits by default, but it's recommended to implement reasonable request patterns:

- **Recommended**: Max 100 requests per minute per API key
- **Bulk Operations**: Use batch endpoints when available
- **Long Operations**: Implement exponential backoff for retries

### Best Practices

```javascript
// Example with exponential backoff
async function apiRequest(url, options, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options);
      if (response.ok) return response;
      
      if (response.status === 429) {
        // Rate limited, wait and retry
        await sleep(Math.pow(2, i) * 1000);
        continue;
      }
      
      throw new Error(`HTTP ${response.status}`);
    } catch (error) {
      if (i === retries - 1) throw error;
      await sleep(Math.pow(2, i) * 1000);
    }
  }
}
```

---

## Examples

### JavaScript/Node.js Example

```javascript
const axios = require('axios');

class DolibarrAPI {
  constructor(baseUrl, apiKey) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
    
    this.client = axios.create({
      baseURL: `${baseUrl}/api/index.php`,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'DOLAPIKEY': apiKey
      }
    });
  }

  // Get all third parties
  async getThirdParties(params = {}) {
    try {
      const response = await this.client.get('/thirdparties', { params });
      return response.data;
    } catch (error) {
      console.error('API Error:', error.response?.data || error.message);
      throw error;
    }
  }

  // Create a new third party
  async createThirdParty(data) {
    try {
      const response = await this.client.post('/thirdparties', data);
      return response.data;
    } catch (error) {
      console.error('API Error:', error.response?.data || error.message);
      throw error;
    }
  }

  // Create invoice
  async createInvoice(invoiceData) {
    try {
      const response = await this.client.post('/invoices', invoiceData);
      return response.data;
    } catch (error) {
      console.error('API Error:', error.response?.data || error.message);
      throw error;
    }
  }
}

// Usage
const api = new DolibarrAPI('http://localhost:8080', 'your_api_key');

// Example usage
async function example() {
  try {
    // Create a company
    const company = await api.createThirdParty({
      name: 'Tech Solutions Inc',
      client: 1,
      email: 'contact@techsolutions.com',
      phone: '+1-555-0199'
    });
    
    console.log('Created company:', company);

    // Create an invoice
    const invoice = await api.createInvoice({
      socid: company.id,
      date: new Date().toISOString().split('T')[0],
      lines: [
        {
          description: 'Consulting Services',
          qty: 10,
          subprice: 150.00
        }
      ]
    });
    
    console.log('Created invoice:', invoice);
    
  } catch (error) {
    console.error('Error:', error);
  }
}

example();
```

### Python Example

```python
import requests
import json
from datetime import datetime

class DolibarrAPI:
    def __init__(self, base_url, api_key):
        self.base_url = f"{base_url}/api/index.php"
        self.headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'DOLAPIKEY': api_key
        }
    
    def _request(self, method, endpoint, data=None, params=None):
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=self.headers,
                json=data,
                params=params
            )
            response.raise_for_status()
            return response.json() if response.content else None
        except requests.RequestException as e:
            print(f"API Error: {e}")
            if hasattr(e.response, 'json'):
                print(f"Error details: {e.response.json()}")
            raise

    def get_thirdparties(self, **params):
        return self._request('GET', '/thirdparties', params=params)
    
    def create_thirdparty(self, data):
        return self._request('POST', '/thirdparties', data=data)
    
    def get_products(self, **params):
        return self._request('GET', '/products', params=params)
    
    def create_invoice(self, data):
        return self._request('POST', '/invoices', data=data)

# Usage example
if __name__ == "__main__":
    api = DolibarrAPI('http://localhost:8080', 'your_api_key')
    
    try:
        # Create a new company
        company_data = {
            'name': 'Python Solutions Ltd',
            'client': 1,
            'email': 'info@pythonsolutions.com',
            'country_code': 'US'
        }
        
        company = api.create_thirdparty(company_data)
        print(f"Created company: {company}")
        
        # Get list of products
        products = api.get_products(limit=5)
        print(f"Products: {products}")
        
    except Exception as e:
        print(f"Error: {e}")
```

### PHP Example

```php
<?php

class DolibarrAPI {
    private $baseUrl;
    private $apiKey;
    private $httpHeaders;
    
    public function __construct($baseUrl, $apiKey) {
        $this->baseUrl = rtrim($baseUrl, '/') . '/api/index.php';
        $this->apiKey = $apiKey;
        $this->httpHeaders = [
            'Content-Type: application/json',
            'Accept: application/json',
            'DOLAPIKEY: ' . $apiKey
        ];
    }
    
    private function request($method, $endpoint, $data = null) {
        $url = $this->baseUrl . '/' . ltrim($endpoint, '/');
        
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $this->httpHeaders,
            CURLOPT_CUSTOMREQUEST => $method
        ]);
        
        if ($data !== null) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode >= 400) {
            throw new Exception("HTTP Error $httpCode: $response");
        }
        
        return json_decode($response, true);
    }
    
    public function getThirdParties($params = []) {
        $query = http_build_query($params);
        $endpoint = '/thirdparties' . ($query ? "?$query" : '');
        return $this->request('GET', $endpoint);
    }
    
    public function createThirdParty($data) {
        return $this->request('POST', '/thirdparties', $data);
    }
    
    public function createInvoice($data) {
        return $this->request('POST', '/invoices', $data);
    }
}

// Usage
try {
    $api = new DolibarrAPI('http://localhost:8080', 'your_api_key');
    
    // Create a company
    $companyData = [
        'name' => 'PHP Web Services',
        'client' => 1,
        'email' => 'contact@phpweb.com'
    ];
    
    $company = $api->createThirdParty($companyData);
    echo "Created company: " . json_encode($company) . "\n";
    
    // Get companies
    $companies = $api->getThirdParties(['limit' => 10]);
    echo "Companies: " . json_encode($companies) . "\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
```

### Bash/cURL Example

```bash
#!/bin/bash

API_KEY="your_api_key_here"
BASE_URL="http://localhost:8080/api/index.php"

# Function to make API requests
api_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    curl -s -X "$method" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -H "DOLAPIKEY: $API_KEY" \
        ${data:+-d "$data"} \
        "$BASE_URL/$endpoint"
}

# Get all third parties
echo "=== Getting Third Parties ==="
api_request "GET" "thirdparties?limit=5" | jq .

# Create a new third party
echo -e "\n=== Creating Third Party ==="
COMPANY_DATA='{
    "name": "Bash Automation Co",
    "client": 1,
    "email": "admin@bashautomation.com",
    "phone": "+1-555-BASH"
}'

COMPANY_RESPONSE=$(api_request "POST" "thirdparties" "$COMPANY_DATA")
echo "$COMPANY_RESPONSE" | jq .

# Extract company ID for invoice creation
COMPANY_ID=$(echo "$COMPANY_RESPONSE" | jq -r '.id // empty')

if [ ! -z "$COMPANY_ID" ]; then
    echo -e "\n=== Creating Invoice ==="
    INVOICE_DATA="{
        \"socid\": $COMPANY_ID,
        \"date\": \"$(date +%Y-%m-%d)\",
        \"lines\": [
            {
                \"description\": \"Automation Services\",
                \"qty\": 5,
                \"subprice\": 200.00
            }
        ]
    }"
    
    api_request "POST" "invoices" "$INVOICE_DATA" | jq .
fi
```

---

## SDKs and Libraries

### Official Libraries

Currently, Dolibarr doesn't provide official SDKs, but the REST API is standard and works with any HTTP client.

### Community Libraries

#### Node.js
```bash
npm install axios  # HTTP client
npm install dolibarr-api-client  # Community wrapper (if available)
```

#### Python
```bash
pip install requests  # HTTP client
pip install dolibarr-python  # Community wrapper (if available)
```

#### PHP
```php
// Use cURL or Guzzle HTTP client
composer require guzzlehttp/guzzle
```

### Creating Your Own SDK

When creating an SDK wrapper, consider implementing:

1. **Authentication handling**: Automatic API key inclusion
2. **Error handling**: Consistent error response parsing
3. **Rate limiting**: Built-in request throttling
4. **Pagination**: Helper methods for paginated results
5. **Type safety**: Strong typing for request/response objects
6. **Logging**: Request/response logging for debugging

---

## Testing and Development

### Enable API for Development

```bash
# Start services with tools
task services:start-with-tools

# Enable API module
task config:enable-api

# Check API status
curl -I "http://localhost:${DOLIBARR_PORT:-8080}/api/index.php/users" \
  -H "DOLAPIKEY: your_api_key"
```

### API Testing Tools

1. **Built-in Explorer**: `http://localhost:8080/api/index.php/explorer`
2. **Postman**: Create collections for API testing
3. **cURL**: Command-line testing
4. **HTTPie**: User-friendly HTTP client

### Development Best Practices

1. **Use Development Environment**: Test against development instances
2. **Version Control API Keys**: Never commit API keys
3. **Error Handling**: Always handle API errors gracefully
4. **Logging**: Log API requests for debugging
5. **Testing**: Write automated tests for API integrations
6. **Documentation**: Document your API usage and endpoints used

### Debugging API Issues

```bash
# Check if API module is enabled
task config:list-modules | grep API

# Test API connectivity
curl -v "http://localhost:8080/api/index.php/users" \
  -H "DOLAPIKEY: your_api_key"

# Check application logs
task services:logs-app | grep -i api

# Verify database permissions
task utilities:shell-db
> SELECT * FROM llx_user_api_keys WHERE api_key = 'your_api_key';
```

Remember to always test API integrations thoroughly and implement proper error handling in production applications!

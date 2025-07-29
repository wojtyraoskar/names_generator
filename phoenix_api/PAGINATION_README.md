# Pagination for List Users API

This document describes the pagination functionality that has been added to the `list_users` API endpoint.

## Overview

The `list_users` function now supports pagination with the following features:

- **Page-based pagination** with configurable page size
- **Total count metadata** for building pagination UI
- **Navigation helpers** (has_next, has_prev)
- **Combined filtering and pagination**

## API Endpoints

### GET /api/users

Returns a paginated list of users with metadata.

#### Query Parameters

- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 20)
- `first_name` (optional): Filter by first name (case-insensitive partial match)
- `last_name` (optional): Filter by last name (case-insensitive partial match)
- `birthdate` (optional): Filter by exact birthdate
- `gender` (optional): Filter by gender (`male` or `female`)

#### Response Format

```json
{
  "data": [
    {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "birthdate": "1990-01-01",
      "gender": "male",
      "inserted_at": "2025-07-29T19:42:25",
      "updated_at": "2025-07-29T19:42:25"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_count": 25,
    "total_pages": 2,
    "has_next": true,
    "has_prev": false
  }
}
```

## Examples

### Basic pagination
```
GET /api/users?page=2&per_page=10
```

### Filtered pagination
```
GET /api/users?gender=male&page=1&per_page=5
```

### Search with pagination
```
GET /api/users?first_name=john&page=1&per_page=10
```

## Implementation Details

### Service Layer Changes

The `PhoenixApi.RandomNames.Service.list_users/1` function now:

1. **Accepts pagination parameters**: `page` and `per_page`
2. **Returns structured response**: Contains both data and pagination metadata
3. **Calculates total count**: Applies the same filters to count query
4. **Provides navigation helpers**: `has_next` and `has_prev` flags

### Query Layer Changes

The `PhoenixApi.RandomNames.Query` module now includes:

- `page` field (default: 1)
- `per_page` field (default: 20)
- Pagination logic in `apply_filter/3` functions

### Controller Layer

The `PhoenixApiWeb.RandomNamesController` handles:

- Parameter parsing from query strings
- JSON serialization with proper status codes
- Error handling for invalid parameters

## Testing

The implementation includes comprehensive tests for:

- Basic pagination functionality
- Filtering with pagination
- Edge cases (empty results, last page, etc.)
- API endpoint behavior
- Service layer logic

Run tests with:
```bash
mix test
```

## Usage in Frontend

Example JavaScript for consuming the paginated API:

```javascript
async function fetchUsers(page = 1, perPage = 20, filters = {}) {
  const params = new URLSearchParams({
    page: page.toString(),
    per_page: perPage.toString(),
    ...filters
  });
  
  const response = await fetch(`/api/users?${params}`);
  const data = await response.json();
  
  return {
    users: data.data,
    pagination: data.pagination
  };
}

// Example usage
const { users, pagination } = await fetchUsers(1, 10, { gender: 'male' });
console.log(`Showing ${users.length} of ${pagination.total_count} users`);
console.log(`Page ${pagination.page} of ${pagination.total_pages}`);
``` 

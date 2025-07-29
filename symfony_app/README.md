# Symfony User Management System

A complete user management system built with Symfony that communicates with a Phoenix API backend.

## Features

- **User List** with filtering and sorting
- **Add New Users** (POST to Phoenix API)
- **Edit Users** (PUT to Phoenix API)
- **Delete Users** (DELETE to Phoenix API)
- **Advanced Filtering** by first name, last name, gender, and birthdate range
- **Column Sorting** with query parameters
- **Pagination** support
- **Flash Messages** for user feedback
- **Modern UI** with Bootstrap 5 and Font Awesome

## Prerequisites

- PHP 8.1 or higher
- Composer
- Symfony CLI (optional but recommended)
- The Phoenix API backend running on `http://localhost:4000`

## Installation

1. **Install dependencies:**
   ```bash
   composer install
   ```

2. **Configure the application:**
   - Copy `.env` to `.env.local` and configure your database settings
   - Update the API base URL in `src/Service/ApiService.php` if needed

3. **Start the development server:**
   ```bash
   symfony server:start
   ```
   Or with PHP's built-in server:
   ```bash
   php -S localhost:8000 -t public/
   ```

## Usage

1. **Start the Phoenix API backend first:**
   ```bash
   cd ../phoenix_api
   mix phx.server
   ```

2. **Access the application:**
   - Open your browser and go to `http://localhost:8000`
   - You'll be redirected to the user management system

## API Endpoints

The application communicates with the Phoenix API using these endpoints:

- `GET /api/users` - List users with filtering and pagination
- `GET /api/users/{id}` - Get a specific user
- `POST /api/users` - Create a new user
- `PUT /api/users/{id}` - Update a user
- `DELETE /api/users/{id}` - Delete a user

## Features in Detail

### Filtering
- **First Name**: Partial text search
- **Last Name**: Partial text search
- **Gender**: Dropdown selection (Male/Female)
- **Birthdate Range**: Date picker for from/to dates

### Sorting
- Click on any column header to sort
- Supports ascending/descending order
- Maintains current filters while sorting

### Pagination
- Configurable items per page
- Page navigation with previous/next
- Shows current page info

### User Management
- **Create**: Form with validation
- **Read**: Detailed user view
- **Update**: Edit form with pre-filled data
- **Delete**: Confirmation dialog

## File Structure

```
src/
├── Controller/
│   ├── HomeController.php      # Home page redirect
│   └── UserController.php      # Main user management controller
├── Entity/
│   └── User.php               # User entity with validation
├── Form/
│   ├── UserFilterType.php     # Filter form
│   └── UserType.php           # User create/edit form
├── Repository/
│   └── UserRepository.php     # Doctrine repository
└── Service/
    └── ApiService.php         # Phoenix API communication

templates/
├── base.html.twig             # Base template with Bootstrap
└── user/
    ├── index.html.twig        # User list with filters
    ├── new.html.twig          # Create user form
    ├── show.html.twig         # User details view
    └── edit.html.twig         # Edit user form
```

## Configuration

### API Configuration
Update the API base URL in `src/Service/ApiService.php`:
```php
private const API_BASE_URL = 'http://localhost:4000/api';
```

### Database Configuration
The application uses Doctrine ORM for entity management. Configure your database in `.env.local`:
```env
DATABASE_URL="mysql://user:password@localhost/database_name"
```

## Troubleshooting

1. **API Connection Issues:**
   - Ensure the Phoenix API is running on the correct port
   - Check the API base URL in `ApiService.php`
   - Verify network connectivity

2. **Form Validation Errors:**
   - Check that all required fields are filled
   - Ensure date format is correct (YYYY-MM-DD)
   - Verify gender selection is valid

3. **Flash Messages Not Showing:**
   - Ensure Bootstrap CSS and JS are loaded
   - Check that the base template includes the flash message section

## Development

### Adding New Features
1. Create/update entities in `src/Entity/`
2. Add form types in `src/Form/`
3. Update controllers in `src/Controller/`
4. Create templates in `templates/`

### API Integration
The `ApiService` class handles all communication with the Phoenix API. To add new endpoints:
1. Add methods to `ApiService`
2. Update the controller to use the new service methods
3. Handle errors appropriately

## License

This project is open source and available under the MIT License. 

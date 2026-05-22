# weatherboo
Your daily weather, but make it wholesome. Weatherboo tells you the forecast, suggests your outfit, and hypes you up before you even finish your coffee. ☀️🌧️ Available wherever the vibe needs lifting.

## Running the App

### Web (Port 9000)
To run the app on port 9000, use:
```bash
flutter run -d chrome --web-port 9000
```

### Mobile
```bash
flutter run
```

## App Routes

The app uses named routes for navigation. Here's a detailed breakdown:

### `/splash` - Splash Screen
- **Purpose**: Initial screen that displays the app logo for 3 seconds
- **Navigation**: Automatically redirects to `/login` after 3 seconds
- **Components**: Custom logo widget with gradient design

### `/login` - Login Screen
- **Purpose**: User authentication screen
- **Navigation**: 
  - On successful login → `/home`
  - Sign up link → `/signup`
- **Components**: 
  - Email field
  - Password field (with visibility toggle)
  - Sign in button
  - Sign up link
- **Features**: 
  - Uses UserProvider for authentication
  - Shows specific error messages for email confirmation and invalid credentials
  - Custom logo display

### `/signup` - Sign Up Screen
- **Purpose**: New user registration
- **Navigation**: 
  - On successful signup → `/login` (with success message)
- **Components**:
  - Email field
  - Password field
  - Confirm password field
  - Sign up button
- **Features**:
  - Uses UserProvider for registration
  - Auto-signs in user after successful signup
  - Creates user profile in Supabase database

### `/home` - Home Screen
- **Purpose**: Main dashboard after login
- **Navigation**:
  - Profile icon → `/profile`
  - Sign out → `/login`
- **Components**:
  - Custom logo
  - Welcome message
  - User email display
  - Sign out button
- **Features**:
  - Displays current logged-in user email
  - Sign out functionality via UserProvider

### `/profile` - Profile Screen
- **Purpose**: User profile management
- **Navigation**:
  - Back button → returns to previous screen
- **Components**:
  - Profile picture (with upload functionality)
  - Personal information form (display name, email, phone, location, bio)
  - Weather preferences (default city, temperature unit, notifications)
  - User stats section
- **Features**:
  - Edit mode toggle
  - Profile picture upload to Supabase storage (web and mobile compatible)
  - Email update via Supabase auth
  - Auto-creates profile if it doesn't exist in database
  - Real-time data loading from UserProvider

## Architecture

### State Management
- **Provider**: Used for state management with UserProvider
- **UserProvider**: Manages authentication state, user profile data, and Supabase interactions

### Backend
- **Supabase**: Authentication, database (profiles table), and storage (profile_pictures bucket)

### Database Schema
- **profiles table**: Stores user profile information
  - id (UUID, references auth.users)
  - display_name
  - email
  - phone
  - location
  - bio
  - default_city
  - temperature_unit
  - notifications_enabled
  - profile_picture_url
  - created_at
  - updated_at

### Storage
- **profile_pictures bucket**: Stores user profile pictures
  - Public access for viewing
  - User-specific upload permissions

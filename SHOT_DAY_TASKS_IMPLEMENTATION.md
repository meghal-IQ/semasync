# Shot Day Tasks - Database Implementation

## Overview
Implemented a complete database-backed solution for Shot Day tasks that persists across devices and allows viewing historical task completion states.

## Backend Changes

### 1. New Model: `ShotDayTask.ts`
- **Location**: `backend/src/models/ShotDayTask.ts`
- **Purpose**: MongoDB schema for storing shot day tasks
- **Fields**:
  - `userId`: Reference to user
  - `date`: Date of the tasks (indexed)
  - `tasks`: Array of task objects with:
    - `title`: Task description
    - `time`: Scheduled time
    - `completed`: Boolean completion status
    - `isMainTask`: Optional flag for main task (e.g., "Take Shot")
  - `selectedDays`: Array of integers (1-7) representing selected shot days
  - `timestamps`: Auto-managed createdAt/updatedAt

### 2. New API Routes: `shotDayTasks.ts`
- **Location**: `backend/src/routes/shotDayTasks.ts`
- **Base Path**: `/api/shot-day-tasks`

#### Endpoints:
1. **GET** `/` - Get shot day tasks for a specific date
   - Query param: `date` (optional, ISO8601 format)
   - Returns existing tasks or creates default tasks if none exist
   
2. **PUT** `/` - Update shot day tasks
   - Body: `{ date, tasks, selectedDays }`
   - Updates or creates task record for the date
   
3. **PUT** `/selected-days` - Update selected shot days
   - Body: `{ selectedDays }`
   - Updates the days of week when shots are scheduled
   
4. **PATCH** `/toggle-task` - Toggle a specific task
   - Body: `{ date, taskIndex }`
   - Toggles completion status of a single task

### 3. Updated `index.ts`
- Added import for `shotDayTasksRoutes`
- Registered route: `app.use('/api/shot-day-tasks', shotDayTasksRoutes)`

## Frontend Changes

### 1. New API Service: `shot_day_tasks_api.dart`
- **Location**: `lib/core/api/shot_day_tasks_api.dart`
- **Purpose**: Dio-based API client for shot day tasks
- **Methods**:
  - `getShotDayTasks({String? date})`
  - `updateShotDayTasks({required String date, required List tasks, List<int>? selectedDays})`
  - `updateSelectedDays({required List<int> selectedDays})`
  - `toggleTask({required String date, required int taskIndex})`

### 2. New Provider: `shot_day_tasks_provider.dart`
- **Location**: `lib/core/providers/shot_day_tasks_provider.dart`
- **Purpose**: State management for shot day tasks
- **Features**:
  - Loads tasks from API for any date
  - Optimistic updates for instant UI feedback
  - Automatic error handling and rollback
  - Methods:
    - `loadTasks({DateTime? date})`
    - `toggleTask(int taskIndex)`
    - `updateTasks(List tasks)`
    - `updateSelectedDays(List<int> days)`
    - `resetAllTasks()`
    - `isShotDay()`

### 3. Updated Widget: `shot_day_widget.dart`
- **Location**: `lib/features/dashboard/presentation/widgets/shot_day_widget.dart`
- **Changes**:
  - Removed SharedPreferences dependency
  - Now uses `ShotDayTasksProvider` via Consumer
  - Supports optional `date` parameter for historical views
  - Real-time sync with database
  - Optimistic UI updates

### 4. Updated Widget: `ShotDaySelector`
- **Changes**:
  - Removed manual state management
  - Now uses `ShotDayTasksProvider` via Consumer
  - Automatically syncs selected days with database
  - No longer requires props to be passed

### 5. Updated `main.dart`
- Added `ShotDayTasksProvider` to MultiProvider
- Import: `import 'core/providers/shot_day_tasks_provider.dart'`

### 6. Updated `simple_semasync_dashboard.dart`
- Simplified `ShotDayWidget` usage: `const ShotDayWidget()`
- Removed manual state management (`_shotDays`)

## Features

### ✅ Database Persistence
- All task states stored in MongoDB
- Syncs across all user devices
- Historical data preserved

### ✅ Historical View Support
- Can view task completion for any past date
- Useful for tracking compliance over time
- Pass `date` parameter to `ShotDayWidget`

### ✅ Optimistic Updates
- UI updates immediately on user interaction
- Background sync with server
- Automatic rollback on errors

### ✅ Default Tasks
- Automatically creates default tasks if none exist:
  1. High-Protein Meal/Drink (7:00 PM)
  2. Drink lots of Water (+electrolytes) (7:00 PM)
  3. Load Syringe and let come to room temp (7:15 PM)
  4. Take Shot (8:00 PM) - Main Task
  5. Another High Protein Meal/Drink (9:00 PM)

### ✅ Shot Day Selection
- Select which days of the week are shot days
- Widget only appears on selected days
- Stored per user in database

### ✅ Reset Functionality
- "Reset" button to uncheck all tasks
- Useful for starting a new shot day
- Syncs with database

## API Testing

### Test Get Tasks
```bash
curl -X GET "http://your-api-url/api/shot-day-tasks?date=2025-10-15" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test Toggle Task
```bash
curl -X PATCH "http://your-api-url/api/shot-day-tasks/toggle-task" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"date":"2025-10-15","taskIndex":0}'
```

### Test Update Selected Days
```bash
curl -X PUT "http://your-api-url/api/shot-day-tasks/selected-days" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"selectedDays":[1,4,7]}'
```

## Deployment

### Backend
```bash
cd backend
npm run build
npm run deploy  # If using PM2
```

### Frontend
```bash
flutter pub get
flutter run
```

## Migration Notes

- **No data migration needed** - System creates default tasks on first access
- **Backward compatible** - Works with existing user accounts
- **SharedPreferences removed** - Old local data will be ignored

## Future Enhancements

1. **Custom Task Times**: Allow users to customize task times
2. **Custom Tasks**: Allow users to add/remove tasks
3. **Reminders**: Push notifications for upcoming tasks
4. **Streaks**: Track consecutive days of task completion
5. **Analytics**: View completion rates over time
6. **Task Notes**: Add notes to completed tasks


# To-Do List App: Product Backlog

## Product Goal
> "To build a secure, cloud-native, and offline-first mobile application that empowers users to capture, organize, and track their daily tasks seamlessly across multiple devices, ensuring no important commitment is overlooked regardless of internet connectivity."

---

## Epics & User Stories

### Epic 1: Identity & Cloud Infrastructure
> *Focuses on securing user access, maintaining sessions, and establishing the robust cloud database connection required for offline-first capabilities.*

#### User Story #1: User Authentication (Sign Up, Log In & Log Out)
**Description:**
*As a* user,
*I want to* securely create an account, log in, and log out of the application,
*So that* my tasks are linked exclusively to my identity, protected from unauthorized access, and I have control over my active session.

**Acceptance Criteria:**
* **Scenario 1: Successful account creation and feedback**
  * **Given** the user is on the AuthScreen,
  * **When** they enter a valid email and password and tap "Sign Up",
  * **Then** a new user account must be created in Firebase Authentication, and a success message (floating SnackBar) must confirm the registration before routing to the main screen.
* **Scenario 2: Successful user login**
  * **Given** the user has an existing account,
  * **When** they input their correct credentials and tap "Log In",
  * **Then** the system must authenticate the session and navigate to the task list, displaying a welcome message (floating SnackBar).
* **Scenario 3: Empty field prevention (Client-Side Validation)**
  * **Given** the user is on the AuthScreen,
  * **When** they attempt to log in or sign up leaving the email or password field empty,
  * **Then** the system must prevent the authentication attempt and display a warning message (floating SnackBar) stating "Please fill in all fields."
* **Scenario 4: Handling invalid login attempts**
  * **Given** the user is on the AuthScreen with filled fields,
  * **When** they attempt to log in with an unregistered email or incorrect password,
  * **Then** the system must explicitly display a red error message (floating SnackBar) informing them that authentication failed, preventing the UI from freezing.
* **Scenario 5: Authentication persistence**
  * **Given** the user has previously logged in,
  * **When** they close and reopen the application,
  * **Then** the `AuthWrapper` must bypass the login screen and route them directly to their data stream.
* **Scenario 6: User Logout**
  * **Given** the user is successfully logged in and viewing their tasks,
  * **When** they tap the "Logout" icon in the application's top app bar,
  * **Then** their Firebase session must be terminated, clearing local memory, and they must be immediately redirected back to the AuthScreen.

#### User Story #2: Cloud Data Synchronization (Firestore)
**Description:**
*As a* user,
*I want* my tasks and categories to be automatically saved to a secure cloud database,
*So that* I never lose my information if my device is lost, damaged, or replaced, and my data is instantly available on any device I log into.

**Acceptance Criteria:**
* **Scenario 1: Securing data by User ID**
  * **Given** the user creates a new task,
  * **When** the system saves it to the Firestore database,
  * **Then** the task record must contain the authenticated user's unique `appUserId` to ensure data isolation.
* **Scenario 2: Real-time UI updates (Reactive Stream)**
  * **Given** the application is connected to the Firestore data stream,
  * **When** a change occurs in the cloud database (e.g., adding or updating a task),
  * **Then** the active UI must rebuild automatically to reflect the latest state without requiring a manual pull-to-refresh.
* **Scenario 3: Fetching cross-device data**
  * **Given** the user installs the app on a new device and logs in,
  * **When** the main screen loads,
  * **Then** the system must query Firestore using a composite index (filtering by `appUserId` and ordering by `createdAt`) and display all their historical tasks.

#### User Story #3: Offline-First Reliability (Full CRUD)
**Description:**
*As a* user,
*I want to* manage my tasks normally even when I don't have internet access,
*So that* my productivity is never halted by connectivity issues, knowing my data will eventually sync.

**Acceptance Criteria:**
* **Scenario 1: Full CRUD operations offline (Create, Update, Delete)**
  * **Given** the device is completely disconnected from the internet,
  * **When** the user creates a new task, edits an existing one, or deletes a task,
  * **Then** the UI must update instantly via the reactive stream, and the exact state change must be securely stored in the local Firebase cache.
* **Scenario 2: Background synchronization upon reconnection**
  * **Given** the user has made changes (creations, edits, or deletions) while offline,
  * **When** the device reconnects to a stable internet connection,
  * **Then** the system must automatically sync all pending local actions to the Firestore cloud database in the background without user intervention.

---

### Epic 2: Task Management & UI
> *Focuses on the core functionalities that allow the user to interact with their tasks, providing a smooth, intuitive, and responsive interface.*

#### User Story #4: Create a New Task
**Description:**
*As a* user,
*I want to* add a new task to my list,
*So that* I can record what I need to do and have it instantly backed up to the cloud.

**Acceptance Criteria:**
* **Scenario 1: Successful task creation and cloud save**
  * **Given** the user inputs a title, optional description, and selects a category in the Modal Bottom Sheet,
  * **When** they tap "Save Task",
  * **Then** the `TaskProvider` must generate a new Task object bound to the user's `appUserId` and push it to the `CloudStorageRepository`.
* **Scenario 2: Real-time list rendering**
  * **Given** the new task is successfully pushed to Firestore,
  * **When** the Firestore Stream emits the updated list,
  * **Then** the new task must be rendered at the top of the To-Do list automatically, without manual UI intervention.
* **Scenario 3: Empty task prevention**
  * **Given** the task title field is empty,
  * **When** the user attempts to tap "Save",
  * **Then** the action must be prevented, and a `fixed` SnackBar warning must indicate that the title cannot be empty.

#### User Story #5: Mark a Task as Completed
**Description:**
*As a* user,
*I want to* mark a task as completed,
*So that* I can track my progress and update my status across all my synced devices.

**Acceptance Criteria:**
* **Scenario 1: Marking as done and cloud update**
  * **Given** an active task is displayed on the list,
  * **When** the user taps the checkbox next to it,
  * **Then** the task's status (`isCompleted`) must change to `true` and the update must be sent to the Firestore document.
* **Scenario 2: Visual feedback**
  * **Given** the Firestore Stream confirms the task is completed,
  * **When** it is displayed on the screen,
  * **Then** it must have a clear visual indicator (a strikethrough text style and greyed out tone) to differentiate it from pending tasks.

#### User Story #6: Delete an Existing Task
**Description:**
*As a* user,
*I want to* delete a task from my list,
*So that* I can discard items I no longer plan to do and remove them permanently from my cloud database.

**Acceptance Criteria:**
* **Scenario 1: Triggering the deletion**
  * **Given** the user is viewing their list of tasks,
  * **When** they swipe left on a specific task (`Dismissible` widget),
  * **Then** the document must be deleted from the Firestore database, and the Stream will automatically remove it from the UI.
* **Scenario 2: Grace period (Undo action)**
  * **Given** the user has just swiped to delete a task,
  * **When** the task disappears,
  * **Then** a `fixed` temporary SnackBar must appear at the bottom of the screen offering an "Undo" button.
* **Scenario 3: Recovering a deleted task**
  * **Given** the deletion SnackBar is active,
  * **When** the user taps "Undo",
  * **Then** the system must re-insert the exact same Task object back into Firestore, causing the Stream to seamlessly render it back in the list.

#### User Story #7: Edit an Existing Task
**Description:**
*As a* user,
*I want to* modify the text or category of a task I already created,
*So that* I can fix typos or update my objective, keeping my cloud records accurate.

**Acceptance Criteria:**
* **Scenario 1: Entering edit mode**
  * **Given** the user is viewing their task list,
  * **When** they tap and hold (long press) on a specific task,
  * **Then** the Modal Bottom Sheet must open, pre-filled with the current title, description, and selected category.
* **Scenario 2: Saving the modification to the cloud**
  * **Given** the user is in edit mode and has changed the text or category,
  * **When** they tap "Update Task",
  * **Then** the specific document in Firestore must be updated, and the Stream will refresh the UI to reflect the new data.

#### User Story #8: Filter Tasks by Status & Category
**Description:**
*As a* user,
*I want to* filter my tasks locally to see all, only pending, or only completed tasks, and combine this with category filters,
*So that* I can easily focus on specific areas of my life without making unnecessary queries to the database.

**Acceptance Criteria:**
* **Scenario 1: Local state filtering**
  * **Given** the `TaskProvider` has loaded all the user's tasks from the Firestore Stream,
  * **When** the user switches TabBar views (Pending/Completed) or taps a Category Chip,
  * **Then** the UI must filter the existing data strictly in the device's memory (using Dart getters) without querying the cloud again, saving bandwidth and read operations.
* **Scenario 2: Empty state handling**
  * **Given** the user applies a filter,
  * **When** there are no tasks matching that criteria locally,
  * **Then** a friendly message ("No tasks found in this section") must be displayed in the center of the screen.

---

## Future Backlog (Out of Current Scope)
> *The following items represent future iterations, scaling opportunities, and technical debt that will be addressed in upcoming sprints.*

**Feature Enhancements:**
* **Local Notifications & Reminders:** Implement local push notifications (via `flutter_local_notifications`) to alert the user about upcoming deadlines.
* **User Profile Module:** Create a new Feature module (`features/profile`) allowing users to view their authenticated email, change their password, and potentially upload a profile picture.
* **Dynamic Category Management (CRUD):** Migrate the currently static categories into a user-specific Firestore collection, allowing users to create, edit, delete, and color-code their own custom tags.
  * **UI Scalability Redesign:** Replace the horizontal filter chips on the main screen with a scalable filtering solution (e.g., a "Filter" action button opening a Modal Bottom Sheet) to accommodate an unlimited number of custom categories without cluttering the UI.

**Technical Debt & Refactoring:**
* **UI Componentization:** Break down large presentation files (like `task_bottom_sheet.dart`) into smaller, modular, and single-responsibility functional widgets to ensure maximum readability and UI reusability.
* **UI Refactoring (Auth Screen Keyboard Issue):** Investigate and fix the `SnackBar` floating behavior on the `AuthScreen` so it does not shift unexpectedly or overlap UI elements when the native keyboard pushes the screen content up (`viewInsets` handling).
* **Automated Testing:** Configure the Flutter testing environment and implement Unit Tests for the `TaskProvider` and `AuthProvider` utilizing Mockito to simulate Firestore Streams without hitting the real database.

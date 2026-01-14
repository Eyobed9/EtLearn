# Database Schema Documentation

This document describes the database schema for the Peer-to-Peer Learning App.

## Core Tables

### 1. `users` Table
Stores user profile information.

```sql
CREATE TABLE IF NOT EXISTS users (
  uid TEXT PRIMARY KEY,                  -- Firebase UID
  email TEXT UNIQUE,
  full_name TEXT,
  photo_url TEXT,
  bio TEXT,
  subjects_teach TEXT[],                 -- Array of subjects user can teach
  skills TEXT[],                         -- Array of skills/interests
  credits INT DEFAULT 0,
  streak INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 2. `courses` Table
Stores course listings created by mentors.

```sql
CREATE TABLE IF NOT EXISTS courses (
  id SERIAL PRIMARY KEY,
  creator_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  title TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  duration_minutes INT,                  -- total duration in minutes
  level TEXT DEFAULT 'Beginner' CHECK (level IN ('Beginner','Intermediate','Advanced')),
  credit_cost INT DEFAULT 0,            -- credits required to learn
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 3. `course_requests` Table
Stores course requests from learners to mentors.

```sql
CREATE TABLE IF NOT EXISTS course_requests (
  id SERIAL PRIMARY KEY,
  course_id INT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  learner_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  mentor_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(course_id, learner_uid)
);
```

### 4. `enrollments` Table
Tracks course enrollments (created when request is accepted).

```sql
CREATE TABLE IF NOT EXISTS enrollments (
  id SERIAL PRIMARY KEY,
  course_id INT REFERENCES courses(id) ON DELETE CASCADE,
  learner_uid TEXT REFERENCES users(uid) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ DEFAULT now(),
  progress_percentage INT DEFAULT 0,     -- 0-100
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed','dropped')),
  last_access TIMESTAMPTZ
);
```

### 5. `messages` Table
Stores 1-1 messages between peers (after request acceptance).

```sql
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  sender_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  receiver_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  course_id INT REFERENCES courses(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 6. `credit_transactions` Table (Optional)
Tracks credit transactions for history.

```sql
CREATE TABLE IF NOT EXISTS credit_transactions (
  id SERIAL PRIMARY KEY,
  user_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  amount INT NOT NULL,                   -- positive for earnings, negative for spending
  type TEXT NOT NULL CHECK (type IN ('earn','spend')),
  description TEXT,
  related_course_id INT REFERENCES courses(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

## Key Relationships

- Users can create multiple courses (`courses.creator_uid` → `users.uid`)
- Learners can request to learn courses (`course_requests.learner_uid` → `users.uid`)
- Mentors receive course requests (`course_requests.mentor_uid` → `users.uid`)
- Accepted requests create enrollments (`enrollments.learner_uid` → `users.uid`)
- Users can send messages to each other (`messages.sender_uid` / `receiver_uid` → `users.uid`)

## Indexes (Recommended)

```sql
CREATE INDEX IF NOT EXISTS idx_courses_creator_uid ON courses(creator_uid);
CREATE INDEX IF NOT EXISTS idx_course_requests_learner_uid ON course_requests(learner_uid);
CREATE INDEX IF NOT EXISTS idx_course_requests_mentor_uid ON course_requests(mentor_uid);
CREATE INDEX IF NOT EXISTS idx_course_requests_course_id ON course_requests(course_id);
CREATE INDEX IF NOT EXISTS idx_course_requests_status ON course_requests(status);
CREATE INDEX IF NOT EXISTS idx_enrollments_learner_uid ON enrollments(learner_uid);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_uid ON messages(receiver_uid);
CREATE INDEX IF NOT EXISTS idx_messages_sender_uid ON messages(sender_uid);
```

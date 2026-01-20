CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

-- Admin!23 (bcrypt hash)
INSERT INTO users (user_name, email, password, role)
VALUES (
    'admin user',
    'admin@mail.com',
    '$2b$12$C1gO1VlmA4Fz1ZQeZbZ7S.5f3iYkT5rZ3p6nFf9LJH0oXJqVQyKcW',
    'admin'
);
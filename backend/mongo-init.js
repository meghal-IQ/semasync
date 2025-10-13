// MongoDB initialization script
db = db.getSiblingDB('semasync');

// Create user for the application
db.createUser({
  user: 'semasync_user',
  pwd: 'semasync_password',
  roles: [
    {
      role: 'readWrite',
      db: 'semasync'
    }
  ]
});

// Create collections and indexes
db.createCollection('users');

// Create indexes for better performance
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true, sparse: true });
db.users.createIndex({ createdAt: -1 });

print('Database initialized successfully!');

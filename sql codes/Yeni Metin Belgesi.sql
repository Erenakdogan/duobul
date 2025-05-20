

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    profile_photo LONGBLOB,
    favorite_games TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 

-- Arkadaşlık tablosu
CREATE TABLE friendships (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sender_email VARCHAR(255) NOT NULL,
    receiver_email VARCHAR(255) NOT NULL,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_email) REFERENCES users(email),
    FOREIGN KEY (receiver_email) REFERENCES users(email)
);

-- Ortak favori oyunlar için view
CREATE VIEW common_favorite_games AS
SELECT 
    f.sender_email,
    f.receiver_email,
    u1.favorite_games as sender_games,
    u2.favorite_games as receiver_games
FROM friendships f
JOIN users u1 ON f.sender_email = u1.email
JOIN users u2 ON f.receiver_email = u2.email
WHERE f.status = 'accepted';

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_email VARCHAR(255) NOT NULL,
    receiver_email VARCHAR(255) NOT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_email) REFERENCES users(email),
    FOREIGN KEY (receiver_email) REFERENCES users(email)
);

CREATE TABLE `user_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `game_type` varchar(50) NOT NULL,
  `rank` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_game_type` (`email`, `game_type`),
  KEY `idx_rank` (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE users CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE user_ranks CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

ALTER TABLE users MODIFY email VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE user_ranks MODIFY email VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

ALTER TABLE users ADD COLUMN steam_url VARCHAR(255);
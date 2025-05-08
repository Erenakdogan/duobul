<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

try {
    // Veritabanı bağlantısı
    $pdo = new PDO("mysql:host=localhost;port=3307;dbname=usersinfo", "root", "");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // POST verilerini al
    $data = json_decode(file_get_contents('php://input'), true);
    $userEmail = $data['user_email'] ?? '';
    $friendEmail = $data['friend_email'] ?? '';

    if (empty($userEmail) || empty($friendEmail)) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik veri gönderildi'
        ]);
        exit;
    }

    // Mesajları getir
    $stmt = $pdo->prepare("
        SELECT m.*, 
               u1.username as sender_username,
               u2.username as receiver_username
        FROM messages m
        JOIN users u1 ON m.sender_email = u1.email
        JOIN users u2 ON m.receiver_email = u2.email
        WHERE (m.sender_email = :user_email AND m.receiver_email = :friend_email)
           OR (m.sender_email = :friend_email AND m.receiver_email = :user_email)
        ORDER BY m.sent_at ASC
    ");
    
    $stmt->execute([
        ':user_email' => $userEmail,
        ':friend_email' => $friendEmail
    ]);
    
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Okunmamış mesajları okundu olarak işaretle
    $updateStmt = $pdo->prepare("
        UPDATE messages 
        SET is_read = TRUE 
        WHERE sender_email = :friend_email 
        AND receiver_email = :user_email 
        AND is_read = FALSE
    ");
    
    $updateStmt->execute([
        ':friend_email' => $friendEmail,
        ':user_email' => $userEmail
    ]);

    echo json_encode([
        'success' => true,
        'messages' => $messages
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
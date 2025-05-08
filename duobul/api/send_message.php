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
    $senderEmail = $data['sender_email'] ?? '';
    $receiverEmail = $data['receiver_email'] ?? '';
    $messageText = $data['message_text'] ?? '';

    if (empty($senderEmail) || empty($receiverEmail) || empty($messageText)) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik veri gönderildi'
        ]);
        exit;
    }

    // Mesajı kaydet
    $stmt = $pdo->prepare("INSERT INTO messages (sender_email, receiver_email, message_text) VALUES (:sender_email, :receiver_email, :message_text)");
    $stmt->execute([
        ':sender_email' => $senderEmail,
        ':receiver_email' => $receiverEmail,
        ':message_text' => $messageText
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Mesaj başarıyla gönderildi'
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
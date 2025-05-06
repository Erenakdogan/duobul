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

    if (empty($senderEmail) || empty($receiverEmail)) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik veri gönderildi'
        ]);
        exit;
    }

    // Alıcının var olup olmadığını kontrol et
    $stmt = $pdo->prepare("SELECT email FROM users WHERE email = :email");
    $stmt->execute([':email' => $receiverEmail]);
    if (!$stmt->fetch()) {
        echo json_encode([
            'success' => false,
            'error' => 'Kullanıcı bulunamadı'
        ]);
        exit;
    }

    // Daha önce istek gönderilmiş mi kontrol et
    $stmt = $pdo->prepare("SELECT id FROM friendships WHERE sender_email = :sender_email AND receiver_email = :receiver_email");
    $stmt->execute([
        ':sender_email' => $senderEmail,
        ':receiver_email' => $receiverEmail
    ]);
    if ($stmt->fetch()) {
        echo json_encode([
            'success' => false,
            'error' => 'Bu kullanıcıya zaten istek gönderilmiş'
        ]);
        exit;
    }

    // Arkadaşlık isteği gönder
    $stmt = $pdo->prepare("INSERT INTO friendships (sender_email, receiver_email) VALUES (:sender_email, :receiver_email)");
    $stmt->execute([
        ':sender_email' => $senderEmail,
        ':receiver_email' => $receiverEmail
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Arkadaşlık isteği gönderildi'
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
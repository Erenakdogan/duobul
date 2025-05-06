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
    $status = $data['status'] ?? '';

    if (empty($senderEmail) || empty($receiverEmail) || empty($status)) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik veri gönderildi'
        ]);
        exit;
    }

    if (!in_array($status, ['accepted', 'rejected'])) {
        echo json_encode([
            'success' => false,
            'error' => 'Geçersiz durum'
        ]);
        exit;
    }

    // İsteği güncelle
    $stmt = $pdo->prepare("
        UPDATE friendships 
        SET status = :status 
        WHERE sender_email = :sender_email 
        AND receiver_email = :receiver_email 
        AND status = 'pending'
    ");
    $stmt->execute([
        ':status' => $status,
        ':sender_email' => $senderEmail,
        ':receiver_email' => $receiverEmail
    ]);

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => $status === 'accepted' ? 'Arkadaşlık isteği kabul edildi' : 'Arkadaşlık isteği reddedildi'
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'İstek bulunamadı veya zaten yanıtlanmış'
        ]);
    }

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
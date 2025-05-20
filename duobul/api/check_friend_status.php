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
    $targetEmail = $data['target_email'] ?? '';

    if (empty($userEmail) || empty($targetEmail)) {
        echo json_encode([
            'success' => false,
            'error' => 'Eksik veri gönderildi'
        ]);
        exit;
    }

    // Arkadaşlık durumunu kontrol et
    $stmt = $pdo->prepare("
        SELECT status, created_at 
        FROM friendships 
        WHERE ((sender_email = :user_email AND receiver_email = :target_email)
        OR (sender_email = :target_email AND receiver_email = :user_email))
        ORDER BY created_at DESC 
        LIMIT 1
    ");
    
    $stmt->execute([
        ':user_email' => $userEmail,
        ':target_email' => $targetEmail
    ]);
    
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode([
            'success' => true,
            'isFriend' => $result['status'] === 'accepted',
            'status' => $result['status'],
            'created_at' => $result['created_at']
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'isFriend' => false,
            'status' => 'none',
            'created_at' => null
        ]);
    }

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?> 
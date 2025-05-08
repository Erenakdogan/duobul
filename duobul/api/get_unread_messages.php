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

    if (empty($userEmail)) {
        echo json_encode([
            'success' => false,
            'error' => 'E-posta adresi gerekli'
        ]);
        exit;
    }

    // Her arkadaş için okunmamış mesaj sayısını getir
    $stmt = $pdo->prepare("
        SELECT 
            sender_email,
            COUNT(*) as unread_count
        FROM messages
        WHERE receiver_email = :user_email
        AND is_read = FALSE
        GROUP BY sender_email
    ");
    
    $stmt->execute([':user_email' => $userEmail]);
    $unreadCounts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'unread_counts' => $unreadCounts
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
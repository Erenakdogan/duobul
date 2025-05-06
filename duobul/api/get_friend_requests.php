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
    $email = $data['email'] ?? '';

    if (empty($email)) {
        echo json_encode([
            'success' => false,
            'error' => 'E-posta adresi gerekli'
        ]);
        exit;
    }

    // Bekleyen arkadaşlık isteklerini getir
    $stmt = $pdo->prepare("
        SELECT u.username, u.email
        FROM friendships f
        JOIN users u ON f.sender_email = u.email
        WHERE f.receiver_email = :email AND f.status = 'pending'
    ");
    $stmt->execute([':email' => $email]);
    $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'requests' => $requests
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
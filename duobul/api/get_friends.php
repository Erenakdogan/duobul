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

    // Arkadaş listesini getir
    $stmt = $pdo->prepare("
        SELECT u.username, u.email
        FROM friendships f
        JOIN users u ON (
            CASE 
                WHEN f.sender_email = :email THEN f.receiver_email = u.email
                ELSE f.sender_email = u.email
            END
        )
        WHERE (f.sender_email = :email OR f.receiver_email = :email)
        AND f.status = 'accepted'
    ");
    $stmt->execute([':email' => $email]);
    $friends = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'friends' => $friends
    ]);

} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
} 
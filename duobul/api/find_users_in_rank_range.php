<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input || !isset($input['min_rank']) || !isset($input['max_rank']) || !isset($input['email'])) {
        throw new Exception("Eksik veri");
    }

    $pdo = new PDO(
        'mysql:host=192.168.51.187;port=3307;dbname=usersinfo',
        'root',
        '',
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );

    $stmt = $pdo->prepare("
        SELECT u.username, r.email, r.rank
        FROM user_ranks r
        JOIN users u ON r.email = u.email
        WHERE r.email != :email
          AND r.rank BETWEEN :min_rank AND :max_rank
        ORDER BY r.rank ASC
        LIMIT 20
    ");
    $stmt->execute([
        ':email' => $input['email'],
        ':min_rank' => (int)$input['min_rank'],
        ':max_rank' => (int)$input['max_rank']
    ]);
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($users && count($users) > 0) {
        echo json_encode(['success' => true, 'users' => $users]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Belirtilen aralıkta kullanıcı yok']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?> 
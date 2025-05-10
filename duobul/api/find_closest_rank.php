<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

try {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input || !isset($input['rank']) || !isset($input['email'])) {
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

    // Kendi emailini hariç tutarak en yakın 3 rankı bul, kullanıcı adını da getir
    $stmt = $pdo->prepare("
        SELECT u.username, r.email, r.rank, ABS(r.rank - :rank) AS fark
        FROM user_ranks r
        JOIN users u ON r.email = u.email
        WHERE r.email != :email
        ORDER BY fark ASC
        LIMIT 3
    ");
    $stmt->execute([
        ':rank' => (int)$input['rank'],
        ':email' => $input['email']
    ]);
    $closest = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($closest && count($closest) > 0) {
        echo json_encode(['success' => true, 'closest' => $closest]);
    } else {
        echo json_encode(['success' => false, 'error' => 'Başka kullanıcı yok']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?> 
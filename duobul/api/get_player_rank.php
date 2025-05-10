<?php
header("Content-Type: application/json");
require_once 'db_connect.php';

$data = json_decode(file_get_contents("php://input"), true);

$email = $data['email'] ?? '';
$gameType = $data['game_type'] ?? '';

try {
    $stmt = $pdo->prepare("
        SELECT rank, role FROM user_ranks 
        WHERE user_email = :email AND game_type = :game_type
    ");
    
    $stmt->execute([':email' => $email, ':game_type' => $gameType]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'rank' => $result['rank'] ?? null,
        'role' => $result['role'] ?? null
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'db_connect.php';

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['email']) || !isset($data['rank'])) {
    echo json_encode(['success' => false, 'message' => 'Eksik parametreler']);
    exit;
}

$email = $data['email'];
$targetRank = $data['rank'];

try {
    // Kullanıcının oyun tipini al
    $stmt = $conn->prepare("SELECT game_type FROM player_ranks WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'Kullanıcı rank bilgisi bulunamadı']);
        exit;
    }
    
    $row = $result->fetch_assoc();
    $gameType = $row['game_type'];
    
    // En yakın rankı bul
    $stmt = $conn->prepare("
        SELECT email, rank, ABS(rank - ?) as rank_diff 
        FROM player_ranks 
        WHERE game_type = ? AND email != ? 
        ORDER BY rank_diff ASC 
        LIMIT 1
    ");
    $stmt->bind_param("iss", $targetRank, $gameType, $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        echo json_encode([
            'success' => true,
            'email' => $row['email'],
            'rank' => $row['rank'],
            'rank_diff' => $row['rank_diff']
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Yakın rank bulunamadı']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Hata: ' . $e->getMessage()]);
}

$stmt->close();
$conn->close();
?> 
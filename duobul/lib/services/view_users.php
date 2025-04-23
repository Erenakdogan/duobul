<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// MySQL bağlantı bilgileri
$host = 'localhost';
$dbname = 'duobul_db';
$username = 'root';
$password = 'Sagu97714B';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Kullanıcıları getir
    $stmt = $pdo->query("SELECT id, username, email, created_at FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'users' => $users
    ]);
} catch(PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Veritabanı hatası: ' . $e->getMessage()
    ]);
}
?> 
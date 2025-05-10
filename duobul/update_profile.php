<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "duobul";
$port = 3307;

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}

$user_id = $_POST['user_id'];
$username = $_POST['username'];
$email = $_POST['email'];
$favorite_games = $_POST['favorite_games'];

// Profil fotoğrafı yükleme işlemi
$profile_image = null;
if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === UPLOAD_ERR_OK) {
    $upload_dir = 'uploads/';
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }
    
    $file_extension = strtolower(pathinfo($_FILES['profile_image']['name'], PATHINFO_EXTENSION));
    $new_filename = uniqid() . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;
    
    if (move_uploaded_file($_FILES['profile_image']['tmp_name'], $upload_path)) {
        $profile_image = $upload_path;
    }
}

// SQL sorgusunu hazırla
$sql = "UPDATE users SET username = ?, email = ?, favorite_games = ?";
$params = [$username, $email, $favorite_games];
$types = "sss";

if ($profile_image !== null) {
    $sql .= ", profile_image = ?";
    $params[] = $profile_image;
    $types .= "s";
}

$sql .= " WHERE id = ?";
$params[] = $user_id;
$types .= "i";

$stmt = $conn->prepare($sql);
$stmt->bind_param($types, ...$params);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Profile updated successfully']);
} else {
    echo json_encode(['error' => 'Failed to update profile: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?> 
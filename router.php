<?php
// Block access to sensitive directories
$forbidden_paths = [
    '/data',
    '/config',
    '/.htaccess',
    '/.user.ini'
];

$request_uri = parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH);

foreach ($forbidden_paths as $path) {
    if (strpos($request_uri, $path) === 0) {
        http_response_code(403);
        echo "403 Forbidden";
        exit;
    }
}

// Serve Nextcloud normally
$requested_file = $_SERVER['DOCUMENT_ROOT'] . $_SERVER["SCRIPT_NAME"];

if (file_exists($requested_file) && is_file($requested_file)) {
    return false; // Let PHP serve the file directly
} else {
    include __DIR__ . "/index.php"; // Route requests to Nextcloud
}
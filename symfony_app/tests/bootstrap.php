<?php

use Symfony\Component\Dotenv\Dotenv;

require dirname(__DIR__).'/vendor/autoload.php';

if (method_exists(Dotenv::class, 'bootEnv')) {
    (new Dotenv())->bootEnv(dirname(__DIR__).'/.env');
}

if ($_SERVER['APP_DEBUG']) {
    umask(0000);
}

// Completely suppress deprecation warnings in tests
error_reporting(E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED);

// Disable Doctrine deprecation warnings completely
if (class_exists('Doctrine\Deprecations\Deprecation')) {
    \Doctrine\Deprecations\Deprecation::ignoreDeprecations();
}

// Set deprecation handler to null to suppress all deprecation warnings
set_error_handler(function($severity, $message, $file, $line) {
    if ($severity === E_DEPRECATED || $severity === E_USER_DEPRECATED) {
        return true; // Suppress deprecation warnings
    }
    return false; // Let other errors through
});

<?php

namespace App\Service;

use App\Entity\User;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\Request;

class ApiService
{
    private const API_BASE_URL = 'http://host.docker.internal:4000/api';

    public function __construct(
        private HttpClientInterface $httpClient
    ) {}

    public function getUsers(array $filters = [], array $sort = [], int $page = 1, int $perPage = 10): array
    {
        $queryParams = array_merge($filters, [
            'page' => $page,
            'per_page' => $perPage,
        ]);

        if (!empty($sort)) {
            $queryParams['sort'] = implode(',', $sort);
        }

        $response = $this->httpClient->request('GET', self::API_BASE_URL . '/users', [
            'query' => $queryParams,
        ]);

        $data = json_decode($response->getContent(), true);

        return [
            'users' => array_map(fn($userData) => User::fromArray($userData), $data['data'] ?? []),
            'pagination' => $data['pagination'] ?? [],
        ];
    }

    public function getUser(int $id): ?User
    {
        try {
            $response = $this->httpClient->request('GET', self::API_BASE_URL . '/users/' . $id);
            $data = json_decode($response->getContent(), true);
            
            return User::fromArray($data);
        } catch (\Exception $e) {
            return null;
        }
    }

    public function createUser(User $user): ?User
    {
        try {
            $response = $this->httpClient->request('POST', self::API_BASE_URL . '/users', [
                'json' => $user->toArray(),
            ]);

            $data = json_decode($response->getContent(), true);
            return User::fromArray($data);
        } catch (\Exception $e) {
            return null;
        }
    }

    public function updateUser(int $id, User $user): ?User
    {
        try {
            $response = $this->httpClient->request('PUT', self::API_BASE_URL . '/users/' . $id, [
                'json' => $user->toArray(),
            ]);

            $data = json_decode($response->getContent(), true);
            return User::fromArray($data);
        } catch (\Exception $e) {
            return null;
        }
    }

    public function deleteUser(int $id): bool
    {
        try {
            $this->httpClient->request('DELETE', self::API_BASE_URL . '/users/' . $id);
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    public function import(): ?array
    {
        try {
            $response = $this->httpClient->request('POST', self::API_BASE_URL . '/import');
            $data = json_decode($response->getContent(), true);
            return $data;
        } catch (\Exception $e) {
            return null;
        }
    }
} 

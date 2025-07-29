<?php

namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class UserControllerTest extends WebTestCase
{
    public function testIndex(): void
    {
        $client = static::createClient();
        $crawler = $client->request('GET', '/users/');

        // The page should load even if the API is not available
        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('h1');
        
        // Check if the page contains expected elements
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('.card');
    }

    public function testNew(): void
    {
        $client = static::createClient();
        $crawler = $client->request('GET', '/users/new');

        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('input[name*="firstName"]');
        $this->assertSelectorExists('input[name*="lastName"]');
    }

    public function testShow(): void
    {
        $client = static::createClient();
        $crawler = $client->request('GET', '/users/1');

        // This should return 200 since the API is working
        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('h3');
        $this->assertSelectorExists('.card');
    }

    public function testEdit(): void
    {
        $client = static::createClient();
        $crawler = $client->request('GET', '/users/1/edit');

        // This should return 200 since the API is working
        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('input[name*="firstName"]');
        $this->assertSelectorExists('input[name*="lastName"]');
    }
} 

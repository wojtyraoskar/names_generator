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

    public function testFilteringAndSortingParametersPreserved(): void
    {
        $client = static::createClient();
        
        // Test that filtering and sorting parameters are preserved in URLs
        $crawler = $client->request('GET', '/users/?firstName=John&lastName=Doe&sort=first_name&direction=desc&page=2');
        
        $this->assertResponseIsSuccessful();
        
        // Check that the page contains the expected elements
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('.card');
        
        // Check if there's a table (users exist) or empty state message
        $tableExists = $crawler->filter('table')->count() > 0;
        $emptyStateExists = $crawler->filter('.text-muted:contains("No users found")')->count() > 0;
        
        $this->assertTrue($tableExists || $emptyStateExists, 'Neither table nor empty state found');
        
        // If table exists, check sorting links
        if ($tableExists) {
            $sortLinks = $crawler->filter('thead th a');
            $this->assertGreaterThan(0, $sortLinks->count(), 'No sort links found in table header');
            
            // Verify that at least one sort link contains filter parameters
            $foundLinkWithParams = false;
            foreach ($sortLinks as $link) {
                $href = $link->getAttribute('href');
                if ($href && strpos($href, 'sort=') !== false) {
                    $this->assertStringContainsString('firstName=John', $href);
                    $this->assertStringContainsString('lastName=Doe', $href);
                    $foundLinkWithParams = true;
                    break;
                }
            }
            
            $this->assertTrue($foundLinkWithParams, 'No sort links with filter parameters found');
        }
    }
} 

<?php

namespace App\Tests\Controller;

use App\Entity\User;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\DependencyInjection\ContainerInterface;
use ReflectionClass;

class UserControllerIntegrationTest extends WebTestCase
{
    private function createUserWithId(int $id, string $firstName, string $lastName, \DateTime $birthdate, string $gender): User
    {
        $user = new User();
        $user->setFirstName($firstName);
        $user->setLastName($lastName);
        $user->setBirthdate($birthdate);
        $user->setGender($gender);
        
        // Use reflection to set the private id field
        $reflection = new ReflectionClass(User::class);
        $idProperty = $reflection->getProperty('id');
        $idProperty->setAccessible(true);
        $idProperty->setValue($user, $id);
        
        return $user;
    }

    public function testIndexWithUsers(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUsers')
            ->willReturn([
                'users' => [
                    $this->createUserWithId(1, 'John', 'Doe', new \DateTime('1990-01-01'), 'male'),
                    $this->createUserWithId(2, 'Jane', 'Smith', new \DateTime('1995-05-15'), 'female'),
                ],
                'pagination' => [
                    'page' => 1,
                    'per_page' => 10,
                    'total_count' => 2,
                    'total_pages' => 1,
                    'has_next' => false,
                    'has_prev' => false,
                ],
            ]);

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/');

        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('h1');
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('.card');
        $this->assertSelectorExists('table');
        $this->assertSelectorTextContains('table', 'John');
        $this->assertSelectorTextContains('table', 'Jane');
    }

    public function testIndexWithNoUsers(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUsers')
            ->willReturn([
                'users' => [],
                'pagination' => [
                    'page' => 1,
                    'per_page' => 10,
                    'total_count' => 0,
                    'total_pages' => 0,
                    'has_next' => false,
                    'has_prev' => false,
                ],
            ]);

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/');

        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('h1');
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('.card');
        $this->assertSelectorTextContains('h4.text-muted', 'No users found');
    }

    public function testShowWithExistingUser(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUser')
            ->willReturn($this->createUserWithId(1, 'John', 'Doe', new \DateTime('1990-01-01'), 'male'));

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/1');

        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('h3');
        $this->assertSelectorExists('.card');
        $this->assertSelectorTextContains('.card', 'John');
        $this->assertSelectorTextContains('.card', 'Doe');
    }

    public function testShowWithNonExistentUser(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUser')
            ->willReturn(null);

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/999');

        $this->assertResponseStatusCodeSame(404);
    }

    public function testEditWithExistingUser(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUser')
            ->willReturn($this->createUserWithId(1, 'John', 'Doe', new \DateTime('1990-01-01'), 'male'));

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/1/edit');

        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('input[name*="firstName"]');
        $this->assertSelectorExists('input[name*="lastName"]');
    }

    public function testEditWithNonExistentUser(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUser')
            ->willReturn(null);

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/999/edit');

        $this->assertResponseStatusCodeSame(404);
    }

    public function testNewUserForm(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);

        $crawler = $client->request('GET', '/users/new');

        $this->assertResponseIsSuccessful();
        $this->assertSelectorExists('form');
        $this->assertSelectorExists('input[name*="firstName"]');
        $this->assertSelectorExists('input[name*="lastName"]');
    }

    public function testFilteringAndSortingParametersPreserved(): void
    {
        $client = static::createClient();
        
        // Create a mock API service
        $apiService = $this->createMock(ApiService::class);
        $apiService->method('getUsers')
            ->willReturn([
                'users' => [
                    $this->createUserWithId(1, 'John', 'Doe', new \DateTime('1990-01-01'), 'male'),
                ],
                'pagination' => [
                    'page' => 2,
                    'per_page' => 10,
                    'total_count' => 1,
                    'total_pages' => 1,
                    'has_next' => false,
                    'has_prev' => true,
                ],
            ]);

        // Replace the service in the container
        $container = $client->getContainer();
        $container->set(ApiService::class, $apiService);
        
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

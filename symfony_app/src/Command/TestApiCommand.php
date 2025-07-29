<?php

namespace App\Command;

use App\Service\ApiService;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;

#[AsCommand(
    name: 'app:test-api',
    description: 'Test the connection to the Phoenix API',
)]
class TestApiCommand extends Command
{
    public function __construct(
        private ApiService $apiService
    ) {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new SymfonyStyle($input, $output);

        $io->title('Testing Phoenix API Connection');

        try {
            $result = $this->apiService->getUsers([], [], 1, 5);
            
            $io->success('API connection successful!');
            $io->text(sprintf('Found %d users', count($result['users'])));
            
            if (!empty($result['users'])) {
                $io->section('Sample Users:');
                foreach (array_slice($result['users'], 0, 3) as $user) {
                    $io->text(sprintf('- %s %s (%s)', $user->getFirstName(), $user->getLastName(), $user->getGender()));
                }
            }
            
            return Command::SUCCESS;
        } catch (\Exception $e) {
            $io->error('API connection failed: ' . $e->getMessage());
            $io->text('Make sure the Phoenix API is running on http://localhost:4000');
            return Command::FAILURE;
        }
    }
} 

<?php

namespace App\Controller;

use App\Entity\User;
use App\Form\UserFilterType;
use App\Form\UserType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\RedirectResponse;

#[Route('/users')]
class UserController extends AbstractController
{
    public function __construct(
        private ApiService $apiService
    ) {}

    #[Route('/', name: 'app_user_index', methods: ['GET'])]
    public function index(Request $request): Response
    {
        // Handle filters
        $filterForm = $this->createForm(UserFilterType::class);
        $filterForm->handleRequest($request);

        $filters = [];
        if ($filterForm->isSubmitted() && $filterForm->isValid()) {
            $data = $filterForm->getData();
            
            if ($data['firstName']) {
                $filters['first_name'] = $data['firstName'];
            }
            if ($data['lastName']) {
                $filters['last_name'] = $data['lastName'];
            }
            if ($data['gender']) {
                $filters['gender'] = $data['gender'];
            }
            if ($data['birthdateFrom']) {
                $filters['birthdate_from'] = $data['birthdateFrom']->format('Y-m-d');
            }
            if ($data['birthdateTo']) {
                $filters['birthdate_to'] = $data['birthdateTo']->format('Y-m-d');
            }
        }

        // Handle sorting
        $sort = [];
        $sortField = $request->query->get('sort');
        $sortDirection = $request->query->get('direction', 'asc');
        
        if ($sortField) {
            $sort[] = $sortDirection === 'desc' ? "-{$sortField}" : $sortField;
        }

        // Handle pagination
        $page = max(1, (int) $request->query->get('page', 1));
        $perPage = max(1, min(50, (int) $request->query->get('per_page', 10)));

        try {
            $result = $this->apiService->getUsers($filters, $sort, $page, $perPage);
        } catch (\Exception $e) {
            // If API is not available, show empty state
            $result = [
                'users' => [],
                'pagination' => [
                    'page' => $page,
                    'per_page' => $perPage,
                    'total_count' => 0,
                    'total_pages' => 0,
                    'has_next' => false,
                    'has_prev' => false,
                ],
            ];
            
            $this->addFlash('warning', 'API connection failed. Please ensure the Phoenix API is running.');
        }

        // Build query parameters for template
        $queryParams = [];
        if ($request->query->has('page')) {
            $queryParams['page'] = $request->query->get('page');
        }
        if ($request->query->has('per_page')) {
            $queryParams['per_page'] = $request->query->get('per_page');
        }
        if ($request->query->has('sort')) {
            $queryParams['sort'] = $request->query->get('sort');
        }
        if ($request->query->has('direction')) {
            $queryParams['direction'] = $request->query->get('direction');
        }

        return $this->render('user/index.html.twig', [
            'users' => $result['users'],
            'pagination' => $result['pagination'],
            'filterForm' => $filterForm->createView(),
            'currentSort' => $sortField,
            'currentDirection' => $sortDirection,
            'queryParams' => $queryParams,
        ]);
    }

    #[Route('/new', name: 'app_user_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        $user = new User();
        $form = $this->createForm(UserType::class, $user);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $createdUser = $this->apiService->createUser($user);
                
                if ($createdUser) {
                    $this->addFlash('success', 'User created successfully!');
                    return $this->redirectToRoute('app_user_index');
                } else {
                    $this->addFlash('error', 'Failed to create user. Please try again.');
                }
            } catch (\Exception $e) {
                $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
            }
        }

        return $this->render('user/new.html.twig', [
            'user' => $user,
            'form' => $form->createView(),
        ]);
    }

    #[Route('/{id}', name: 'app_user_show', methods: ['GET'])]
    public function show(int $id): Response
    {
        try {
            $user = $this->apiService->getUser($id);
            
            if (!$user) {
                throw $this->createNotFoundException('User not found');
            }

            return $this->render('user/show.html.twig', [
                'user' => $user,
            ]);
        } catch (\Exception $e) {
            throw $this->createNotFoundException('User not found or API connection failed');
        }
    }

    #[Route('/{id}/edit', name: 'app_user_edit', methods: ['GET', 'POST'])]
    public function edit(Request $request, int $id): Response
    {
        try {
            $user = $this->apiService->getUser($id);
            
            if (!$user) {
                throw $this->createNotFoundException('User not found');
            }

            $form = $this->createForm(UserType::class, $user);
            $form->handleRequest($request);

            if ($form->isSubmitted() && $form->isValid()) {
                try {
                    $updatedUser = $this->apiService->updateUser($id, $user);
                    
                    if ($updatedUser) {
                        $this->addFlash('success', 'User updated successfully!');
                        return $this->redirectToRoute('app_user_show', ['id' => $id]);
                    } else {
                        $this->addFlash('error', 'Failed to update user. Please try again.');
                    }
                } catch (\Exception $e) {
                    $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
                }
            }

            return $this->render('user/edit.html.twig', [
                'user' => $user,
                'form' => $form->createView(),
            ]);
        } catch (\Exception $e) {
            throw $this->createNotFoundException('User not found or API connection failed');
        }
    }

    #[Route('/{id}', name: 'app_user_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('delete'.$id, $request->request->get('_token'))) {
            try {
                $success = $this->apiService->deleteUser($id);
                
                if ($success) {
                    $this->addFlash('success', 'User deleted successfully!');
                } else {
                    $this->addFlash('error', 'Failed to delete user. Please try again.');
                }
            } catch (\Exception $e) {
                $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
            }
        }

        return $this->redirectToRoute('app_user_index');
    }
} 

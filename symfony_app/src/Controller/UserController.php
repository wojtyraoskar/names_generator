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

#[Route('/users')]
class UserController extends AbstractController
{
    public function __construct(private readonly ApiService $apiService) {}

    #[Route('/', name: 'app_user_index', methods: ['GET'])]
    public function index(Request $request): Response
    {
        $filterForm = $this->createForm(UserFilterType::class, null, ['method' => 'GET']);
        $filterForm->handleRequest($request);

        $data = $filterForm->getData() ?? [];

        $filters = array_filter([
            'first_name'     => $data['firstName'] ?? null,
            'last_name'      => $data['lastName'] ?? null,
            'gender'         => $data['gender'] ?? null,
            'birthdate_from' => isset($data['birthdateFrom']) ? $data['birthdateFrom']->format('Y-m-d') : null,
            'birthdate_to'   => isset($data['birthdateTo']) ? $data['birthdateTo']->format('Y-m-d') : null,
        ]);

        $sortField     = $request->query->get('sort');
        $sortDirection = $request->query->get('direction', 'asc');
        $sort          = $sortField ? [($sortDirection === 'desc' ? '-' : '') . $sortField] : [];

        $page    = max(1, $request->query->getInt('page', 1));
        $perPage = max(1, min(50, $request->query->getInt('per_page', 10)));

        try {
            $result = $this->apiService->getUsers($filters, $sort, $page, $perPage);
        } catch (\Throwable) {
            $this->addFlash('warning', 'API connection failed. Please ensure the Phoenix API is running.');
            $result = [
                'users'      => [],
                'pagination' => [
                    'page'         => $page,
                    'per_page'     => $perPage,
                    'total_count'  => 0,
                    'total_pages'  => 0,
                    'has_next'     => false,
                    'has_prev'     => false,
                ],
            ];
        }

        return $this->render('user/index.html.twig', [
            'users'            => $result['users'],
            'pagination'       => $result['pagination'],
            'filterForm'       => $filterForm->createView(),
            'currentSort'      => $sortField,
            'currentDirection' => $sortDirection,
            'queryParams'      => $request->query->all(),
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
                $this->apiService->createUser($user);
                $this->addFlash('success', 'User created successfully!');
                return $this->redirectToRoute('app_user_index');
            } catch (\Throwable) {
                $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
            }
        }

        return $this->render('user/new.html.twig', [
            'user' => $user,
            'form' => $form->createView(),
        ]);
    }

    #[Route('/import', name: 'app_user_import', methods: ['POST'])]
    public function import(): Response
    {
        try {
            $result = $this->apiService->import();
            if ($result) {
                $this->addFlash('success', $result['message'] ?? 'Import completed successfully!');
            } else {
                $this->addFlash('error', 'Import failed. Please try again.');
            }
        } catch (\Throwable) {
            $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
        }

        return $this->redirectToRoute('app_user_index');
    }

    #[Route('/{id}', name: 'app_user_show', methods: ['GET'])]
    public function show(int $id): Response
    {
        try {
            $user = $this->apiService->getUser($id) ?? throw $this->createNotFoundException();
        } catch (\Throwable) {
            throw $this->createNotFoundException('User not found or API connection failed');
        }

        return $this->render('user/show.html.twig', compact('user'));
    }

    #[Route('/{id}/edit', name: 'app_user_edit', methods: ['GET', 'POST'])]
    public function edit(Request $request, int $id): Response
    {
        try {
            $user = $this->apiService->getUser($id) ?? throw $this->createNotFoundException();
        } catch (\Throwable) {
            throw $this->createNotFoundException('User not found or API connection failed');
        }

        $form = $this->createForm(UserType::class, $user);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->updateUser($id, $user);
                $this->addFlash('success', 'User updated successfully!');
                return $this->redirectToRoute('app_user_show', ['id' => $id]);
            } catch (\Throwable) {
                $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
            }
        }

        return $this->render('user/edit.html.twig', [
            'user' => $user,
            'form' => $form->createView(),
        ]);
    }

    #[Route('/{id}', name: 'app_user_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('delete'.$id, $request->request->get('_token'))) {
            try {
                $this->apiService->deleteUser($id)
                    ? $this->addFlash('success', 'User deleted successfully!')
                    : $this->addFlash('error', 'Failed to delete user. Please try again.');
            } catch (\Throwable) {
                $this->addFlash('error', 'API connection failed. Please ensure the Phoenix API is running.');
            }
        }

        return $this->redirectToRoute('app_user_index');
    }
}
